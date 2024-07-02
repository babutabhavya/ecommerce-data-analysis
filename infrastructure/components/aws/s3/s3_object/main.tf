resource "aws_s3_object" "s3_object" {
  bucket = var.s3_bucket
  key    = var.key
  source = var.obj_source
}

