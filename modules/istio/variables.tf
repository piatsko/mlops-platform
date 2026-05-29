variable "namespace" {
  type    = string
  default = "istio-system"
}

variable "chart_version" {
  type    = string
  default = "1.27.1"
}

variable "istiod_set" {
  description = "Additional Helm set values for istiod"
  type        = map(string)
  default     = {}
}

variable "gateway_set" {
  description = "Additional Helm set values for istio-ingressgateway"
  type        = map(string)
  default     = {}
}
