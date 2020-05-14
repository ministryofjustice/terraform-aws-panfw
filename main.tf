variable "firewalls" {
  default = {
    firewall-a-tmp = {

      interfaces = [
        { name = "eth0", subnet = "test", index = 0, public_ip = true },
        { name = "eth1", subnet = "test", index = 1, public_ip = true },
        { name = "eth2", subnet = "test", index = 2 }
      ]
    },
    firewall-b-tmp = {
      interfaces = [
        { name = "eth0", subnet = "test", index = 0 },
        { name = "eth1", subnet = "test", index = 1 },
        { name = "eth2", subnet = "test", index = 2 }
      ]
    }
  }
}

locals {
  interfaces = flatten([
    for fw_name, firewall in var.firewalls : [
      for if_name, interfaecs in firewall.interfaces : [
        merge(interfaecs, { "fw_name" = fw_name })
      ]
    ]
  ])
}

variable "tags" {
  default = {}
}


output "test" {
  # value = local.interfaces
  value = { for i in local.interfaces : "${i.fw_name}-${i.name}" => i }
}

# module.vpc.subnets["Central-Mgmt-2a"].id, secrity_groups = []
# module.vpc.subnets["Central-Mgmt-2a"].id, secrity_groups = []
# module.vpc.subnets["Central-Mgmt-2a"].id, secrity_groups = []

resource "aws_network_interface" "eni-management" {
  for_each          = { for i in local.interfaces : "${i.fw_name}-${i.name}" => i }
  subnet_id         = each.value.subnet
  security_groups   = each.value.secrity_groups
  source_dest_check = lookup(each.value, "source_dest_check", true)

  tags = merge(var.tags, { Name = each.key })
}

# resource "aws_eip" "eip-management" {
#   for_each          = var.management_subnet
#   vpc               = true
#   network_interface = aws_network_interface.eni-management[each.key].id

#   tags = {
#     Name = "eip_${each.key}_management"
#   }
# }

# resource "aws_eip" "eip-untrust" {
#   for_each          = var.untrust_subnet
#   vpc               = true
#   network_interface = aws_network_interface.eni-untrust[each.key].id

#   tags = {
#     Name = "eip_${each.key}_untrust"
#   }
# }

# # output "test" {
# #   value = aws_network_interface.eni-management
# # }

# resource "aws_instance" "instance-ngfw" {
#   disable_api_termination              = false
#   instance_initiated_shutdown_behavior = "stop"

#   ebs_optimized = true
#   ami           = var.custom_ami
#   instance_type = "m4.xlarge"
#   key_name      = "aws-moj"

#   monitoring = false

#   root_block_device {
#     delete_on_termination = "true"
#   }
#   network_interface {
#     device_index         = 1
#     network_interface_id = aws_network_interface.eni-management["security-Mgmt-a"].id
#   }

#   network_interface {
#     device_index         = 0
#     network_interface_id = aws_network_interface.eni-untrust["security-Pub-a"].id
#   }

#   network_interface {
#     device_index         = 2
#     network_interface_id = aws_network_interface.eni-trust["security-Priv-a"].id
#   }

#   tags = {
#     Name = "GP POC MOJ FW 1"
#   }
# }

# resource "aws_instance" "instance-ngfw-2" {
#   disable_api_termination              = false
#   instance_initiated_shutdown_behavior = "stop"

#   ebs_optimized = true
#   ami           = var.custom_ami
#   instance_type = "m4.xlarge"
#   key_name      = "aws-moj"

#   monitoring = false

#   root_block_device {
#     delete_on_termination = "true"
#   }
#   network_interface {
#     device_index         = 1
#     network_interface_id = aws_network_interface.eni-management["security-Mgmt-b"].id
#   }

#   network_interface {
#     device_index         = 0
#     network_interface_id = aws_network_interface.eni-untrust["security-Pub-b"].id
#   }

#   network_interface {
#     device_index         = 2
#     network_interface_id = aws_network_interface.eni-trust["security-Priv-b"].id
#   }

#   tags = {
#     Name = "GP POC MOJ FW 2"
#   }
# }

# # output "eip_untrust" {
# #   value = "${aws_eip.eip-untrust.public_ip}"
# # }

# # output "eip_mgmt" {
# #   value = "${aws_eip.eip-management.public_ip}"
# # }
# # output "trust_eni_id" {
# #   value = "${aws_network_interface.eni-trust.id}"
# # }
