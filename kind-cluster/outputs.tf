output "cluster_name" {
  value       = kind_cluster.this.name
  description = "Name of the created kind cluster."
}

output "endpoint" {
  value       = kind_cluster.this.endpoint
  description = "Kubernetes API server endpoint."
}

output "kubeconfig" {
  value       = kind_cluster.this.kubeconfig
  description = "Raw kubeconfig for the cluster."
  sensitive   = true
}

output "kubeconfig_path" {
  value       = kind_cluster.this.kubeconfig_path
  description = "Path to the kubeconfig file written by the kind provider."
}
