output "pafw" {
  value = aws_instance.this
}

output "network_interfaces" {
  value = aws_network_interface.this
}

output "elastic_ips" {
  value = aws_eip.this
}
