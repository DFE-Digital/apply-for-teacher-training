resource "kubernetes_deployment" "postgres" {
  count = var.deploy_azure_backing_services ? 0 : 1

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
          "kubernetes.io/os" : "linux"
        }
        container {
          name  = local.postgres_service_name
          image = "postgres:14-alpine"
          resources {
            requests = {
              cpu    = var.cluster.cpu_min
              memory = "256Mi"
            }
            limits = {
              cpu    = 1
              memory = "1Gi"
            }
          }
          port {
            container_port = 5432
          }
          env {
            name  = "POSTGRES_PASSWORD"
            value = var.postgres_admin_password
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "postgres" {
  count = var.deploy_azure_backing_services ? 0 : 1

  metadata {
    name      = local.postgres_service_name
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
