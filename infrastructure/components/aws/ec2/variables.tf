variable "instance_type" {
  description = "The instance type to use"
  default     = "t2.micro"
}

variable "environment" {
  description = "The environment for the instance (e.g., dev, prod)"
  type        = string
}

variable "private_key_name" {
  description = "private key name"

}
