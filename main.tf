data "aws_availability_zones" "available" {
  state = "available"
}

resource "random_shuffle" "azs" {
  input        = data.aws_availability_zones.available.names
  result_count = 10
}

locals {
  azs               = var.availability_zones == null ? random_shuffle.azs.*.name : var.availability_zones
  number_of_subnets = var.availability_zones == null ? var.subnet_count : length(var.availability_zones)
}

resource "aws_subnet" "private" {
  count                   = local.number_of_subnets
  availability_zone       = local.azs[count.index]
  cidr_block              = cidrsubnet(var.subnet_cidr, ceil(log(local.number_of_subnets == 1 ? local.number_of_subnets * 4 : local.number_of_subnets == 2 ? local.number_of_subnets * 2 : local.number_of_subnets, 2)), count.index)
  map_public_ip_on_launch = false
  vpc_id                  = var.vpc_id

  tags = {
    Name               = "${var.name}-${count.index + 1}"
    TerraformWorkspace = var.TFC_WORKSPACE_SLUG
  }
}

resource "aws_route_table" "private" {
  count  = local.number_of_subnets
  vpc_id = var.vpc_id

  tags = {
    Name               = "${var.name}-${count.index + 1}-${local.azs[count.index]}"
    TerraformWorkspace = var.TFC_WORKSPACE_SLUG
    Type               = "private"
  }
}

resource "aws_route_table_association" "private" {
  count          = local.number_of_subnets
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id

  depends_on = [
    aws_subnet.private,
    aws_route_table.private,
  ]
}

resource "aws_route" "private_with_internet_access_nat_gateway" {
  count                  = var.allow_internet_access ? local.number_of_subnets : 0
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  nat_gateway_id         = element(var.nat_gateway_ids, count.index)
  destination_cidr_block = "0.0.0.0/0"
  depends_on             = [aws_route_table.private]
}

resource "aws_network_acl" "private" {
  count      = local.number_of_subnets > 0 ? 1 : 0
  vpc_id     = var.vpc_id
  subnet_ids = aws_subnet.private.*.id

  dynamic "egress" {
    for_each = var.subnet_network_acl_egress
    content {
      action          = lookup(egress.value, "action", null)
      cidr_block      = lookup(egress.value, "cidr_block", null)
      from_port       = lookup(egress.value, "from_port", null)
      icmp_code       = lookup(egress.value, "icmp_code", null)
      icmp_type       = lookup(egress.value, "icmp_type", null)
      ipv6_cidr_block = lookup(egress.value, "ipv6_cidr_block", null)
      protocol        = lookup(egress.value, "protocol", null)
      rule_no         = lookup(egress.value, "rule_no", null)
      to_port         = lookup(egress.value, "to_port", null)
    }
  }
  dynamic "ingress" {
    for_each = var.subnet_network_acl_ingress
    content {
      action          = lookup(ingress.value, "action", null)
      cidr_block      = lookup(ingress.value, "cidr_block", null)
      from_port       = lookup(ingress.value, "from_port", null)
      icmp_code       = lookup(ingress.value, "icmp_code", null)
      icmp_type       = lookup(ingress.value, "icmp_type", null)
      ipv6_cidr_block = lookup(ingress.value, "ipv6_cidr_block", null)
      protocol        = lookup(ingress.value, "protocol", null)
      rule_no         = lookup(ingress.value, "rule_no", null)
      to_port         = lookup(ingress.value, "to_port", null)
    }
  }

  depends_on = [aws_subnet.private]

  tags = {
    Name               = "${var.name}-${count.index + 1}"
    TerraformWorkspace = var.TFC_WORKSPACE_SLUG
    Type               = "private"
  }
}