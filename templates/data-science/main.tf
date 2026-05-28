data "coder_workspace" "me" {}
data "coder_workspace_owner" "me" {}

resource "coder_agent" "main" {
  os   = "linux"
  arch = "arm64"
  dir  = "/home/jovyan"

  startup_script = <<-EOT
    set -e

    # Install JupyterLab extensions
    pip install --quiet \
      jupyterlab-git \
      jupyter-lsp \
      python-lsp-server \
      jupyter-server-proxy

    # base_url must match the Coder path-based proxy prefix so JupyterLab
    # emits absolute asset paths the browser can resolve through the proxy
    jupyter lab \
      --ip=0.0.0.0 \
      --port=8888 \
      --no-browser \
      --ServerApp.token='' \
      --ServerApp.password='' \
      --ServerApp.base_url="/@$${CODER_WORKSPACE_OWNER_NAME}/$${CODER_WORKSPACE_NAME}.main/apps/jupyterlab/" \
      >/tmp/jupyter.log 2>&1 &
  EOT

  display_apps {
    vscode         = false
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

resource "coder_app" "jupyterlab" {
  agent_id     = coder_agent.main.id
  slug         = "jupyterlab"
  display_name = "JupyterLab"
  url          = "http://localhost:8888/@${data.coder_workspace_owner.me.name}/${data.coder_workspace.me.name}.main/apps/jupyterlab"
  icon         = "/icon/jupyter.svg"
  subdomain    = false
  share        = "owner"

  healthcheck {
    url       = "http://localhost:8888/@${data.coder_workspace_owner.me.name}/${data.coder_workspace.me.name}.main/apps/jupyterlab/api"
    interval  = 5
    threshold = 10
  }
}

resource "kubernetes_pod" "workspace" {
  count = data.coder_workspace.me.start_count

  metadata {
    name      = "coder-${data.coder_workspace_owner.me.name}-${lower(data.coder_workspace.me.name)}"
    namespace = var.workspace_namespace
    labels = {
      "app.kubernetes.io/name" = "coder-workspace"
      "coder.owner"            = data.coder_workspace_owner.me.name
      "coder.workspace_id"     = data.coder_workspace.me.id
      "coder.workspace_name"   = data.coder_workspace.me.name
    }
  }

  spec {
    security_context {
      run_as_user = 1000
      fs_group    = 100
    }

    container {
      name              = "dev"
      image             = "quay.io/jupyter/scipy-notebook:latest"
      image_pull_policy = "IfNotPresent"
      command           = ["sh", "-c", replace(coder_agent.main.init_script, "/localhost|127\\.0\\.0\\.1/", "host.docker.internal")]

      env {
        name  = "CODER_AGENT_TOKEN"
        value = coder_agent.main.token
      }

      resources {
        requests = {
          cpu    = "500m"
          memory = "2Gi"
        }
        limits = {
          cpu    = "2"
          memory = "8Gi"
        }
      }
    }
  }
}
