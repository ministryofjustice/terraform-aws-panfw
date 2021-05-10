# Terraform AWS PAN VM-Series Firewall

## Overview

This Terraform module deploys the Palo Alto Networks vm-series firewalls. Each firewall is a distinct AWS EC2 instance.

## Usage

```terraform
module "panfw" {
  source    = "git::https://spring.paloaltonetworks.com/mekanayake/terraform-aws-vmseries?ref=v0.2.1"
  key_name  = aws_key_pair.this.key_name
  firewalls = [
    {
      name       = "myfw"
      interfaces = [
        {
          name            = "mynic0"
          subnet_id       = aws_subnet.this.id
          security_groups = [aws_security_group.this.id]
          public_ip       = true
          dns_prefix      = "myprefix"
        }
      ]
    }
  ]
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->