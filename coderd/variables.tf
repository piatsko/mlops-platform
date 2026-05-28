variable "coder_url" {
  type        = string
  description = "URL of the Coder deployment."
  default     = "http://localhost:8080"
}

variable "coder_api_token" {
  type        = string
  description = "Coder API token. Create one at <coder_url>/settings/tokens."
  sensitive   = true
}

variable "workspaces_namespace" {
  type        = string
  description = "Kubernetes namespace where workspace pods are created."
  default     = "coder-workspaces"
}
