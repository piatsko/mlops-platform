output "namespace" {
  value = helm_release.kserve_resources.namespace
}

output "status" {
  value = helm_release.kserve_resources.status
}
