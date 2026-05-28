module "cluster" {
  source = "./kind-cluster"

  cluster_name = var.cluster_name
  node_image   = var.node_image
  worker_count = var.worker_count

  extra_port_mappings = concat(
    var.extra_port_mappings,
    [
      { container_port = 30080, host_port = 8080, protocol = "TCP" }, # Coder
    ]
  )
}

module "coder" {
  source = "./coder"

  namespace  = "coder"
  access_url = "http://localhost:8080"

  depends_on = [module.cluster]
}
