variable "s3_bucket_name" {
  description = "Name of the S3 bucket to crawl"
}

variable "database_name" {
  description = "Name of the Glue database"
}

variable "bucket_folder" {
    description = "Name of the s3 bucket folder to crawl"

}

variable "name" {
    description = "prefix name of the crawler"

}

variable "service_role_name" {
    description = "Service role name"

}