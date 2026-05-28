module "cluster" {
  source = "./kind-cluster"

  cluster_name = var.cluster_name
  node_image   = var.node_image
  worker_count = var.worker_count

  extra_port_mappings = concat(
    var.extra_port_mappings,
    [
      { container_port = 30080, host_port = 8080, protocol = "TCP" }, # Coder
    ]
  )
}

module "coder" {
  source = "./coder"

  namespace  = "coder"
  access_url = "http://localhost:8080"

  depends_on = [module.cluster]
}

# ── Coder templates ───────────────────────────────────────────────────────────

resource "coderd_template" "data_science" {
  count        = var.coder_api_token != "" ? 1 : 0
  name         = "data-science"
  display_name = "Data Science"
  description  = "RStudio + JupyterLab on rocker/verse. Runs as root; for local development only."
  icon         = "/icon/jupyter.svg"

  versions = [
    {
      directory = "./coder/workspace-templates/data-science"
      active    = true
      tf_vars = [
        {
          name  = "workspace_namespace"
          value = "coder-workspaces"
        }
      ]
    }
  ]

  depends_on = [module.coder]
}

resource "coderd_template" "kubernetes_workspace" {
  count        = var.coder_api_token != "" ? 1 : 0
  name         = "kubernetes-workspace"
  display_name = "Kubernetes Workspace"
  description  = "A workspace running as a Kubernetes pod on the local kind cluster."
  icon         = "/icon/k8s.png"

  versions = [
    {
      directory = "./coder/workspace-templates/kubernetes-workspace"
      active    = true
      tf_vars = [
        {
          name  = "workspace_namespace"
          value = "coder-workspaces"
        }
      ]
    }
  ]

  depends_on = [module.coder]
}
