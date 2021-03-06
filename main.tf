data "aws_ami" "this" {
  count       = var.custom_ami_id == null ? 1 : 0
  most_recent = true

  filter {
    name   = "name"
    values = ["PA-VM-AWS-${var.panos_version}*"]
  }

  filter {
    name   = "product-code"
    values = [var.fw_product_map[var.fw_product]]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["aws-marketplace"]
}

resource "aws_network_interface" "this" {
  for_each = { for k, v in var.interfaces : k => v }

  subnet_id         = each.value.subnet_id
  private_ips       = try([each.value.private_ip_address], null)
  source_dest_check = try(each.value.source_dest_check, false)
  security_groups   = try(each.value.security_groups, null)
  description       = try(each.value.description, null)
  tags              = merge(var.tags, { "Name" = each.value.name })
}

resource "aws_eip" "this" {
  for_each = { for k, v in var.interfaces : k => v if try(v.create_public_ip, false) && ! can(v.eip_allocation_id) }

  vpc              = true
  public_ipv4_pool = try(each.value.public_ipv4_pool, "amazon")
  tags             = merge(var.tags, { "Name" = "${each.value.name}-eip" })
}

resource "aws_eip_association" "this" {
  for_each = { for k, v in var.interfaces : k => v if try(v.create_public_ip, false) || can(v.eip_allocation_id) }

  allocation_id        = try(aws_eip.this[each.key].id, var.interfaces[each.key].eip_allocation_id)
  network_interface_id = aws_network_interface.this[each.key].id
}

# Attach interfaces to the instance except the first interface. 
# First interface will be directly attached to the EC2 instance. See 'aws_instance' resource 
resource "aws_network_interface_attachment" "this" {
  for_each = { for k, v in aws_network_interface.this : k => v if k > 0 }

  instance_id          = aws_instance.this.id
  network_interface_id = aws_network_interface.this[each.key].id
  device_index         = each.key
}

resource "aws_instance" "this" {
  disable_api_termination              = false
  instance_initiated_shutdown_behavior = "stop"
  ebs_optimized                        = true
  ami                                  = var.custom_ami_id != null ? var.custom_ami_id : data.aws_ami.this[0].id
  instance_type                        = var.instance_type
  key_name                             = var.ssh_key_name
  user_data                            = var.user_data
  monitoring                           = false
  iam_instance_profile                 = var.iam_instance_profile

  root_block_device {
    delete_on_termination = "true"
  }

  # Attach primary interface to the instance
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.this[0].id
  }

  tags = merge(var.tags, { "Name" = var.name })
}
