locals {
  pg_password = var.pg_password != "" ? var.pg_password : random_password.pg[0].result
  pg_host     = "coder-db-postgresql.${var.namespace}.svc.cluster.local"
  pg_url      = "postgresql://coder:${local.pg_password}@${local.pg_host}:5432/coder?sslmode=disable"

}

resource "random_password" "pg" {
  count   = var.pg_password == "" ? 1 : 0
  length  = 24
  special = false
}

resource "kubernetes_namespace_v1" "coder" {
  metadata {
    name = var.namespace
  }
}

# ── PostgreSQL ────────────────────────────────────────────────────────────────

resource "helm_release" "postgresql" {
  name       = "coder-db"
  repository = "oci://registry-1.docker.io/bitnamicharts"
  chart      = "postgresql"
  version    = var.pg_chart_version != "" ? var.pg_chart_version : null
  namespace  = kubernetes_namespace_v1.coder.metadata[0].name
  wait       = true
  timeout    = 300

  set {
    name  = "auth.username"
    value = "coder"
  }

  set_sensitive {
    name  = "auth.password"
    value = local.pg_password
  }

  set {
    name  = "auth.database"
    value = "coder"
  }

  # no persistent volume needed for a local dev cluster
  set {
    name  = "primary.persistence.enabled"
    value = "false"
  }
}

resource "kubernetes_secret_v1" "coder_db_url" {
  metadata {
    name      = "coder-db-url"
    namespace = kubernetes_namespace_v1.coder.metadata[0].name
  }

  data = {
    url = local.pg_url
  }

  depends_on = [helm_release.postgresql]
}

# ── Coder ─────────────────────────────────────────────────────────────────────

resource "helm_release" "coder" {
  name             = "coder"
  repository       = "https://helm.coder.com/v2"
  chart            = "coder"
  version          = var.coder_chart_version
  namespace        = kubernetes_namespace_v1.coder.metadata[0].name
  create_namespace = false
  wait             = true
  timeout          = 300

  values = [
    yamlencode({
      coder = {
        env = concat(
          [
            {
              name = "CODER_PG_CONNECTION_URL"
              valueFrom = {
                secretKeyRef = {
                  name = kubernetes_secret_v1.coder_db_url.metadata[0].name
                  key  = "url"
                }
              }
            },
            {
              name  = "CODER_ACCESS_URL"
              value = var.access_url
            },
            {
              name  = "PATH"
              value = "/opt/tofu:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
            },
          ],
        )
        service = {
          type = "ClusterIP"
        }
        initContainers = [
          {
            name    = "install-tofu"
            image   = "busybox:1.36"
            command = [
              "sh", "-c",
              "set -e && wget -qO /tmp/tofu.tar.gz https://github.com/opentofu/opentofu/releases/download/v1.9.1/tofu_1.9.1_linux_amd64.tar.gz && tar -xzf /tmp/tofu.tar.gz -C /tmp && mv /tmp/tofu /opt/tofu/terraform && chmod +x /opt/tofu/terraform"
            ]
            volumeMounts = [
              {
                name      = "tofu-bin"
                mountPath = "/opt/tofu"
              }
            ]
          }
        ]
        volumes = [
          {
            name     = "tofu-bin"
            emptyDir = {}
          }
        ]
        volumeMounts = [
          {
            name      = "tofu-bin"
            mountPath = "/opt/tofu"
          }
        ]
      }
    })
  ]

  depends_on = [kubernetes_secret_v1.coder_db_url]
}

# ── Workspace namespace + RBAC ────────────────────────────────────────────────

resource "kubernetes_namespace_v1" "workspaces" {
  metadata {
    name = var.workspaces_namespace
  }
}

# Allow Coder's service account to manage pods/services in the workspaces namespace
resource "kubernetes_role_v1" "coder_workspaces" {
  metadata {
    name      = "coder-workspaces"
    namespace = kubernetes_namespace_v1.workspaces.metadata[0].name
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "pods/log", "pods/exec", "services", "persistentvolumeclaims"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
}

resource "kubernetes_role_binding_v1" "coder_workspaces" {
  metadata {
    name      = "coder-workspaces"
    namespace = kubernetes_namespace_v1.workspaces.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.coder_workspaces.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = "coder"
    namespace = kubernetes_namespace_v1.coder.metadata[0].name
  }
}

# ── NodePort service so the kind host-port mapping reaches Coder ──────────────
resource "kubernetes_service_v1" "coder_nodeport" {
  metadata {
    name      = "coder-nodeport"
    namespace = kubernetes_namespace_v1.coder.metadata[0].name
  }

  spec {
    type = "NodePort"

    selector = {
      "app.kubernetes.io/name"     = "coder"
      "app.kubernetes.io/instance" = helm_release.coder.name
    }

    port {
      name        = "http"
      port        = 80
      target_port = 8080
      node_port   = var.node_port
      protocol    = "TCP"
    }
  }

  depends_on = [helm_release.coder]
}
