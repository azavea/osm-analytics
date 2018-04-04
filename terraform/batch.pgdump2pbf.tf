resource "aws_batch_compute_environment" "pgdump2pbf" {
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
    max_vcpus     = "16"

    spot_iam_fleet_role = "${aws_iam_role.container_instance_spot_fleet.arn}"
    instance_role       = "${module.pgdump2pbf_container_service_cluster.container_instance_ecs_for_ec2_service_role_arn}"

    instance_type = [
      "${var.pgdump2pbf_instance_type}",
    ]

    security_group_ids = [
      "${module.pgdump2pbf_container_service_cluster.container_instance_security_group_id}",
    ]

    subnets = [
      "${var.public_subnets}",
    ]

    tags {
      Name               = "BatchWorker"
      ComputeEnvironment = "Default"
      Project            = "${var.project}"
      Environment        = "${var.environment}"
    }
  }
}

data "template_file" "pgdump2pbf_job_definition" {
  template = "${file("job-definitions/batch-pgdump2pbf.json")}"

  vars {
    batch_image_url               = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/raster-foundry-batch:${var.image_version}"
    aws_region                    = "${var.aws_region}"
    environment                   = "${var.environment}"
  }
}

resource "aws_batch_job_definition" "pgdump2pbf" {
  name = "job${var.environment}PGDump2PBF"
  type = "container"

  container_properties = "${data.template_file.pgdump2pbf_job_definition.rendered}"

  parameters {
    pgdump-path = "",
    history-path = "",
    snapshot-path = "",
    changeset-path = ""
  }

  retry_strategy {
    attempts = 3
  }
}

