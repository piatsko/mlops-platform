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
