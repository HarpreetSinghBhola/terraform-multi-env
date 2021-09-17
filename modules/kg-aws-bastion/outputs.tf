output "private_key" {
  sensitive   = true
  description = "Content of the generated private key"
  value       = join("", tls_private_key.default.*.private_key_pem)
}

output "key_name" {
  value       = aws_key_pair.generated[0].key_name
  description = "Name of SSH key"
}

output "private_ip" {
  description = "Private IP of instance"
  value       = join("", aws_instance.default.*.private_ip)
}
output "private_dns" {
  description = "Private DNS of instance"
  value       = join("", aws_instance.default.*.private_dns)
}
output "id" {
  description = "Disambiguated ID of the instance"
  value       = join("", aws_instance.default.*.id)
}
output "arn" {
  description = "ARN of the instance"
  value       = join("", aws_instance.default.*.arn)
}

output "ssh_key_pair" {
  description = "Name of the SSH key pair provisioned on the instance"
  value       = "${var.ec2_name}-key"
}