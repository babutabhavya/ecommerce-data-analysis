variable "region" {
  description = "The AWS region to deploy in"
  default     = "us-east-1"
}

variable "instance_type" {
  description = "The instance type to use"
  default     = "t2.micro"
}

variable "key_name" {
  description = "The name of the SSH key pair"
  default     = "my_new_ec2_key"
}

variable "environment" {
  description = "The environment for the instance (e.g., dev, prod)"
  type        = string
}