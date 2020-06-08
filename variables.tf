
variable "tags" {
  description = "Optional Tags to apply to all resources"
  type        = map(any)
  default     = {}
}

variable "firewalls" {
  description = "map of firewalls to create"
  type        = map(any)
  default     = {}
}

variable "fw_version" {
  description = "Firewall version to deploy."
  type        = string
  default     = "9.1.2"
}

variable "fw_product" {
  description = "Type of VM-Series to deploy.  Can be one of 'byol', 'bundle-1', 'bundle-2'."
  default     = "byol"
}

variable "fw_product_map" {
  type = map(string)

  default = {
    byol     = "6njl1pau431dv1qxipg63mvah"
    bundle-1 = "6kxdw3bbmdeda3o6i1ggqt4km"
    bundle-2 = "806j2of0qy5osgjjixq9gqc6g"
  }
}

variable "instance_type" {
  description = "Instance type for FW"
  default     = "m5.xlarge"
}

variable "key_name" {
  default = null
}

variable "user_data" {
  default = null
}

variable "custom_ami" {
  description = "Custom AMI for launch template"
  type        = string
  default     = null
}

variable "iam_instance_profile" {
  description = "fw instance profile"
  type        = string
  default     = null
}

variable "public_ipv4_pool" {
  description = "EC2 IPv4 address pool identifier"
  default     = "amazon"
}
