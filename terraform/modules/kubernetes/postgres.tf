resource "kubernetes_deployment" "postgres" {
  metadata {
    name      = local.postgres_service_name
    namespace = var.namespace
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = local.postgres_service_name
      }
    }
    template {
      metadata {
        labels = {
          app = local.postgres_service_name
        }
      }
      spec {
        node_selector = {
            "kubernetes.io/os": "linux"
        }
        container {
          name  = local.postgres_service_name
          image = "postgres:11-alpine"
          resources {
            requests = {
              cpu = "100m"
              memory = "256Mi"
            }
            limits = {
              cpu = "250m"
              memory = "1Gi"
            }
          }
          port {
            container_port = 5432
          }
          env {
            name = "POSTGRES_PASSWORD"
            value = "password"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "postgres" {
  metadata {
    name = local.postgres_service_name
    namespace = var.namespace
  }
  spec {
    port {
      port = 5432
    }
    selector = {
      app = local.postgres_service_name
    }
  }
}
