variable "cluster_name" {
  type        = string
  description = "Name of the kind cluster."
  default     = "mtb-mirror"
}

variable "node_image" {
  type        = string
  description = "kind node Docker image. See https://github.com/kubernetes-sigs/kind/releases for available tags."
  default     = "kindest/node:v1.31.0"
}

variable "worker_count" {
  type        = number
  description = "Number of worker nodes."
  default     = 2
}

variable "extra_port_mappings" {
  type = list(object({
    container_port = number
    host_port      = number
    protocol       = optional(string, "TCP")
  }))
  description = "Extra ports to expose on the control-plane node (e.g. for NodePort or Ingress)."
  default     = []
}

variable "cert_manager_version" {
  description = "cert-manager Helm chart version"
  type        = string
  default     = "v1.17.0"
}

variable "cert_manager_namespace" {
  type    = string
  default = "cert-manager"
}

variable "istio_version" {
  description = "Istio Helm chart version"
  type        = string
  default     = "1.27.1"
}

variable "istio_namespace" {
  type    = string
  default = "istio-system"
}

variable "istiod_set" {
  description = "Additional Helm values for istiod"
  type        = map(string)
  default     = {}
}

variable "istio_gateway_set" {
  description = "Additional Helm values for istio-ingressgateway"
  type        = map(string)
  default     = {}
}

variable "knative_domain" {
  type        = string
  description = "External domain for Knative Serving (e.g. inference.yourcompany.com)."
  default     = "example.com"
}

variable "enable_llmisvc" {
  type        = bool
  description = "Deploy LLMInferenceService stack (Gateway API CRDs, LWS, Envoy Gateway, LLMISvc controller)."
  default     = false
}