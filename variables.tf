variable "snowflake_account" {
  description = "The Snowflake account"
  type        = string
}

variable "snowflake_user" {
  description = "The Snowflake user"
  type        = string
}

variable "snowflake_password" {
  description = "The Snowflake password"
  type        = string
  sensitive   = true
}

variable "snowflake_database" {
  description = "The Snowflake database"
  type        = string
}

variable "snowflake_role" {
  description = "The Snowflake role"
  type        = string
}

variable "snowflake_warehouse" {
  description = "The Snowflake warehouse"
  type        = string
}
