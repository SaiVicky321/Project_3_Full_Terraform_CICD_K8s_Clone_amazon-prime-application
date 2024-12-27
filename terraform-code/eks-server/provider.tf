# This block is used to define local variables within the Terraform configuration.
# This block sets up variables that define the structure of a network in AWS with VPC
locals {
  region = "us-east-1"
  name   = "amazon-prime-cluster"
  vpc_cidr = "10.0.0.0/16"
  azs      = ["us-east-1a", "us-east-1b"]
  # Public subnets are typically used for resources that need to be directly accessible from the internet, such as load balancers.
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
  intra_subnets   = ["10.0.5.0/24", "10.0.6.0/24"]
  tags = {
    Example = local.name
  }
}

provider "aws" {
  region = "us-east-1"
}


# Access Control: 
# Private subnets might have outbound access to the internet through a NAT Gateway, 
# while intra subnets are typically fully isolated and only communicate within the VPC.

# Use Case: 
# Private subnets are often for backend or application layers that need some level of access to the internet, 
# while intra subnets are used for highly secure, isolated communication between services that don't require internet access.