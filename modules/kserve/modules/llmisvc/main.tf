locals {
  chart_repo = "oci://ghcr.io/kserve/charts"

  # Build kubectl prefix once; stored in null_resource triggers so destroy
  # provisioners can reference it via self.triggers without needing variables.
  kubectl = var.kubeconfig_context != "" ? "kubectl --kubeconfig ${var.kubeconfig_path} --context ${var.kubeconfig_context}" : "kubectl --kubeconfig ${var.kubeconfig_path}"
}

# ---------------------------------------------------------------------------
# Gateway API CRDs
# Upstream does not ship a Helm chart; the canonical install is kubectl apply.
# Source: https://github.com/kubernetes-sigs/gateway-api/releases
# ---------------------------------------------------------------------------
resource "null_resource" "gateway_api_crds" {
  triggers = {
    version = var.gateway_api_version
    kubectl = local.kubectl
  }

  provisioner "local-exec" {
    command = "${self.triggers.kubectl} apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/${self.triggers.version}/standard-install.yaml"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "${self.triggers.kubectl} delete -f https://github.com/kubernetes-sigs/gateway-api/releases/download/${self.triggers.version}/standard-install.yaml --ignore-not-found=true || true"
  }
}

# ---------------------------------------------------------------------------
# LeaderWorkerSet (LWS) Operator
# Required for multi-node LLM inference pods.
# Source: https://github.com/kubernetes-sigs/lws/releases
# ---------------------------------------------------------------------------
resource "null_resource" "lws_operator" {
  triggers = {
    version = var.lws_version
    kubectl = local.kubectl
  }

  provisioner "local-exec" {
    command = "${self.triggers.kubectl} apply --server-side -f https://github.com/kubernetes-sigs/lws/releases/download/${self.triggers.version}/manifests.yaml"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "${self.triggers.kubectl} delete -f https://github.com/kubernetes-sigs/lws/releases/download/${self.triggers.version}/manifests.yaml --ignore-not-found=true || true"
  }
}

# ---------------------------------------------------------------------------
# Envoy Gateway
# Provides the Gateway and HTTPRoute implementations used by LLMInferenceService.
# ---------------------------------------------------------------------------
resource "helm_release" "envoy_gateway" {
  name             = "eg"
  repository       = "oci://docker.io/envoyproxy"
  chart            = "gateway-helm"
  version          = var.envoy_gateway_version
  namespace        = "envoy-gateway-system"
  create_namespace = true
  wait             = true
  timeout          = 300

  depends_on = [null_resource.gateway_api_crds]
}

# ---------------------------------------------------------------------------
# KServe LLMISvc CRDs + resources
# ---------------------------------------------------------------------------
resource "helm_release" "kserve_llmisvc_crd" {
  name             = "kserve-llmisvc-crd"
  repository       = local.chart_repo
  chart            = "kserve-llmisvc-crd"
  version          = var.kserve_version
  namespace        = var.kserve_namespace
  create_namespace = true
  wait             = true
  timeout          = 300

  depends_on = [
    null_resource.gateway_api_crds,
    null_resource.lws_operator,
    helm_release.envoy_gateway,
  ]
}

resource "helm_release" "kserve_llmisvc_resources" {
  name       = "kserve-llmisvc-resources"
  repository = local.chart_repo
  chart      = "kserve-llmisvc-resources"
  version    = var.kserve_version
  namespace  = var.kserve_namespace
  wait       = true
  timeout    = 300

  set = [
    { name = "kserve.version", value = var.kserve_version },
    # kserve-resources (installed first) already created the shared inferenceservice-config ConfigMap.
    # Per determine_shared_resources_helm() in llmisvc-full-install-helm.sh: when kserve-resources is
    # already installed, llmisvc-resources must not recreate the shared resources.
    { name = "kserve.createSharedResources", value = "false" },
  ]

  depends_on = [helm_release.kserve_llmisvc_crd]
}
