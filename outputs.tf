output "pafw" {
  value = aws_instance.this
}

output "primary_public_ip" {
  value = { for name, fw in aws_instance.this : name => lookup(fw, "public_ip", "") }
}

output "network_interfaces" {
  value = aws_network_interface.this
}

output "elastic_ips" {
  # value = { for e in matchkeys(values(aws_eip.this), keys(aws_eip.this), keys(aws_network_interface_attachment.this)) : e.tags.FW_Name => e }
  value = aws_eip.this
}
