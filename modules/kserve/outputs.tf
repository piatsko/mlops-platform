output "knative_serving_namespace" {
  value = module.knative.serving_namespace
}

output "kserve_namespace" {
  value = module.kserve.namespace
}

output "kserve_status" {
  value = module.kserve.status
}

output "llmisvc_status" {
  value = var.enable_llmisvc ? module.llmisvc[0].kserve_llmisvc_status : "disabled"
}
