//// variables.tf

variable "name_prefix" {
  description = "Prefix used for naming VCF CLI resources"
  type        = string
  default     = "vcftf-go"
}

variable "namespace" {
  description = "The Kubernetes namespace to deploy resources into"
  type        = string
  default     = "greg01-b2y9g"
}