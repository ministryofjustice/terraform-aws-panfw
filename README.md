# Terraform AWS PAN VM-Series Firewall

## Overview

This Terraform module deploys the Palo Alto Networks vm-series firewalls. Each firewall is a distinct AWS EC2 instance.

## Usage

```terraform
module "panfw" {
  source    = "git::https://spring.paloaltonetworks.com/mekanayake/terraform-aws-vmseries?ref=v0.1.0"
  key_name  = aws_key_pair.this.key_name
  firewalls = [
    {
      name       = "myfw"
      interfaces = [
        {
          name           = "mynic0"
          subnet_id      = aws_subnet.this.id
          security_group = aws_security_group.this.id
          public_ip      = true
          dns_prefix     = "myprefix"
        }
      ]
    }
  ]
}
```

## Providers

| Name | Version |
|------|---------|
| aws | ~> 2 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| tags | Optional tags to apply to all resources | `map(any)` | {} | no |
| firewalls | List of firewalls to create | `list(any)` | {} | no |
| fw\_version | Firewall version to deploy | `string` | "9.1.2" | no |
| fw\_product | Type of firewall product, one of: 'byol', 'bundle-1', 'bundle-2' | n/a | "byol" | no |
| fw\_product\_map | Firewall product codes | `map(string)` | {<br>byol     = "6njl1pau431dv1qxipg63mvah"<br>bundle-1 = "6kxdw3bbmdeda3o6i1ggqt4km"<br>bundle-2 = "806j2of0qy5osgjjixq9gqc6g"<br>} | no |
| instance\_type | EC2 instance type for firewall | `string` | "m5.xlarge" | no |
| key\_name | AWS SSH key name | `string` | n/a | no |
| user\_data | User data | n/a | n/a | no |
| custom\_ami | Custom AMI id to use instead of the usual fw\_product\_map | `string` | n/a | no |
| iam\_instance_profile | Firewall instance IAM profile | `string` | n/a | no |
| public\_ipv4\_pool | EC2 IPv4 address pool identifier | n/a | "amazon" | no |

### Map of firewalls - typical example

```terraform
  firewalls = {
    myfw = {
      interfaces = [
        {
          description    = "The example network interface of Palo Alto firewall"
          name           = "mynic0"
          public_ip      = true
          security_group = aws_security_group.this.id
          subnet_id      = aws_subnet.this.id
          private_ips    = [ "172.31.244.200" ]
          dns_prefix     = "myprefix" // extra aws tag
        }
      ]
    }
  }
```

## Outputs

| Name | Description |
|------|-------------|
| pafw | Created firewalls, as map of `aws_instance` objects |
| primary\_public\_ip | Mapping of EC2 name to its primary public IP |
| elastic\_ips | Non-primary Elastic IP addresses |
| network\_interfaces | All created non-primary network interfaces, as map of `aws_network_interface` objects |
