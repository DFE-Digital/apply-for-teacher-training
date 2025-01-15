variable "hosted_zone" {
  type    = map(any)
  default = {}
}

variable "multiple_hosted_zones" {
  type    = bool
  default = false
}

# Variables for Azure alerts
variable "enable_alerting" { default = false }
variable "pg_actiongroup_name" { default = null }
variable "pg_actiongroup_rg" { default = null }
variable "latency_threshold" {
  default = 1500
}
variable "percent_5xx_threshold" {
  default = 15
}

variable "alert_window_size" {
  type        = string
  nullable    = false
  default     = "PT15M"
  description = "The period of time that is used to monitor alert activity e.g PT1M, PT5M, PT15M, PT30M, PT1H, PT6H or PT12H"
}
