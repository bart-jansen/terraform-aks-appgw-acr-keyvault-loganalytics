variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "app_name" {
  type = string
}

variable "log_retention_days" {
  type        = string
  description = "Time in days to keep the logs available in Azure Monitor"
  default     = 30
}