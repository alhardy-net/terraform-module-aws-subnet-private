variable "aws_region" {
  description = "The AWS region for the resources."
  type        = string
}

variable "name" {
  description = "The prefix to use for all resource names."
  type        = string
}

variable "vpc_id" {
  description = "The Identifier of the VPC for which to create the subnet(s)."
  type        = string
}

variable "subnet_cidr" {
  description = "The CIDR block for the Subnet."
  type        = string
}

variable "subnet_count" {
  description = "The number of public subnets, each assigned a random AZ where assigned AZ will be unique when possible."
  type        = number
}

variable "nat_gateway_ids" {
  description = "The nat gateway ids for each of the subnets providing internet access. allow_internet_access should be true"
  type        = list(string)
  default     = []
}

variable "allow_internet_access" {
  description = "Configures private subnet to use NAT gateway for internet access."
  type        = bool
  default     = true
}

variable "subnet_network_acl_egress" {
  description = "Egress network ACL rules for public subnets"
  type        = list(map(string))

  default = [
    {
      rule_no    = 100
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
    },
  ]
}

variable "subnet_network_acl_ingress" {
  description = "Private network ACL rules for public subnets"
  type        = list(map(string))

  default = [
    {
      rule_no    = 100
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
    },
  ]
}

variable "availability_zones" {
  type        = list(string)
  default     = null
  description = "The availability zones to use for the private subnets. If not specified random az will be assigned. The length will overrides the subnet_count."
}

# Terraform Cloud
variable "TFC_WORKSPACE_SLUG" {
  type        = string
  default     = "local"
  description = "This is the full slug of the configuration used in this run. This consists of the organization name and workspace name, joined with a slash"
}