variable "kserve_namespace" {
  type    = string
  default = "kserve"
}

variable "kserve_version" {
  type    = string
  default = "v0.19.0-rc0"
}

variable "gateway_api_version" {
  description = "Gateway API CRDs version (kubernetes-sigs/gateway-api)"
  type        = string
  default     = "v1.4.1"
}

variable "lws_version" {
  description = "LeaderWorkerSet operator version (kubernetes-sigs/lws)"
  type        = string
  default     = "v0.8.0"
}

variable "envoy_gateway_version" {
  description = "Envoy Gateway Helm chart version"
  type        = string
  default     = "v1.7.0"
}

variable "kubeconfig_path" {
  description = "Path to kubeconfig, forwarded to kubectl for raw-manifest installs"
  type        = string
  default     = "~/.kube/config"
}

variable "kubeconfig_context" {
  description = "Kubeconfig context for kubectl commands (empty = current context)"
  type        = string
  default     = ""
}
