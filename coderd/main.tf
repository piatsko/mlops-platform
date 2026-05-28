resource "coderd_template" "data_science" {
  name         = "data-science"
  display_name = "Data Science"
  description  = "RStudio + JupyterLab on rocker/verse. Runs as root; for local development only."
  icon         = "/icon/jupyter.svg"

  versions = [
    {
      directory = "${path.module}/templates/data-science"
      active    = true
      tf_vars = [
        {
          name  = "workspace_namespace"
          value = var.workspaces_namespace
        }
      ]
    }
  ]
}

resource "coderd_template" "kubernetes_workspace" {
  name         = "kubernetes-workspace"
  display_name = "Kubernetes Workspace"
  description  = "A workspace running as a Kubernetes pod on the local kind cluster."
  icon         = "/icon/k8s.png"

  versions = [
    {
      directory = "${path.module}/templates/kubernetes-workspace"
      active    = true
      tf_vars = [
        {
          name  = "workspace_namespace"
          value = var.workspaces_namespace
        }
      ]
    }
  ]
}
