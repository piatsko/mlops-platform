output "external_url" {
  value       = var.external_url
  description = "External Keycloak URL — matches KC_HOSTNAME_URL, used as OIDC issuer base."
}

output "internal_url" {
  value       = "http://keycloak.${var.namespace}.svc.cluster.local"
  description = "In-cluster Keycloak URL."
}
