variable "region" {
  description = "The AWS region to deploy in"
  default     = "us-east-1"
}

variable "key_name" {
  description = "The name of the SSH key pair"
  default     = "my_new_ec2_key"
}

variable "master_instance_type" {
  description = "The instance type for the EMR master node"
  default     = "m1.medium"
}

variable "core_instance_type" {
  description = "The instance type for the EMR core nodes"
  default     = "m1.medium"
}

variable "core_instance_count" {
  description = "The number of core instances in the EMR cluster"
  default     = 2
}

variable "emr_instance_profile" {
  description = "The IAM instance profile for EMR"
  default     = "EMR_EC2_DefaultRole"
}

variable "environment" {
  description = "The environment for the EMR cluster (e.g., dev, prod)"
  type        = string
}