#
# VPC Resources
#
#module "vpc" {
#  source = "github.com/azavea/terraform-aws-vpc?ref=3.1.1"
#
#  name                       = "${format("vpc%s%s",replace(var.project, " ",""), var.environment)}"
#  region                     = "${var.aws_region}"
#  key_name                   = "${var.aws_key_name}"
#  cidr_block                 = "${var.vpc_cidr_block}"
#  external_access_cidr_block = "${var.external_access_cidr_block}"
#  private_subnet_cidr_blocks = "${var.vpc_private_subnet_cidr_blocks}"
#  public_subnet_cidr_blocks  = "${var.vpc_public_subnet_cidr_blocks}"
#  availability_zones         = "${var.aws_availability_zones}"
#  bastion_ami                = "${var.bastion_ami}"
#  bastion_instance_type      = "${var.bastion_instance_type}"
#  project                    = "${var.project}"
#  environment                = "${var.environment}"
#}

