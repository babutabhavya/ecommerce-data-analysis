output "instance_ip" {
  description = "The public IP of the instance"
  value       = aws_instance.web.public_ip
}

output "private_key_path" {
  description = "The path to the private key"
  value       = local_file.private_key.filename
}