variable "secret_name" {
  description = "Name of the secret"
  type        = string
}

variable "description" {
  description = "Description of the secret"
  type        = string
  default     = "Managed by Terraform"
}

variable "secret_string" {
  description = "Secret string to store (JSON format)"
  type        = string
  sensitive   = true
}

variable "recovery_window_in_days" {
  description = "Number of days to retain the secret before deletion (0-30). Set to 0 for immediate deletion."
  type        = number
  default     = 30
}

variable "force_delete" {
  description = "Force deletion without recovery window. Use with caution!"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to the secret"
  type        = map(string)
  default     = {}
}
