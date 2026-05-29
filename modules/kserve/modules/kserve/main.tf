locals {
  chart_repo = "oci://ghcr.io/kserve/charts"
}

resource "helm_release" "kserve_crd" {
  name             = "kserve-crd"
  repository       = local.chart_repo
  chart            = "kserve-crd"
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = true
  wait             = true
  timeout          = 300
}

resource "helm_release" "kserve_resources" {
  name       = "kserve-resources"
  repository = local.chart_repo
  chart      = "kserve-resources"
  version    = var.chart_version
  namespace  = var.namespace
  wait       = true
  timeout    = 300

  set = [
    { name = "kserve.version", value = var.chart_version },
    { name = "kserve.controller.deploymentMode", value = "Knative" },
  ]

  depends_on = [helm_release.kserve_crd]
}

resource "helm_release" "kserve_runtime_configs" {
  count      = var.install_runtimes ? 1 : 0
  name       = "kserve-runtime-configs"
  repository = local.chart_repo
  chart      = "kserve-runtime-configs"
  version    = var.chart_version
  namespace  = var.namespace
  wait       = true
  timeout    = 300

  set = [
    { name = "kserve.version", value = var.chart_version },
    { name = "kserve.servingruntime.enabled", value = "true" },
    { name = "kserve.llmisvcConfigs.enabled", value = "false" },
  ]

  depends_on = [helm_release.kserve_resources]
}
