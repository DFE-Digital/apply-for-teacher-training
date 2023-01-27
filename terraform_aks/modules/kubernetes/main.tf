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
          "kubernetes.io/os" : "linux"
        }
        container {
          name    = local.webapp_name
          image   = var.app_docker_image
          command = try(slice(local.webapp_startup_command, 0, 1), null)
          args    = try(slice(local.webapp_startup_command, 1, length(local.webapp_startup_command)), null)
          # Check performed to ensure the application is available. If it fails the current pod is killed and a new one created.
          liveness_probe {
            http_get {
              path = "/check"
              port = 3000
            }

            failure_threshold = 10
            period_seconds    = 1
          }
          # Check performed to ensure the application has started.
          startup_probe {
            http_get {
              path = "/check"
              port = 3000
            }

            failure_threshold = 24
            period_seconds    = 5
          }
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
              cpu    = "100m"
              memory = "256Mi"
            }
            limits = {
              cpu    = "1000m"
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
    name      = local.webapp_name
    namespace = var.namespace
  }
  spec {
    type = "ClusterIP"
    port {
      port        = 80
      target_port = 3000
    }
    selector = {
      app = local.webapp_name
    }
  }
}

resource "kubernetes_config_map" "app_config" {
  metadata {
    name      = "${local.app_config_name}-${local.webapp_env_variables_hash}"
    namespace = var.namespace
  }
  data = local.webapp_env_variables
}

resource "kubernetes_secret" "app_secrets" {
  metadata {
    name      = "${local.app_secrets_name}-${local.app_secrets_hash}"
    namespace = var.namespace
  }
  data = local.app_secrets
}

resource "kubernetes_ingress_v1" "webapp" {
  wait_for_load_balancer = true
  metadata {
    name      = local.webapp_name
    namespace = var.namespace
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      host = local.hostname
      http {
        path {
          backend {
            service {
              name = kubernetes_service.webapp.metadata[0].name
              port {
                number = kubernetes_service.webapp.spec[0].port[0].port
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "main_worker" {
  metadata {
    name      = local.worker_name
    namespace = var.namespace
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = local.worker_name
      }
    }
    template {
      metadata {
        labels = {
          app = local.worker_name
        }
      }
      spec {
        node_selector = {
          "kubernetes.io/os" : "linux"
        }
        container {
          name    = local.worker_name
          image   = var.app_docker_image
          command = ["bundle"]
          args    = ["exec", "sidekiq", "-c", "5", "-C", "config/sidekiq-main.yml"]

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
              cpu    = "100m"
              memory = "256Mi"
            }
            limits = {
              cpu    = "1000m"
              memory = "1Gi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "secondary_worker" {
  metadata {
    name      = local.secondary_worker_name
    namespace = var.namespace
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = local.secondary_worker_name
      }
    }
    template {
      metadata {
        labels = {
          app = local.secondary_worker_name
        }
      }
      spec {
        node_selector = {
          "kubernetes.io/os" : "linux"
        }
        container {
          name    = local.secondary_worker_name
          image   = var.app_docker_image
          command = ["bundle"]
          args    = ["exec", "sidekiq", "-c", "5", "-C", "config/sidekiq-secondary.yml"]

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
              cpu    = "100m"
              memory = "256Mi"
            }
            limits = {
              cpu    = "1000m"
              memory = "1Gi"
            }
          }
        }
      }
    }
  }
}
