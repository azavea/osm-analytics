#
# VPC Resources
#
module "vpc" {
  source = "github.com/azavea/terraform-aws-vpc?ref=3.1.1"

  name                       = "${format("vpc%s%s",replace(var.project, " ",""), var.environment)}"
  region                     = "${var.aws_region}"
  key_name                   = "${var.aws_key_name}"
  cidr_block                 = "${var.vpc_cidr_block}"
  external_access_cidr_block = "${var.external_access_cidr_block}"
  private_subnet_cidr_blocks = "${var.vpc_private_subnet_cidr_blocks}"
  public_subnet_cidr_blocks  = "${var.vpc_public_subnet_cidr_blocks}"
  availability_zones         = "${var.aws_availability_zones}"
  bastion_ami                = "${var.bastion_ami}"
  bastion_instance_type      = "${var.bastion_instance_type}"
  project                    = "${var.project}"
  environment                = "${var.environment}"
}

#
# VPC Peering Resources
#
resource "aws_vpc_peering_connection" "dataproc" {
  peer_owner_id = "${var.aws_account_id}"
  peer_vpc_id   = "${var.dataproc_vpc_id}"
  vpc_id        = "${module.vpc.id}"
  auto_accept   = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags {
    Name        = "peer${var.environment}Dataproc"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}

data "aws_route_table" "private" {
  count = "${length(var.vpc_private_subnet_cidr_blocks)}"

  subnet_id = "${element(module.vpc.private_subnet_ids, count.index)}"
}

resource "aws_route" "dataproc_peer" {
  count = "${length(var.vpc_private_subnet_cidr_blocks)}"

  route_table_id            = "${element(data.aws_route_table.private.*.id, count.index)}"
  destination_cidr_block    = "${var.dataproc_private_subnet_cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.dataproc.id}"
}
