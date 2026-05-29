output "cluster_name" {
  value       = module.cluster.cluster_name
  description = "Name of the created kind cluster."
}

output "endpoint" {
  value       = module.cluster.endpoint
  description = "Kubernetes API server endpoint."
}

output "kubeconfig_path" {
  value       = module.cluster.kubeconfig_path
  description = "Path to the kubeconfig file."
}

output "kubeconfig" {
  value       = module.cluster.kubeconfig
  description = "Raw kubeconfig (sensitive)."
  sensitive   = true
}

output "coder_url" {
  value       = module.coder.access_url
  description = "Open this URL to access Coder."
}

output "cert_manager_namespace" {
  value       = module.cert_manager.namespace
  description = "Namespace where cert-manager is deployed."
}

output "istio_namespace" {
  value       = module.istio.namespace
  description = "Namespace where Istio is deployed."
}

output "kserve_namespace" {
  value       = module.kserve.kserve_namespace
  description = "Namespace where KServe is deployed."
}

output "kserve_status" {
  value       = module.kserve.kserve_status
  description = "KServe Helm release status."
}

output "llmisvc_status" {
  value       = module.kserve.llmisvc_status
  description = "LLMISvc status (disabled if enable_llmisvc=false)."
}
