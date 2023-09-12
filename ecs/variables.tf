########################################
# Variables
########################################
variable "region" {
  type = string
}

variable "profile_name" {
  type = string
}

variable "username" {
  type      = string
  default   = "admin"
  sensitive = true
}

variable "password" {
  type      = string
  sensitive = true
}