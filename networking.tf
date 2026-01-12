#create aws vpc using module
module "aws_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.5.0"

  cidr = var.aws_vpc_cidr

  azs            = slice(data.aws_availability_zones.available.names, 0, var.aws_web_subnet_count)
  public_subnets = [for subnet in range(var.aws_web_subnet_count) : cidrsubnet(var.aws_vpc_cidr, 8, subnet)]

  private_subnets = [for subnet in range(var.aws_web_subnet_count) : cidrsubnet(var.aws_vpc_cidr, 8, subnet + 10)]

  enable_nat_gateway     = true #very expensive! #changing this to true to allow private subnets to have internet access for updates
  single_nat_gateway     = false
  one_nat_gateway_per_az = true #very expensive!

  enable_vpn_gateway   = false #not needed for this lab
  enable_dns_hostnames = var.aws_vpc_enable_dns_hostnames

  tags = merge(local.common_tags, { name = "${local.naming_prefix}-${var.environment}-vpc" })
}
#removing below aws vpc creation as i am using vpc module now
