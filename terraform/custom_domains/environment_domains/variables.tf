variable hosted_zone {
  type = map(any)
  default = {}
}

variable "multiple_hosted_zones" {
  type = bool
  default = false
}
