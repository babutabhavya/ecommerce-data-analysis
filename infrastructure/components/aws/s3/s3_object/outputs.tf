output "object_arn" {
  value = aws_s3_object.s3_object.arn
}

output "key" {
  value = aws_s3_object.s3_object.key
}
