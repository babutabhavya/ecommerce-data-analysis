
output "private_key_name" {
  description = "The private key name"
  value       = aws_key_pair.deployer.key_name
}
