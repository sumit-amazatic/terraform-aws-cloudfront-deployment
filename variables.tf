variable "name" {
  type        = string
  description = "Name of this deployment."
}

variable "s3_bucket" {
  type        = string
  description = "S3 Bucket name that will be created for this deployment."
}

variable "environment_name" {
  type        = string
  description = "Name of environment."
}

variable "namespace" {
  type        = string
  description = "Determines naming convention of assets. Generally follows DNS naming convention."
}

variable "dns_zone" {
  type        = string
  description = "Name of the DNS zone to use with this deployment."
}

variable "dns_names" {
  type        = list(string)
  description = "DNS names to associate with this deployment"
}

variable "acm_certificate_arn" {
  type        = string
  description = "ARN of the corresponding ACM SSL to use with this deployment."
}

variable "web_acl_id" {
  type        = string
  description = "(Optional) - If you're using AWS WAF to filter CloudFront requests, the Id of the AWS WAF web ACL that is associated with the distribution."
  default     = null
}

variable "is_ipv6_enabled" {
  type        = bool
  description = "(Optional) - Whether the IPv6 is enabled for the distribution."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the AWS resources."
}

variable "private_dns" {
  type        = bool
  description = "If true, this module will create Route53 DNS records in a private zone"
  default     = false
}

variable "whitelisted_headers" {
  type        = list(string)
  description = "List of whitelisted headers for this CloudFront distribution."
  default     = ["Origin"]
}

variable "cors_rule" {
  type = list(object({
    allowed_headers = list(string)
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = list(string)
    max_age_seconds = number
  }))
  description = "CORS rule to apply to s3 bucket"
  default     = []
}

variable "use_external_dns" {
  type        = bool
  description = "If true, this module will not create any Route53 DNS records."
  default     = false
}
