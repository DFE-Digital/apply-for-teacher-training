terraform {
  required_providers {
    statuscake = {
      source  = "StatusCakeDev/statuscake"
      version = "1.0.1"
    }
  }
}

provider "statuscake" {
  username = var.username
  apikey   = var.password
}

resource "statuscake_test" "alert" {
  for_each = var.alerts

  website_name   = each.value.website_name
  website_url    = each.value.website_url
  test_type      = each.value.test_type
  check_rate     = each.value.check_rate
  contact_group  = each.value.contact_group
  trigger_rate   = each.value.trigger_rate
  node_locations = each.value.node_locations
  confirmations  = each.value.confirmations
}
