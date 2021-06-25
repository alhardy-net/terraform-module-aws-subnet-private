output "subnet_ids" {
  value       = aws_subnet.private.*.id
  description = "The Identifier of the private subnet(s)."
}

output "subnet_cidrs" {
  value       = aws_subnet.private.*.cidr_block
  description = "CIDR blocks of the created private subnet(s)."
}

output "route_tables_ids" {
  value       = aws_route_table.private.*.id
  description = "The Identifier of the private routing table(s)."
}