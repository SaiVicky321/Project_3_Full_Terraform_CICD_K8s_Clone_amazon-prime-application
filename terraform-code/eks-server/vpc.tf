module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.13.0"
#local variables
  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets
  intra_subnets   = local.intra_subnets

  enable_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

# enable_nat_gateway = true: Creates a NAT Gateway in the public subnet, allowing private subnet resources to access the internet. 
# If not used, private subnets won’t have outbound internet access unless you configure another method.

# public_subnet_tags and private_subnet_tags: These tags help Kubernetes (or your infrastructure) identify which subnets are 
# intended for public-facing ELBs and which are for internal ELBs. 
# Without these tags, you would need to manage load balancers manually, and services may not work as intended.