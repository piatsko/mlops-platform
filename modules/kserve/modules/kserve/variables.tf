variable "namespace" {
  type    = string
  default = "kserve"
}

variable "chart_version" {
  type    = string
  default = "v0.19.0-rc0"
}

variable "install_runtimes" {
  description = "Install ClusterServingRuntimes via kserve-runtime-configs chart (sets kserve.servingruntime.enabled)"
  type        = bool
  default     = true
}
