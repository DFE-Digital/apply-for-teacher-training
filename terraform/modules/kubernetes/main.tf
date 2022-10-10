resource "kubernetes_deployment" "webapp" {
  metadata {
    name      = local.webapp_name
    namespace = var.namespace
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = local.webapp_name
      }
    }
    template {
      metadata {
        labels = {
          app = local.webapp_name
        }
      }
      spec {
        node_selector = {
            "kubernetes.io/os": "linux"
        }
        container {
          name  = local.webapp_name
          image = var.app_docker_image
          env_from {
            config_map_ref {
              name = kubernetes_config_map.app_config.metadata.0.name
            }
          }
          env_from {
            secret_ref {
              name = kubernetes_secret.app_secrets.metadata.0.name
            }
          }
          resources {
            requests = {
              cpu = "100m"
              memory = "256Mi"
            }
            limits = {
              cpu = "1000m"
              memory = "1Gi"
            }
          }
          port {
            container_port = 3000
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "webapp" {
  metadata {
    name = local.webapp_name
    namespace = var.namespace
  }
  spec {
    type = "LoadBalancer"
    port {
      port = 80
      target_port = 3000
    }
    selector = {
      app = local.webapp_name
    }
  }
}

resource kubernetes_config_map app_config {
  metadata {
    name      = local.app_config_name
    namespace = var.namespace
  }
  data = local.web_app_env_variables
}

resource kubernetes_secret app_secrets {
  metadata {
    name      = local.app_secrets_name
    namespace = var.namespace
  }
  data = local.app_secrets
}
