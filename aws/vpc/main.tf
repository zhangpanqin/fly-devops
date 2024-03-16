locals {
  vpc_name         = "eu-north-1-demo-zpq-vpc"
}
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.6.0"

  name = local.vpc_name
  cidr = "10.52.0.0/16"

  azs             = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
  private_subnets = [
    "10.52.0.0/18",
    "10.52.64.0/18",
    "10.52.128.0/18"
  ]

  private_subnet_suffix = "prv"

  private_subnet_tags = {
    "Tier" = "private"
  }

  public_subnets = [
    "10.52.192.0/21",
    "10.52.200.0/21",
    "10.52.208.0/21"
  ]

  public_subnet_suffix = "pub"
  public_subnet_tags   = {
    "Tier" = "public"
  }

  create_database_subnet_group    = false
  create_elasticache_subnet_group = false
  create_redshift_subnet_group    = false
  map_public_ip_on_launch = false
  enable_dns_hostnames    = true
  enable_dns_support      = true
  enable_nat_gateway      = true
  one_nat_gateway_per_az  = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

  igw_tags                = { Name : format("%s-igw", local.vpc_name) }
  public_route_table_tags = { Name : format("%s-pub-rt", local.vpc_name) }
  vpc_flow_log_tags       = { Name : format("%s-log-group", local.vpc_name) }

  manage_default_network_acl = true
  default_network_acl_name   = format("%s-acl", local.vpc_name)

  manage_default_route_table = true
  default_route_table_name   = format("%s-main-rt", local.vpc_name)

  manage_default_security_group = true
  default_security_group_name   = format("%s-sg", local.vpc_name)
}