resource "kubernetes_deployment" "redis" {
  metadata {
    name      = local.redis_service_name
    namespace = var.namespace
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = local.redis_service_name
      }
    }
    template {
      metadata {
        labels = {
          app = local.redis_service_name
        }
      }
      spec {
        node_selector = {
          "kubernetes.io/os" : "linux"
        }
        container {
          name  = local.redis_service_name
          image = "redis:5-alpine"
          resources {
            requests = {
              cpu    = "100m"
              memory = "256Mi"
            }
            limits = {
              cpu    = "250m"
              memory = "1Gi"
            }
          }
          port {
            container_port = 6379
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "redis" {
  metadata {
    name      = local.redis_service_name
    namespace = var.namespace
  }
  spec {
    port {
      port = 6379
    }
    selector = {
      app = local.redis_service_name
    }
  }
}
