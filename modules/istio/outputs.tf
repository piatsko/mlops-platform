output "namespace" {
  value = helm_release.istio_base.namespace
}

output "ingressgateway_status" {
  value = helm_release.istio_ingressgateway.status
}
