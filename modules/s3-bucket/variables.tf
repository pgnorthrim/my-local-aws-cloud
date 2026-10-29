variable "name" {
  description = "Bucket name."
  type        = string
}

variable "data_dir" {
  description = "Optional folder to load into the bucket: <data_dir>/<prefix>/<file> -> s3://<name>/<prefix>/<file>. Dotfiles are skipped."
  type        = string
  default     = null
}

variable "versioning" {
  description = "Turn on object versioning."
  type        = bool
  default     = false
}

variable "force_destroy" {
  description = "Allow destroying the bucket while it still has objects. Fine locally; think twice on real AWS."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Extra tags for the bucket (provider default_tags still apply)."
  type        = map(string)
  default     = {}
}
