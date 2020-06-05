locals {
  interfaces = flatten([
    for fw_name, firewall in var.firewalls : [
      for if_name, interfaecs in firewall.interfaces : [
        merge(interfaecs, { "fw_name" = fw_name })
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

# resource "aws_network_interface" "this" {
#   for_each          = { for i in local.interfaces : "${i.fw_name}-${i.name}" => i }
#   subnet_id         = each.value.subnet_id
#   private_ips       = lookup(each.value, "private_ips", null)
#   security_groups   = each.value.security_groups
#   source_dest_check = lookup(each.value, "source_dest_check", true)
#   description       = lookup(each.value, "description", null)

#   tags = merge(var.tags, lookup(each.value, "tags", {}), { "Name" = each.key })
# }

# Attach interfaces to the instance where index is not 0
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

resource "aws_eip" "this" {
  for_each = { for i in local.interfaces :
    "${i.fw_name}-${i.name}" => i
    if lookup(i, "public_ip", null) != null ? true : false
  }
  vpc               = true
  network_interface = aws_network_interface.this[each.key].id

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

  # Attach index 0 interface to the instance
  dynamic "network_interface" {
    for_each = [for i in each.value.interfaces : i if i.index == 0]

    content {
      device_index         = network_interface.value.index
      network_interface_id = aws_network_interface.this["${each.key}-${network_interface.value.name}"].id
    }

  }

  tags = merge(var.tags, { Name = each.key })
}
