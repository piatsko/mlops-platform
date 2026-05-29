locals {
  # Points to the upstream template this manifest was derived from.
  # Source: https://github.com/kserve/kserve/blob/master/hack/setup/infra/knative/templates/knative-serving-istio.yaml
  # Captured at kserve commit: 950ba64
  # SHA256 of source template: 85723020636abbebae48249f5d202cdf508910fb465b5d080b25611fe04ba066
  #
  # When bumping knative_operator_version or knative_serving_version:
  #   1. Check the upstream template for changes:
  #      git diff <old-commit> <new-commit> -- hack/setup/infra/knative/templates/knative-serving-istio.yaml
  #   2. Update the manifest below accordingly.
  #   3. Update upstream_template_sha256 and the captured commit above.
  upstream_template_sha256 = "85723020636abbebae48249f5d202cdf508910fb465b5d080b25611fe04ba066"

  operator_chart_url = "https://github.com/knative/operator/releases/download/knative-${var.operator_version}/knative-operator-${var.operator_version}.tgz"

  kubectl = var.kubeconfig_context != "" ? "kubectl --kubeconfig ${var.kubeconfig_path} --context ${var.kubeconfig_context}" : "kubectl --kubeconfig ${var.kubeconfig_path}"

  knative_serving_manifest = jsonencode({
    apiVersion = "operator.knative.dev/v1beta1"
    kind       = "KnativeServing"
    metadata = {
      name      = "knative-serving"
      namespace = var.serving_namespace
    }
    spec = {
      version = var.serving_version
      config = {
        deployment = {
          "registries-skipping-tag-resolving" = "nvcr.io,index.docker.io"
        }
        domain = { (var.domain) = "" }
      }
      workloads = [
        { name = "controller", resources = [{ container = "controller", requests = { cpu = "5m", memory = "32Mi" }, limits = { cpu = "100m", memory = "128Mi" } }] },
        { name = "activator", resources = [{ container = "activator", requests = { cpu = "5m", memory = "32Mi" }, limits = { cpu = "100m", memory = "128Mi" } }] },
        { name = "autoscaler", resources = [{ container = "autoscaler", requests = { cpu = "5m", memory = "32Mi" }, limits = { cpu = "100m", memory = "128Mi" } }] },
        { name = "domain-mapping", resources = [{ container = "domain-mapping", requests = { cpu = "5m", memory = "32Mi" }, limits = { cpu = "100m", memory = "128Mi" } }] },
        { name = "webhook", resources = [{ container = "webhook", requests = { cpu = "5m", memory = "32Mi" }, limits = { cpu = "100m", memory = "128Mi" } }] },
        { name = "domainmapping-webhook", resources = [{ container = "domainmapping-webhook", requests = { cpu = "5m", memory = "32Mi" }, limits = { cpu = "100m", memory = "128Mi" } }] },
        { name = "net-istio-controller", resources = [{ container = "controller", requests = { cpu = "5m", memory = "32Mi" }, limits = { cpu = "100m", memory = "128Mi" } }] },
        { name = "net-istio-webhook", resources = [{ container = "webhook", requests = { cpu = "5m", memory = "32Mi" }, limits = { cpu = "100m", memory = "128Mi" } }] },
      ]
    }
  })
}

# Fail at plan time if the operator version has been bumped without reviewing the manifest.
# To suppress this when you have reviewed and confirmed no relevant changes, update
# reviewed_at_operator_version below to match var.operator_version.
locals {
  reviewed_at_operator_version = "v1.21.1"
}

check "knative_manifest_review" {
  assert {
    condition     = local.reviewed_at_operator_version == var.operator_version
    error_message = "knative_operator_version was changed to ${var.operator_version} but the KnativeServing manifest in modules/knative/main.tf has only been reviewed against ${local.reviewed_at_operator_version}. Review the upstream template diff and update reviewed_at_operator_version."
  }
}

resource "helm_release" "knative_operator" {
  name             = "knative-operator"
  chart            = local.operator_chart_url
  namespace        = var.operator_namespace
  create_namespace = true
  wait             = true
  timeout          = 300
}

resource "kubernetes_namespace_v1" "knative_serving" {
  metadata {
    name = var.serving_namespace
  }

  depends_on = [helm_release.knative_operator]
}

resource "null_resource" "knative_serving" {
  triggers = {
    manifest = local.knative_serving_manifest
    kubectl  = local.kubectl
  }

  provisioner "local-exec" {
    command = "echo '${self.triggers.manifest}' | ${self.triggers.kubectl} apply -f -"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "echo '${self.triggers.manifest}' | ${self.triggers.kubectl} delete -f - --ignore-not-found=true || true"
  }

  depends_on = [kubernetes_namespace_v1.knative_serving]
}
