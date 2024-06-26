resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name

  tags = {
    Environment = var.environment
    Name        = var.bucket_name
  }
}

resource "aws_s3_object" "dataset" {
depends_on = [aws_s3_bucket.bucket]
  bucket = aws_s3_bucket.bucket.bucket
  key    = "olist_public_dataset.xlsx"
  source = "${path.module}/files/olist_public_dataset.xlsx"  # Local path to the file to upload
}