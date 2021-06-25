locals {
  name                             = "alhardynet"
  aws_region                       = "ap-southeast-2"
  vpc_cidr                         = "10.0.0.0/16"
  private_application_subnet_count = 3
  private_persistence_subnet_count = 3
  public_subnet_cidr               = cidrsubnet(local.vpc_cidr, 4, 0)
  private_application_subnet_cidr  = local.private_application_subnet_count > 0 ? cidrsubnet(local.vpc_cidr, 2, 1) : 0
  private_persistence_subnet_cidr  = local.private_persistence_subnet_count > 0 ? cidrsubnet(local.vpc_cidr, 2, 2) : 0
}

module "aws-vpc" {
  source                        = "app.terraform.io/bytebox/aws-vpc/module"
  version                       = "0.0.1"
  aws_region                    = local.aws_region
  vpc_cidr                      = local.vpc_cidr
  enable_vpc_flow_log           = false
  manage_default_security_group = false
  manage_default_network_acl    = false
  manage_default_route_table    = false
  name                          = local.name
}

module "public-subnet" {
  source                 = "app.terraform.io/bytebox/aws-subnet-public/module"
  version                = "0.0.1"
  aws_region             = local.aws_region
  igw_id                 = module.aws-vpc.igw_id
  name                   = local.name
  enable_nat_gateway     = true
  use_single_nat_gateway = true
  subnet_count           = 2
  vpc_id                 = module.aws-vpc.vpc_id
  enable_flow_log        = false
  subnet_cidr            = local.public_subnet_cidr
}

module "private-application-subnet" {
  source                = "../../"
  aws_region            = local.aws_region
  enable_flow_log       = false
  name                  = "${local.name}-private-application"
  nat_gateway_ids       = module.public-subnet.nat_gateway_ids
  subnet_cidr           = local.private_application_subnet_cidr
  subnet_count          = local.private_application_subnet_count
  vpc_id                = module.aws-vpc.vpc_id
  allow_internet_access = true
}

module "private-persistence-subnet" {
  source                = "../../"
  aws_region            = local.aws_region
  enable_flow_log       = false
  name                  = "${local.name}-private-persistence"
  nat_gateway_ids       = module.public-subnet.nat_gateway_ids
  subnet_cidr           = local.private_persistence_subnet_cidr
  subnet_count          = local.private_persistence_subnet_count
  vpc_id                = module.aws-vpc.vpc_id
  allow_internet_access = false
}