output "envoy_gateway_status" {
  value = helm_release.envoy_gateway.status
}

output "kserve_llmisvc_status" {
  value = helm_release.kserve_llmisvc_resources.status
}
