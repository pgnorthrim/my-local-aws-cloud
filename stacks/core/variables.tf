variable "moto_endpoint" {
  description = "Local Moto server URL (my-local-aws-cloud: docker compose up -d)."
  type        = string
  default     = "http://localhost:4566"
}

variable "project" {
  description = "Project tag."
  type        = string
  default     = "core"
}

variable "owner" {
  description = "Owner tag."
  type        = string
  default     = "pgNorthRim"
}
