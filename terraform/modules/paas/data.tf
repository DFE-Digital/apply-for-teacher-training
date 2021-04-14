data "cloudfoundry_org" "org" {
  name = "dfe"
}

data "cloudfoundry_space" "space" {
  name = var.cf_space
  org  = data.cloudfoundry_org.org.id
}

data "cloudfoundry_domain" "london_cloudapps_digital" {
  name = "london.cloudapps.digital"
}

data "cloudfoundry_domain" "apply_service_gov_uk" {
  name = "apply-for-teacher-training.service.gov.uk"
}

data "cloudfoundry_domain" "apply_education_gov_uk" {
  name = "apply-for-teacher-training.education.gov.uk"
}

data "cloudfoundry_service" "postgres" {
  name = "postgres"
}

data "cloudfoundry_service" "redis" {
  name = "redis"
}
