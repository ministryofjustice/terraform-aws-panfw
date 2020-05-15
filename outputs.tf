output "pafw" {
  value = aws_instance.this
}

output "primary_public_ip" {
  value = { for name, fw in aws_instance.this : name => fw.public_ip }
}
