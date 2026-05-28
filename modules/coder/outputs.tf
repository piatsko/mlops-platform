output "access_url" {
  value       = var.access_url
  description = "URL to open Coder in a browser."
}

output "namespace" {
  value       = kubernetes_namespace_v1.coder.metadata[0].name
  description = "Kubernetes namespace where Coder is deployed."
}

output "workspaces_namespace" {
  value       = kubernetes_namespace_v1.workspaces.metadata[0].name
  description = "Namespace where workspace pods run."
}

output "pg_password" {
  value       = local.pg_password
  description = "PostgreSQL password (auto-generated or provided)."
  sensitive   = true
}
