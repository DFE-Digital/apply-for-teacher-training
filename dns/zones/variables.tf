
variable "azure_credentials" { default = null }

variable "hosted_zone" {
  type    = map(any)
  default = {}
}

locals {
  azure_credentials = try(jsondecode(var.azure_credentials), null)
  tags = {
    "Environment" = "Prod"
    "Portfolio"   = "Early Years and Schools Group"
    "Product"     = "Find postgraduate teacher training"
    "Service"     = "Teacher services"
  }
}
