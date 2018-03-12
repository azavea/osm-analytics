variable "project" {
  default = "OSM pgdump2orc"
}

variable "environment" {
  default = "Staging"
}

variable "output_tag" { default = "output" }

variable "aws_region" {
  default = "us-east-1"
}

variable "aws_availability_zones" {
  default = ["us-east-1c", "us-east-1d"]
}

variable "pgdump_s3path" {}
variable "pbf_s3path" {}
variable "orc_s3path" {}
variable "ingest_status_s3path" {}

variable "aws_account_id" {}

variable "aws_ecs_service_role_policy_arn" {
  default = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

variable "aws_spot_fleet_service_role_policy_arn" {
  default = "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole"
}

variable "aws_batch_service_role_policy_arn" {
  default = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}

variable "aws_lambda_service_role_policy_arn" {
  default = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

variable "aws_s3_policy_arn" {
  default = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

variable "aws_batch_policy_arn" {
  default = "arn:aws:iam::aws:policy/AWSBatchFullAccess"
}

variable "aws_cloudwatch_logs_policy_arn" {
  default = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

variable "aws_ses_policy_arn" {
  default = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
}

variable "aws_key_name" {}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "external_access_cidr_block" {
  default = "66.212.12.106/32"
}

variable "vpc_private_subnet_cidr_blocks" {
  default = ["10.0.1.0/24", "10.0.3.0/24"]
}

variable "vpc_public_subnet_cidr_blocks" {
  default = ["10.0.0.0/24", "10.0.2.0/24"]
}

variable "image_version" {}

variable "pgdump2pbf_instance_type" {
  default = "c5.4xlarge"
}

variable "pbf2orc_instance_type" {
  default = "c5.xlarge"
}

variable "pgdump2pbf_instance_root_block_device_type" {
  default = "gp2"
}

variable "pgdump2pbf_instance_root_block_device_size" {
  default = "1500"
}

variable "pbf2orc_instance_root_block_device_type" {
  default = "gp2"
}

variable "pbf2orc_instance_root_block_device_size" {
  default = "1000"
}

variable "batch_ami_id" {}

variable "spot_fleet_bid_percentage" {}

variable "dataproc_vpc_id" {}

variable "dataproc_private_subnet_cidr_block" {}

variable "bastion_ami" {}

variable "bastion_instance_type" {
  default = "t2.micro"
}
