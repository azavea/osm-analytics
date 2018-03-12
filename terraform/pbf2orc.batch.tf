resource "aws_batch_compute_environment" "pbf2orc" {
  compute_environment_name = "batch${var.environment}DefaultComputeEnvironment"
  type                     = "MANAGED"
  state                    = "ENABLED"
  service_role             = "${aws_iam_role.container_instance_batch.arn}"

  compute_resources {
    type           = "SPOT"
    bid_percentage = "${var.spot_fleet_bid_percentage}"
    ec2_key_pair   = "${var.aws_key_name}"
    image_id       = "${var.batch_ami_id}"

    min_vcpus     = "0"
    max_vcpus     = "4"

    spot_iam_fleet_role = "${aws_iam_role.container_instance_spot_fleet.arn}"
    instance_role       = "${module.pbf2orc_container_service_cluster.container_instance_ecs_for_ec2_service_role_arn}"

    instance_type = [
      "${var.pbf2orc_instance_type}",
    ]

    security_group_ids = [
      "${module.pbf2orc_container_service_cluster.container_instance_security_group_id}",
    ]

    subnets = [
      "${module.vpc.public_subnet_ids}",
    ]

    tags {
      Name               = "BatchWorker"
      ComputeEnvironment = "Default"
      Project            = "${var.project}"
      Environment        = "${var.environment}"
    }
  }
}

resource "aws_batch_job_queue" "pbf2orc" {
  name                 = "queue${var.environment}Ingest"
  priority             = 1
  state                = "ENABLED"
  compute_environments = ["${aws_batch_compute_environment.pbf2orc.arn}"]
}

data "template_file" "pbf2orc_job_definition" {
  template = "${file("job-definitions/pbf2orc.json")}"

  vars {
    batch_image_url               = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/raster-foundry-batch:${var.image_version}"
    aws_region                    = "${var.aws_region}"
    status_path                   = "${var.ingest_status_s3path}"
    pgdump_path                   = "${var.pgdump_s3path}"
    pbf_path                      = "${var.pbf_s3path}"
    output_tag                    = "${var.output_tag}"
    environment                   = "${var.environment}"
  }
}

resource "aws_batch_job_definition" "pbf2orc" {
  name = "job${var.environment}IngestScene"
  type = "container"

  container_properties = "${data.template_file.pbf2orc_job_definition.rendered}"

  parameters {
    sceneId = " "
  }

  retry_strategy {
    attempts = 3
  }
}

#
# Autoscaling Resources
#
data "template_file" "pbf2orc_container_instance_cloud_config" {
  template = "${file("cloud-config/container-instance.yml.tpl")}"

  vars {
    environment   = "${var.environment}"
  }
}

module "pbf2orc_container_service_cluster" {
  source = "github.com/azavea/terraform-aws-ecs-cluster?ref=1.0.0"

  root_block_device_type = "${var.pbf2orc_instance_root_block_device_type}"
  root_block_device_size = "${var.pbf2orc_instance_root_block_device_size}"

  lookup_latest_ami    = true
  vpc_id               = "${module.vpc.id}"
  instance_type        = "${var.pbf2orc_instance_type}"
  key_name             = "${var.aws_key_name}"
  cloud_config_content = "${data.template_file.pbf2orc_container_instance_cloud_config.rendered}"

  health_check_grace_period = "600"
  desired_capacity          = "0"
  min_size                  = "0"
  max_size                  = "1"

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  private_subnet_ids = ["${module.vpc.private_subnet_ids}"]

  project     = "${var.project}"
  environment = "${var.environment}"
}

