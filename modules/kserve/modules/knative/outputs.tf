output "operator_namespace" {
  value = helm_release.knative_operator.namespace
}

output "serving_namespace" {
  value = kubernetes_namespace_v1.knative_serving.metadata[0].name
}
