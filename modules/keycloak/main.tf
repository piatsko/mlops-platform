resource "kubernetes_namespace_v1" "keycloak" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_deployment_v1" "keycloak" {
  metadata {
    name      = "keycloak"
    namespace = kubernetes_namespace_v1.keycloak.metadata[0].name
    labels    = { "app" = "keycloak" }
  }

  spec {
    replicas = 1

    selector {
      match_labels = { "app" = "keycloak" }
    }

    template {
      metadata {
        labels = { "app" = "keycloak" }
      }

      spec {
        container {
          name    = "keycloak"
          image = "quay.io/keycloak/keycloak:${var.keycloak_version}"
          # start-dev: embedded H2, HTTP enabled, no TLS — suitable for local dev
          args  = ["start-dev"]

          env {
            name  = "KEYCLOAK_ADMIN"
            value = "admin"
          }
          env {
            name  = "KEYCLOAK_ADMIN_PASSWORD"
            value = var.admin_password
          }
          # Pin the issuer URL so tokens carry a consistent host regardless of
          # whether the request came from the browser or from inside the cluster.
          env {
            name  = "KC_HOSTNAME_URL"
            value = var.external_url
          }
          env {
            name  = "KC_HOSTNAME_ADMIN_URL"
            value = var.external_url
          }
          env {
            name  = "KC_PROXY_HEADERS"
            value = "xforwarded"
          }

          port {
            container_port = 8080
            protocol       = "TCP"
          }

          readiness_probe {
            http_get {
              path = "/realms/master"
              port = 8080
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            failure_threshold     = 6
          }

          resources {
            requests = {
              cpu    = "250m"
              memory = "512Mi"
            }
            limits = {
              cpu    = "1"
              memory = "1Gi"
            }
          }
        }
      }
    }
  }

  timeouts {
    create = "10m"
  }
}

resource "kubernetes_service_v1" "keycloak" {
  metadata {
    name      = "keycloak"
    namespace = kubernetes_namespace_v1.keycloak.metadata[0].name
  }

  spec {
    type     = "ClusterIP"
    selector = { "app" = "keycloak" }

    # Port matches the kind host-port binding (8081) so the same URL works
    # from both inside the cluster and from the Mac browser (via /etc/hosts).
    port {
      name        = "http"
      port        = 8081
      target_port = 8080
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_service_v1" "keycloak_nodeport" {
  metadata {
    name      = "keycloak-nodeport"
    namespace = kubernetes_namespace_v1.keycloak.metadata[0].name
  }

  spec {
    type     = "NodePort"
    selector = { "app" = "keycloak" }

    port {
      name        = "http"
      port        = 80
      target_port = 8080
      node_port   = var.node_port
      protocol    = "TCP"
    }
  }
}
