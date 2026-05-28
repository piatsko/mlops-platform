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

output "keycloak_url" {
  value       = module.keycloak.external_url
  description = "Open this URL to access the Keycloak admin console."
}
