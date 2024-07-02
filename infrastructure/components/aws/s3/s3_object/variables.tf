variable "key" {
    description = "The key for the resource in the bucket"
    type = string
}

variable "s3_bucket" {
    description = "s3 bucket to insert the object to"
}

variable "obj_source" {
    description = "local path of the source file for the object"
}