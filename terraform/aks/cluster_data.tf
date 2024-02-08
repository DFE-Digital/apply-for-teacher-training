module "cluster_data" {
  source = "./vendor/modules/aks//aks/cluster_data"
  name   = var.cluster
}
