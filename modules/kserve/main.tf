module "knative" {
  source = "./modules/knative"

  operator_namespace = var.knative_operator_namespace
  serving_namespace  = var.knative_serving_namespace
  operator_version   = var.knative_operator_version
  serving_version    = var.knative_serving_version
  domain             = var.knative_domain
  kubeconfig_path    = var.kubeconfig_path
  kubeconfig_context = var.kubeconfig_context
}

module "kserve" {
  source = "./modules/kserve"

  namespace        = var.kserve_namespace
  chart_version    = var.kserve_version
  install_runtimes = var.kserve_install_runtimes

  depends_on = [module.knative]
}

module "llmisvc" {
  source = "./modules/llmisvc"
  count  = var.enable_llmisvc ? 1 : 0

  kserve_namespace      = var.kserve_namespace
  kserve_version        = var.kserve_version
  gateway_api_version   = var.gateway_api_version
  lws_version           = var.lws_version
  envoy_gateway_version = var.envoy_gateway_version
  kubeconfig_path       = var.kubeconfig_path
  kubeconfig_context    = var.kubeconfig_context

  depends_on = [module.kserve]
}
