
variable "confluent_cloud_api_key" {
  description = "Confluent Cloud API Key (also referred as Cloud API ID)"
  type        = string
}

variable "confluent_cloud_api_secret" {
  description = "Confluent Cloud API Secret"
  type        = string
  sensitive   = true
}

variable "db_source_password" {
  description = "Password for the source database"
  type        = string
  sensitive   = true
}

variable "db_source_host" {
  description = "Host for the source database"
  type        = string
}

variable "db_target_password" {
  description = "Password for the target database"
  type        = string
  sensitive   = true
} 

variable "db_target_host" {
  description = "Host for the target database"
  type        = string
}