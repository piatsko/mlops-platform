resource "helm_release" "istio_base" {
  name             = "istio-base"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "base"
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = true
  wait             = true
  timeout          = 300

  set = [
    { name = "defaultRevision", value = "default" }
  ]
}

resource "helm_release" "istiod" {
  name       = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  version    = var.chart_version
  namespace  = var.namespace
  wait       = true
  timeout    = 600

  set = concat(
    [
      { name = "proxy.autoInject", value = "disabled" },
      { name = "pilot.env.ENABLE_GATEWAY_API_INFERENCE_EXTENSION", value = "true" },
      { name = "pilot.podAnnotations.cluster-autoscaler\\.kubernetes\\.io/safe-to-evict", value = "true", type = "string" },
    ],
    [for k, v in var.istiod_set : { name = k, value = v }]
  )

  depends_on = [helm_release.istio_base]
}

resource "helm_release" "istio_ingressgateway" {
  name       = "istio-ingressgateway"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  version    = var.chart_version
  namespace  = var.namespace
  wait       = true
  timeout    = 600

  set = concat(
    [
      { name = "podAnnotations.cluster-autoscaler\\.kubernetes\\.io/safe-to-evict", value = "true", type = "string" },
    ],
    [for k, v in var.gateway_set : { name = k, value = v }]
  )

  depends_on = [helm_release.istiod]
}
