output "external_urls" {
  value = flatten([
    for zone_name, zone_values in var.hosted_zone : [
      for domain in zone_values["domains"] : (domain == "apex" ?
        "https://${zone_name}" :
        "https://${domain}.${zone_name}"
      )
    ]
  ])
}
