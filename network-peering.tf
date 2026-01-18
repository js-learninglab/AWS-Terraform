### this .tf is to create network peering between two vpcs created using vpc module

# create peering connection. Think of this is the bridge between two vpcs
resource "aws_vpc_peering_connection" "a_vpc_peering" {
  vpc_id        = module.aws_vpc.vpc_id                   #frontend vpc
  peer_vpc_id   = module.aws_vpc_backend.vpc_id          #backend vpc
  auto_accept   = true

  tags = merge(local.common_tags, { Name = "${local.naming_prefix}-${var.environment}-vpc-peering" })
}

# add route for frontend vpc to reach backend vpc. Think of this like a road signs for frontend vpc

# Public subnets route to Backend
resource "aws_route" "frontend_public_to_backend" {
  route_table_id            = module.aws_vpc.public_route_table_ids[0]
  destination_cidr_block    = "10.1.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.a_vpc_peering.id
}

# Private subnets route to Backend
resource "aws_route" "frontend_private_to_backend" {
  count                     = length(module.aws_vpc.private_route_table_ids)
  route_table_id            = module.aws_vpc.private_route_table_ids[count.index]
  destination_cidr_block    = "10.1.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.a_vpc_peering.id
}


# add route for backend vpc to reach frontend vpc. Think of this like a road signs for backend vpc

# Public subnets route to Frontend
resource "aws_route" "backend_public_to_frontend" {
  route_table_id            = module.aws_vpc_backend.public_route_table_ids[0]
  destination_cidr_block    = "10.0.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.a_vpc_peering.id
}

# Private subnets route to Backend
resource "aws_route" "backend_private_to_frontend" {
  count                     = length(module.aws_vpc_backend.private_route_table_ids)
  route_table_id            = module.aws_vpc_backend.private_route_table_ids[count.index]
  destination_cidr_block    = "10.0.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.a_vpc_peering.id
}