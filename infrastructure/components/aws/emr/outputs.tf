
output "emr_master_public_dns" {
  description = "The public DNS of the EMR master node"
  value       = aws_emr_cluster.emr_cluster.master_public_dns
}