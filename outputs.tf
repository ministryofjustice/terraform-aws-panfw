output "mgmt_ip_address" {
  description = "VM-Series management IP address. If `create_public_ip` is `true` or `eip_allocation_id` is used, it is a public IP address, otherwise a private IP address."
  value       = can(aws_instance.this.public_ip) ? aws_instance.this.public_ip : aws_instance.this.private_ip

}

output "interfaces" {
  description = "List of VM-Series network interfaces. The elements of the list are `aws_network_interface` objects. The order is the same as `interfaces` input."
  value       = aws_network_interface.this
}
