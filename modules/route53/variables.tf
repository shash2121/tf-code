variable "domain_name" {
  description = "The domain name for the hosted zone"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "VPC ID for private hosted zone (leave empty for public)"
  type        = string
  default     = ""
}

# CNAME Record
variable "create_cname_record" {
  description = "Whether to create a CNAME record"
  type        = bool
  default     = false
}

variable "cname_record_name" {
  description = "Name for the CNAME record (e.g., www, app, api)"
  type        = string
  default     = "www"
}

variable "cname_target" {
  description = "Target for the CNAME record"
  type        = string
  default     = ""
}

variable "cname_ttl" {
  description = "TTL for the CNAME record"
  type        = number
  default     = 300
}
