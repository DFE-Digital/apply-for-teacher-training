resource "kubernetes_pod_disruption_budget_v1" "pdb" {
  count = var.pdb_min_available != null ? 1 : 0

  metadata {
    name      = "${local.webapp_name}-pdb"
    namespace = var.namespace
  }
  spec {
    min_available = var.pdb_min_available
    selector {
      match_labels = {
        app = local.webapp_name
      }
    }
  }
}
