variable "prefix" {
  default = "raven"
}

variable "stage" {
  default = "testing"
}

variable "script_path" {
  default = "./scripts/initialize_setup.sh"
}

variable "username" {
  description = "The name of the user that will be used to remote exec the script"
  default     = "toor"
}

variable "public_key" {
  description = "The path to the private key used to connect to the instance"
  default     = "~/.ssh/id_rsa.pub"
}