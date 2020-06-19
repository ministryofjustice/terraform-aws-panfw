locals {
  interfaces = flatten([
    for fw_name, firewall in var.firewalls : [
      for if_name, interfaecs in firewall.interfaces : [
        merge(interfaecs, { "fw_name" = fw_name }, { "dns_prefix" = lookup(firewall, "dns_prefix", null) })
      ]
    ]
  ])
}

data "aws_ami" "this" {
  most_recent = true

  filter {
    name   = "name"
    values = ["PA-VM-AWS-${var.fw_version}*"]
  }

  filter {
    name   = "product-code"
    values = ["${var.fw_product_map[var.fw_product]}"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["aws-marketplace"]
}

# Attach interfaces to the instance where index is not 0
# This will allow you to add / remove interfaces from the firewall without having to destroy the ec2 instance
resource "aws_network_interface" "this" {
  for_each          = { for i in local.interfaces : "${i.fw_name}-${i.name}" => i if i.index != 0 }
  subnet_id         = each.value.subnet_id
  private_ips       = lookup(each.value, "private_ips", null)
  security_groups   = lookup(each.value, "security_groups", null)
  source_dest_check = lookup(each.value, "source_dest_check", false)
  description       = lookup(each.value, "description", null)
  attachment {
    instance     = aws_instance.this[each.value.fw_name].id
    device_index = lookup(each.value, "index", null)
  }
  tags = merge(var.tags, lookup(each.value, "tags", {}), { "Name" = each.key })
}

# Creates the primary interface (index 0) for the instance
resource "aws_network_interface" "primary" {
  for_each          = { for i in local.interfaces : i.fw_name => i if i.index == 0 }
  subnet_id         = each.value.subnet_id
  private_ips       = lookup(each.value, "private_ips", null)
  security_groups   = lookup(each.value, "security_groups", null)
  source_dest_check = lookup(each.value, "source_dest_check", false)
  description       = lookup(each.value, "description", null)

  tags = merge(var.tags, lookup(each.value, "tags", {}), { "Name" = each.key })
}

resource "aws_eip" "this" {
  for_each = { for i in local.interfaces :
    "${i.fw_name}-${i.name}" => i
    if lookup(i, "public_ip", false) && i.index != 0 ? true : false
  }
  vpc               = true
  network_interface = aws_network_interface.this[each.key].id
  public_ipv4_pool  = var.public_ipv4_pool

  tags = merge(var.tags, { Name = "${each.key}-eip" }, { FW_Name = each.value.fw_name }, { DNS_Prefix = lookup(each.value, "dns_prefix", null) })
}

resource "aws_eip" "primary" {
  for_each = { for i in local.interfaces :
    i.fw_name => i
    if lookup(i, "public_ip", false) && i.index == 0 ? true : false
  }
  vpc               = true
  network_interface = aws_network_interface.primary[each.key].id
  public_ipv4_pool  = var.public_ipv4_pool

  tags = merge(var.tags, { Name = "${each.key}-eip" })
}

resource "aws_instance" "this" {
  for_each                             = var.firewalls
  disable_api_termination              = false
  instance_initiated_shutdown_behavior = "stop"
  ebs_optimized                        = true
  ami                                  = var.custom_ami != null ? var.custom_ami : data.aws_ami.this.id
  instance_type                        = var.instance_type
  key_name                             = var.key_name
  user_data                            = var.user_data
  monitoring                           = false
  iam_instance_profile                 = var.iam_instance_profile

  root_block_device {
    delete_on_termination = "true"
  }

  # Attach primary interface to the instance
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.primary[each.key].id
  }

  tags = merge(var.tags, { Name = each.key })
}
