locals {
  interfaces = flatten([
    for fw_name, firewall in var.firewalls : [
      for if_idx, i in firewall.interfaces : {
        fw_name   = firewall.name
        if_idx    = if_idx
        if_name   = i.name
        public_ip = i.public_ip
        # dns_prefix = lookup(i, "dns_prefix", null)
        attr = i
      }
    ]
  ])
}

data "aws_ami" "this" {
  count       = var.custom_ami == null ? 1 : 0
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
  for_each          = { for i in local.interfaces : "${i.fw_name}-${i.if_name}" => merge(i, i.attr) }
  subnet_id         = each.value.subnet_id
  private_ips       = lookup(each.value, "private_ips", null)
  security_groups   = lookup(each.value, "security_groups", null)
  source_dest_check = lookup(each.value, "source_dest_check", false)
  description       = lookup(each.value, "description", null)

  tags = merge(var.tags, lookup(each.value, "tags", {}), { "Name" = each.key })
}

# Attach interfaces to the instance except the first interface. 
# First interface will be directly attached to the EC2 instance. See 'aws_instance' resource 
resource "aws_network_interface_attachment" "this" {
  for_each             = { for i in local.interfaces : "${i.fw_name}-${i.if_name}" => merge(i, i.attr) if i.if_idx != 0 }
  instance_id          = aws_instance.this[each.value.fw_name].id
  network_interface_id = aws_network_interface.this[each.key].id
  device_index         = lookup(each.value, "if_idx", null)
}

resource "aws_eip" "this" {
  for_each = { for i in local.interfaces :
    "${i.fw_name}-${i.if_name}" => merge(i, i.attr)
    if i.public_ip
  }
  vpc               = true
  network_interface = aws_network_interface.this[each.key].id
  public_ipv4_pool  = var.public_ipv4_pool

  tags = merge(
    var.tags,
    each.value.tags,
    { Name = "${each.key}-eip" }
    # { FW_Name = each.value.fw_name },
    # { DNS_Prefix = each.value.dns_prefix }
  )
}

resource "aws_instance" "this" {
  for_each                             = { for f in var.firewalls : f.name => f }
  disable_api_termination              = false
  instance_initiated_shutdown_behavior = "stop"
  ebs_optimized                        = true
  ami                                  = var.custom_ami != null ? var.custom_ami : data.aws_ami.this[0].id
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
    network_interface_id = aws_network_interface.this["${each.key}-${each.value.interfaces[0].name}"].id
  }

  # If firewall name is provided as tag use that instead of using each.key
  # This will ensure the user can later change the name of the firewall without destroying the aws_instance
  tags = merge(var.tags, { Name = lookup(each.value.tags, "Name", each.key) })
}
