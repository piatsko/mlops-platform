variable "operator_namespace" {
  type    = string
  default = "knative-operator"
}

variable "serving_namespace" {
  type    = string
  default = "knative-serving"
}

variable "operator_version" {
  description = "Knative Operator version string, must start with 'v'"
  type        = string
  default     = "v1.21.1"
}

variable "serving_version" {
  description = "Knative Serving version deployed inside the KnativeServing CR"
  type        = string
  default     = "1.21.1"
}

variable "domain" {
  description = "External domain exposed by Knative Serving"
  type        = string
  default     = "example.com"
}

variable "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  type        = string
}

variable "kubeconfig_context" {
  description = "Kubeconfig context to use (empty string uses the current context)"
  type        = string
}
