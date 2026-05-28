variable "namespace" {
  type        = string
  description = "Kubernetes namespace for Coder and its database."
  default     = "coder"
}

variable "access_url" {
  type        = string
  description = "Publicly reachable URL for Coder (used in emails, agent connections, etc.)."
  default     = "http://localhost:8080"
}

variable "coder_chart_version" {
  type        = string
  description = "Coder Helm chart version (stable channel). See https://github.com/coder/coder/releases."
  default     = "2.32.1"
}

variable "pg_chart_version" {
  type        = string
  description = "Bitnami PostgreSQL Helm chart version. Leave empty for latest."
  default     = ""
}

variable "pg_password" {
  type        = string
  description = "PostgreSQL password. Auto-generated when empty."
  default     = ""
  sensitive   = true
}

variable "workspaces_namespace" {
  type        = string
  description = "Kubernetes namespace where workspace pods are created."
  default     = "coder-workspaces"
}

variable "node_port" {
  type        = number
  description = "NodePort number for the external Coder service (must match kind extraPortMappings container_port)."
  default     = 30080
}
