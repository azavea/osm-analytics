variable "project" {
  default = "OSM pgdump2orc"
}

variable "environment" {
  default = "OsmOrcStaging"
}

variable "pgdump_bucket" {}

variable "pgdump_key" {}

variable "output_bucket" {}

variable "aws_region" {
  default = "us-east-1"
}

variable "aws_availability_zones" {
  default = ["us-east-1c", "us-east-1d"]
}

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

variable "public_subnets" { type = "list" }

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

variable "bastion_ami" {
  default = "ami-ff02509a"
}

variable "bastion_instance_type" {
  default = "t2.micro"
}
