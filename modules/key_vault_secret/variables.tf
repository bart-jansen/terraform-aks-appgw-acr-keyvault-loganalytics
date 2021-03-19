variable "name" {
  type        = string
  description = "Name of secret key"
}

variable "value" {
  type        = string
  description = "Value of the secret key in key vault"
  sensitive   = true
}

variable "key_vault_id" {
  type        = string
  description = "Key key vault to add this secret to"
}