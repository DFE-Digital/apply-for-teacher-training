provider "google" {
  project = "rugged-abacus-218110"
}

module "airbyte" {
  source = "./vendor/modules/aks//aks/airbyte"

  count = var.airbyte_enabled ? 1 : 0

  environment           = local.app_name_suffix
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  service_name          = var.service_name
  docker_image          = var.docker_image
  postgres_version      = 16
  #postgres_version      = var.postgres_version
  postgres_url          = module.postgres.url

  host_name          = module.postgres.host
  database_name      = module.postgres.name
  workspace_id       = var.airbyte_enabled ? module.secrets.map.AIRBYTE-WORKSPACE-ID : null
  client_id          = var.airbyte_enabled ? module.secrets.map.AIRBYTE-CLIENT-ID : null
  client_secret      = var.airbyte_enabled ? module.secrets.map.AIRBYTE-CLIENT-SECRET : null
  repl_password      = var.airbyte_enabled ? module.secrets.map.AIRBYTE-REPLICATION-PASSWORD : null
  server_url         = "https://airbyte-${var.namespace}.${module.cluster_data.ingress_domain}"
  connection_status  = var.connection_status
  connection_streams = local.connection_streams

  cluster           = var.cluster
  namespace         = var.namespace
  gcp_taxonomy_id   = "69524444121704657"
  gcp_policy_tag_id = "6523652585511281766"
  gcp_keyring       = "bat-key-ring"
  gcp_key           = "bat-key"

  config_map_ref = module.application_configuration.kubernetes_config_map_name
  secret_ref     = module.application_configuration.kubernetes_secret_name
  cpu            = module.cluster_data.configuration_map.cpu_min

  use_azure = var.deploy_azure_backing_services
  gcp_bq_sa = var.airbyte_enabled ? module.secrets.map.AIRBYTE-BQ-SA : null
}

## Airbyte module variables

variable "airbyte_enabled" { default = false }

variable "connection_status" {
  type = string
  default = "inactive"
  description = "Connectin status, either active or inactive"
}

locals {
  connection_streams = var.airbyte_enabled ? file("workspace_variables/airbyte_stream_config.json") : null
  gcp_dataset_name   = replace("${var.service_short}_airbyte_${local.app_name_suffix}", "-", "_")
}
