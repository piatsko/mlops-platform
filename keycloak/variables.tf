variable "namespace" {
  type        = string
  description = "Kubernetes namespace for Keycloak."
  default     = "keycloak"
}

variable "node_port" {
  type        = number
  description = "NodePort number for Keycloak (must match kind extraPortMappings container_port)."
  default     = 30081
}

variable "admin_password" {
  type        = string
  sensitive   = true
  description = "Keycloak admin console password."
}

variable "keycloak_version" {
  type        = string
  description = "quay.io/keycloak/keycloak image tag."
  default     = "26.2"
}

variable "external_url" {
  type        = string
  description = "Canonical Keycloak URL. Set as KC_HOSTNAME_URL so all tokens carry this as the issuer. Must be reachable from both the browser and from inside the cluster. For kind, use the in-cluster service DNS + NodePort (e.g. http://keycloak.keycloak.svc.cluster.local:8081) and add that hostname to /etc/hosts on the Mac pointing to 127.0.0.1."
  default     = "http://keycloak.keycloak.svc.cluster.local:8081"
}
