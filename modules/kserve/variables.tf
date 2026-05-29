variable "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "kubeconfig_context" {
  description = "Kubeconfig context to use (empty string uses the current context)"
  type        = string
  default     = ""
}

# Versions — defaults match kserve-deps.env
variable "knative_operator_version" {
  description = "Knative Operator version (must start with 'v')"
  type        = string
  default     = "v1.21.1"
}

variable "knative_serving_version" {
  description = "Knative Serving version deployed by the operator CR"
  type        = string
  default     = "1.21.1"
}

variable "kserve_version" {
  description = "KServe Helm chart version"
  type        = string
  default     = "v0.19.0-rc0"
}

# Namespace overrides
variable "knative_operator_namespace" {
  type    = string
  default = "knative-operator"
}

variable "knative_serving_namespace" {
  type    = string
  default = "knative-serving"
}

variable "kserve_namespace" {
  type    = string
  default = "kserve"
}

# Knative domain
variable "knative_domain" {
  description = "External domain used by Knative Serving"
  type        = string
  default     = "example.com"
}

# KServe options
variable "kserve_install_runtimes" {
  description = "Install ClusterServingRuntimes via kserve-runtime-configs chart"
  type        = bool
  default     = true
}

# LLMISvc
variable "enable_llmisvc" {
  description = "Deploy LLM InferenceService controller and its dependencies (Gateway API, LWS, Envoy Gateway)"
  type        = bool
  default     = false
}

variable "gateway_api_version" {
  description = "Gateway API CRDs version"
  type        = string
  default     = "v1.4.1"
}

variable "lws_version" {
  description = "LeaderWorkerSet operator version"
  type        = string
  default     = "v0.8.0"
}

variable "envoy_gateway_version" {
  description = "Envoy Gateway Helm chart version"
  type        = string
  default     = "v1.7.0"
}
