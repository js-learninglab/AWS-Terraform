# create new aws vpc to serve as backend networking
module "aws_vpc_backend" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.5.0"

  cidr = var.aws_vpc_backend_cidr

  azs = slice(data.aws_availability_zones.available.names, 0, var.aws_web_subnet_count)
  public_subnets = [for subnet in range(var.aws_web_subnet_count) : cidrsubnet(var.aws_vpc_backend_cidr, 8, subnet)]

  private_subnets = [for subnet in range(var.aws_web_subnet_count) : cidrsubnet(var.aws_vpc_backend_cidr, 8, subnet + 10)] #similar private subnets as the aws_vpc just to standardize

  enable_nat_gateway     = true #very expensive but to allow internet access for updates in private subnets
  single_nat_gateway     = true
  one_nat_gateway_per_az = false #doesnt really need this as true. All instance use single gateway to access internet just for updates

  enable_vpn_gateway   = false #not needed for this lab
  enable_dns_hostnames = var.aws_vpc_enable_dns_hostnames

  tags = merge(local.common_tags, { name = "${local.naming_prefix}-${var.environment}-backend-vpc" })
}