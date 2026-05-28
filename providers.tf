# helm and kubernetes providers connect via the kubeconfig file that the kind
# provider writes after cluster creation. Run `tofu apply -target=module.cluster`
# first on a fresh environment so this file exists before the second full apply.
provider "helm" {
  kubernetes {
    config_path = "${path.module}/${var.cluster_name}-config"
  }
  repository_cache       = pathexpand("~/Library/Caches/helm/repository")
  repository_config_path = pathexpand("~/Library/Preferences/helm/repositories.yaml")
}

provider "kubernetes" {
  config_path = "${path.module}/${var.cluster_name}-config"
}
