resource "kubernetes_deployment" "webapp" {
  metadata {
    name      = local.webapp_name
    namespace = var.namespace
  }
  spec {
    replicas = var.webapp_replicas
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
          "teacherservices.cloud/node_pool" = "applications"
          "kubernetes.io/os"                = "linux"
        }
        topology_spread_constraint {
          max_skew           = 1
          topology_key       = "topology.kubernetes.io/zone"
          when_unsatisfiable = "DoNotSchedule"
          label_selector {
            match_labels = {
              app = local.webapp_name
            }
          }
        }
        topology_spread_constraint {
          max_skew           = 1
          topology_key       = "kubernetes.io/hostname"
          when_unsatisfiable = "ScheduleAnyway"
          label_selector {
            match_labels = {
              app = local.webapp_name
            }
          }
        }
        container {
          name    = local.webapp_name
          image   = var.app_docker_image
          command = try(slice(local.webapp_startup_command, 0, 1), null)
          args    = try(slice(local.webapp_startup_command, 1, length(local.webapp_startup_command)), null)
          # Check performed to ensure the application is available. If it fails the current pod is killed and a new one created.
          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true

          }
          liveness_probe {
            http_get {
              path = "/check"
              port = 3000
            }

            failure_threshold = 10
            period_seconds    = 1
            timeout_seconds   = 10
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
              cpu    = var.cluster.cpu_min
              memory = var.webapp_memory_max
            }
            limits = {
              cpu    = 1
              memory = var.webapp_memory_max
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

resource "kubernetes_ingress_v1" "webapp-svc" {
  for_each = toset(var.gov_uk_host_names)

  wait_for_load_balancer = true
  metadata {
    name      = each.value
    namespace = var.namespace
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      host = each.value
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
    replicas = var.worker_replicas
    selector {
      match_labels = {
        app = local.worker_name
      }
    }
    strategy {
      type = "Recreate"
    }
    template {
      metadata {
        labels = {
          app = local.worker_name
        }
      }
      spec {
        node_selector = {
          "teacherservices.cloud/node_pool" = "applications"
          "kubernetes.io/os"                = "linux"
        }
        container {
          name    = local.worker_name
          image   = var.app_docker_image
          command = ["bundle"]
          args    = ["exec", "sidekiq", "-c", "5", "-C", "config/sidekiq-main.yml"]
          security_context {
            read_only_root_filesystem  = true
            allow_privilege_escalation = false
          }
          liveness_probe {
            exec {
              command = ["pgrep", "-f", "sidekiq"]
            }
            period_seconds = 10
          }
          startup_probe {
            exec {
              command = ["pgrep", "-f", "sidekiq"]
            }
            initial_delay_seconds = 5
            period_seconds        = 10
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
              cpu    = var.cluster.cpu_min
              memory = var.worker_memory_max
            }
            limits = {
              cpu    = 1
              memory = var.worker_memory_max
            }
          }
        }
      }
    }
  }
  depends_on = [kubernetes_deployment.webapp]
}

resource "kubernetes_deployment" "secondary_worker" {
  metadata {
    name      = local.secondary_worker_name
    namespace = var.namespace
  }
  spec {
    replicas = var.secondary_worker_replicas
    selector {
      match_labels = {
        app = local.secondary_worker_name
      }
    }
    strategy {
      type = "Recreate"
    }
    template {
      metadata {
        labels = {
          app = local.secondary_worker_name
        }
      }
      spec {
        node_selector = {
          "teacherservices.cloud/node_pool" = "applications"
          "kubernetes.io/os"                = "linux"
        }
        container {
          name    = local.secondary_worker_name
          image   = var.app_docker_image
          command = ["bundle"]
          args    = ["exec", "sidekiq", "-c", "5", "-C", "config/sidekiq-secondary.yml"]
          security_context {
            read_only_root_filesystem  = true
            allow_privilege_escalation = false
          }
          liveness_probe {
            exec {
              command = ["pgrep", "-f", "sidekiq"]
            }
            period_seconds = 10
          }
          startup_probe {
            exec {
              command = ["pgrep", "-f", "sidekiq"]
            }
            initial_delay_seconds = 5
            period_seconds        = 10
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
              cpu    = var.cluster.cpu_min
              memory = var.secondary_worker_memory_max
            }
            limits = {
              cpu    = 1
              memory = var.secondary_worker_memory_max
            }
          }
        }
      }
    }
  }
  depends_on = [kubernetes_deployment.webapp]
}

resource "kubernetes_deployment" "clock_worker" {
  metadata {
    name      = local.clock_worker_name
    namespace = var.namespace
  }
  spec {
    replicas = var.clock_worker_replicas
    selector {
      match_labels = {
        app = local.clock_worker_name
      }
    }
    strategy {
      type = "Recreate"
    }
    template {
      metadata {
        labels = {
          app = local.clock_worker_name
        }
      }
      spec {
        node_selector = {
          "teacherservices.cloud/node_pool" = "applications"
          "kubernetes.io/os"                = "linux"
        }
        container {
          name    = local.clock_worker_name
          image   = var.app_docker_image
          command = ["bundle"]
          args    = ["exec", "clockwork", "config/clock.rb"]
          security_context {
            read_only_root_filesystem  = true
            allow_privilege_escalation = false
          }
          liveness_probe {
            exec {
              command = ["pgrep", "-f", "clockwork"]
            }
            period_seconds = 10
          }
          startup_probe {
            exec {
              command = ["pgrep", "-f", "clockwork"]
            }
            initial_delay_seconds = 5
            period_seconds        = 10
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
              cpu    = var.cluster.cpu_min
              memory = var.clock_worker_memory_max
            }
            limits = {
              cpu    = 1
              memory = var.clock_worker_memory_max
            }
          }
        }
      }
    }
  }
  depends_on = [kubernetes_deployment.webapp]
}
