# Terraform AWS PAN VM-Series Firewall

## Overview

This Terraform module deploys the Palo Alto Networks vm-series firewalls. Each firewall is a distinct AWS EC2 instance.

## Usage

```terraform
module "vmseries" {
  source     = "github.com/ministryofjustice/terraform-aws-panfw"

  name           = "fw00"
  ssh_key_name   = "EC2-key-pair-name"
  interfaces = [
    {
      name             = "mgmt"
      subnet_id        = subnet-00000000000000001
      security_groups  = [sg-00000000000000001]
      create_public_ip = true
    }
  ]
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=0.13, <0.15 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.10 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.10 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eip.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) | resource |
| [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_network_interface.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface) | resource |
| [aws_network_interface_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface_attachment) | resource |
| [aws_ami.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_custom_ami_id"></a> [custom\_ami\_id](#input\_custom\_ami\_id) | Custom AMI id to use instead of using an AMI published in the Marketplace. | `string` | `null` | no |
| <a name="input_fw_product"></a> [fw\_product](#input\_fw\_product) | Type of firewall product: one of 'byol', 'bundle-1', 'bundle-2'. | `string` | `"byol"` | no |
| <a name="input_fw_product_map"></a> [fw\_product\_map](#input\_fw\_product\_map) | Firewall product codes. | `map(string)` | <pre>{<br>  "bundle-1": "6kxdw3bbmdeda3o6i1ggqt4km",<br>  "bundle-2": "806j2of0qy5osgjjixq9gqc6g",<br>  "byol": "6njl1pau431dv1qxipg63mvah"<br>}</pre> | no |
| <a name="input_iam_instance_profile"></a> [iam\_instance\_profile](#input\_iam\_instance\_profile) | Firewall instance IAM profile. | `string` | `null` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type for firewall. | `string` | `"m5.xlarge"` | no |
| <a name="input_interfaces"></a> [interfaces](#input\_interfaces) | List of the network interface specifications.<br>The first should be the Management network interface, which does not participate in data filtering.<br>The remaining ones are the dataplane interfaces.<br>- `name`: (Required\|string) Name tag for the ENI.<br>- `description`: (Optional\|string) A descriptive name for the ENI.<br>- `subnet_id`: (Required\|string) Subnet ID to create the ENI in.<br>- `private_ip_address`: (Optional\|string) Private IP to assign to the ENI. If not set, dynamic allocation is used.<br>- `eip_allocation_id`: (Optional\|string) Associate an existing EIP to the ENI.<br>- `create_public_ip`: (Optional\|bool) Whether to create a public IP for the ENI. Default false.<br>- `public_ipv4_pool`: (Optional\|string) EC2 IPv4 address pool identifier. <br>- `source_dest_check`: (Optional\|bool) Whether to enable source destination checking for the ENI. Default false.<br>- `security_groups`: (Optional\|list) A list of Security Group IDs to assign to this interface. Default null.<br>Example:<pre>interfaces =[<br>  {<br>    name: "mgmt"<br>    subnet_id: subnet-00000000000000001<br>    create_public_ip: true<br>  },<br>  {<br>    name: "public"<br>    subnet_id: subnet-00000000000000002<br>    create_public_ip: true<br>    source_dest_check: false<br>  },<br>  {<br>    name: "private"<br>    subnet_id: subnet-00000000000000003<br>    source_dest_check: false<br>  },<br>]</pre> | `any` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the VM-Series virtual machine. | `string` | n/a | yes |
| <a name="input_panos_version"></a> [panos\_version](#input\_panos\_version) | PAN-OS version of the firewall to deploy. | `string` | `"9.1.9"` | no |
| <a name="input_ssh_key_name"></a> [ssh\_key\_name](#input\_ssh\_key\_name) | AWS EC2 key pair name. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to be associated with the resources created. | `map(any)` | `{}` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | User data to provide when launching the instance. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_interfaces"></a> [interfaces](#output\_interfaces) | List of VM-Series network interfaces. The elements of the list are `aws_network_interface` objects. The order is the same as `interfaces` input. |
| <a name="output_mgmt_ip_address"></a> [mgmt\_ip\_address](#output\_mgmt\_ip\_address) | VM-Series management IP address. If `create_public_ip` is `true` or `eip_allocation_id` is used, it is a public IP address, otherwise a private IP address. |
| <a name="output_public_ips"></a> [public\_ips](#output\_public\_ips) | Map of public IPs. The keys represent the interface name, and the values represent the public IP. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->