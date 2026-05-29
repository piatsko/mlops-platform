module "cluster" {
  source = "./modules/kind-cluster"

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
  source = "./modules/coder"

  namespace  = "coder"
  access_url = "http://localhost:8080"

  depends_on = [module.cluster]
}

module "cert_manager" {
  source = "./modules/cert-manager"

  namespace     = var.cert_manager_namespace
  chart_version = var.cert_manager_version

  depends_on = [module.cluster]
}

module "istio" {
  source = "./modules/istio"

  namespace    = var.istio_namespace
  chart_version = var.istio_version
  istiod_set   = var.istiod_set
  gateway_set  = var.istio_gateway_set

  depends_on = [module.cert_manager]
}

module "kserve" {
  source = "./modules/kserve"

  kubeconfig_path    = "${path.module}/${var.cluster_name}-config"
  kubeconfig_context = "kind-${var.cluster_name}"
  knative_domain     = var.knative_domain
  enable_llmisvc     = var.enable_llmisvc

  depends_on = [module.istio]
}
