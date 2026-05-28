data "coder_workspace" "me" {}
data "coder_workspace_owner" "me" {}

data "coder_parameter" "image" {
  name         = "image"
  display_name = "Container image"
  description  = "Base Docker image for the workspace container."
  default      = "codercom/enterprise-base:ubuntu"
  mutable      = true

  option {
    name  = "Ubuntu (Coder base)"
    value = "codercom/enterprise-base:ubuntu"
  }
  option {
    name  = "Ubuntu 22.04"
    value = "ubuntu:22.04"
  }
}

resource "coder_agent" "main" {
  os   = "linux"
  arch = "amd64"

  startup_script = <<-EOT
    set -e
    curl -fsSL https://code-server.dev/install.sh | sh -s -- --method=standalone --prefix=/tmp/code-server
    /tmp/code-server/bin/code-server --auth none --port 13337 >/tmp/code-server.log 2>&1 &
  EOT

  display_apps {
    vscode         = true
    web_terminal   = true
    ssh_helper     = true
  }

  metadata {
    display_name = "CPU Usage"
    key          = "cpu"
    script       = "coder stat cpu"
    interval     = 10
    timeout      = 2
    order        = 1
  }
  metadata {
    display_name = "Memory"
    key          = "mem"
    script       = "coder stat mem"
    interval     = 10
    timeout      = 2
    order        = 2
  }
}

resource "coder_app" "code_server" {
  agent_id     = coder_agent.main.id
  slug         = "code-server"
  display_name = "VS Code"
  url          = "http://localhost:13337"
  icon         = "/icon/code.svg"
  subdomain    = false
  share        = "owner"

  healthcheck {
    url       = "http://localhost:13337/healthz"
    interval  = 5
    threshold = 6
  }
}

resource "kubernetes_pod" "workspace" {
  count = data.coder_workspace.me.start_count

  metadata {
    name      = "coder-${data.coder_workspace_owner.me.name}-${lower(data.coder_workspace.me.name)}"
    namespace = var.workspace_namespace
    labels = {
      "app.kubernetes.io/name"   = "coder-workspace"
      "coder.owner"              = data.coder_workspace_owner.me.name
      "coder.workspace_id"       = data.coder_workspace.me.id
      "coder.workspace_name"     = data.coder_workspace.me.name
    }
  }

  spec {
    security_context {
      run_as_user = 1000
      fs_group    = 1000
    }

    container {
      name              = "dev"
      image             = data.coder_parameter.image.value
      image_pull_policy = "Always"
      command           = ["sh", "-c", replace(coder_agent.main.init_script, "/localhost|127\\.0\\.0\\.1/", "host.docker.internal")]

      security_context {
        run_as_user = 1000
      }

      env {
        name  = "CODER_AGENT_TOKEN"
        value = coder_agent.main.token
      }

      resources {
        requests = {
          cpu    = "250m"
          memory = "512Mi"
        }
        limits = {
          cpu    = "1"
          memory = "2Gi"
        }
      }
    }
  }
}
 output "coder_script" {
   sensitive = true
   value = coder_agent.main.init_script
 }