/*
This configuration is only for a prometheus app hosted inside the same space as the Apply app.
prometheus-bat-qa -> apply-qa (bat-qa space)
prometheus-bat -> apply-prod and apply-sandbox (bat-prod space)
We don't have prometheus stack deployed in bat-staging and hence the use of count to not deploy the policy in staging.
*/
locals {
  configure_prometheus_network_policy = var.prometheus_app == null ? 0 : 1
}

data "cloudfoundry_app" "apply_web_app" {
  depends_on = [cloudfoundry_app.web_app]
  name_or_id = cloudfoundry_app.web_app.name
  space      = data.cloudfoundry_space.space.id
}

data "cloudfoundry_app" "prometheus_app" {
  count      = local.configure_prometheus_network_policy
  name_or_id = var.prometheus_app
  space      = data.cloudfoundry_space.space.id
}

resource "cloudfoundry_network_policy" "apply_prometheus_policy" {
  depends_on = [data.cloudfoundry_app.apply_web_app]
  count      = local.configure_prometheus_network_policy
  policy {
    source_app      = data.cloudfoundry_app.prometheus_app[0].id
    destination_app = data.cloudfoundry_app.apply_web_app.id
    port            = "8080"
  }
}
