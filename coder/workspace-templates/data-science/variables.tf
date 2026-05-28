variable "workspace_namespace" {
  type        = string
  description = "Kubernetes namespace to create workspace pods in."
  default     = "coder-workspaces"
}
