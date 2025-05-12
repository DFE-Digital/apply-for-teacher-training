terraform {
  required_providers {
    statuscake = {
      source  = "StatusCakeDev/statuscake"
      version = "2.2.2"
    }
  }
}

resource "statuscake_uptime_check" "alert" {
  for_each = var.alerts

  name           = each.value.website_name
  check_interval = each.value.check_rate
  confirmation   = 2
  trigger_rate   = 0
  regions        = ["london", "dublin"]
  contact_groups = each.value.contact_group

  http_check {
    follow_redirects = true
    timeout          = 40
    request_method   = "HTTP"
    status_codes = [
      "204",
      "205",
      "206",
      "303",
      "400",
      "401",
      "403",
      "404",
      "405",
      "406",
      "408",
      "410",
      "413",
      "444",
      "429",
      "494",
      "495",
      "496",
      "499",
      "500",
      "501",
      "502",
      "503",
      "504",
      "505",
      "506",
      "507",
      "508",
      "509",
      "510",
      "511",
      "521",
      "522",
      "523",
      "524",
      "520",
      "598",
      "599"
    ]
  }

  monitored_resource {
    address = each.value.website_url
  }
}

# Added in as statuscake would report credential error without
resource "time_sleep" "wait_10_seconds" {
  depends_on = [statuscake_uptime_check.alert]

  destroy_duration = "10s"
}
