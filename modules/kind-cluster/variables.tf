variable "cluster_name" {
  type        = string
  description = "Name of the kind cluster."
}

variable "node_image" {
  type        = string
  description = "kind node Docker image (must match the desired Kubernetes version)."
  default     = "kindest/node:v1.31.0"
}

variable "worker_count" {
  type        = number
  description = "Number of worker nodes."
  default     = 2
}

variable "pod_subnet" {
  type        = string
  description = "CIDR block for pod networking."
  default     = "10.244.0.0/16"
}

variable "service_subnet" {
  type        = string
  description = "CIDR block for service networking."
  default     = "10.96.0.0/12"
}

variable "extra_port_mappings" {
  type = list(object({
    container_port = number
    host_port      = number
    protocol       = optional(string, "TCP")
  }))
  description = "Extra port mappings to expose on the control-plane node."
  default     = []
}
