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
  default     = 3
}

variable "emr_instance_profile" {
  description = "The IAM instance profile for EMR"
  default     = "EMR_EC2_DefaultRole"
}

variable "environment" {
  description = "The environment for the EMR cluster (e.g., dev, prod)"
  type        = string
}

variable "logs_uri" {
  description = "The logs url for the EMR cluster"
}

variable "pyspark_app_s3_path" {
  description = "The s3 location of the pyspark app"

}

variable "emr_service_role" {
  description = "EMR Service role"
  type        = string
}

variable "emr_ec2_service_role" {
  description = "EMR Ec2 Service role"
  type        = string
}
