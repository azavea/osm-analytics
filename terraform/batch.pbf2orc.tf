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
    max_vcpus     = "12"

    spot_iam_fleet_role = "${aws_iam_role.container_instance_spot_fleet.arn}"
    instance_role       = "${module.pbf2orc_container_service_cluster.container_instance_ecs_for_ec2_service_role_arn}"

    instance_type = [
      "${var.pbf2orc_instance_type}",
    ]

    security_group_ids = [
      "${module.pbf2orc_container_service_cluster.container_instance_security_group_id}",
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

data "template_file" "pbf2orc_job_definition" {
  template = "${file("job-definitions/batch-pbf2orc.json")}"

  vars {
    batch_image_url               = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/raster-foundry-batch:${var.image_version}"
    aws_region                    = "${var.aws_region}"
    environment                   = "${var.environment}"
  }
}

resource "aws_batch_job_definition" "pbf2orc" {
  name = "job${var.environment}PBF2ORC"
  type = "container"

  container_properties = "${data.template_file.pbf2orc_job_definition.rendered}"

  parameters {
    pbf-bucket = "${aws_s3_bucket.osm_pgdump.bucket}",
    pbf-history-key = "${var.output_prefix}planet.osh.pbf",
    pbf-snapshot-key = "${var.output_prefix}planet.osm.pbf",
    xml-changeset-key = "${var.output_prefix}planet.osc.pbf",
    orc-bucket = "${aws_s3_bucket.osm_orc.bucket}",
    orc-history-key = "${var.output_prefix}planet.osh.orc",
    orc-snapshot-key = "${var.output_prefix}planet.osm.orc",
    orc-changeset-key = "${var.output_prefix}planet.osc.orc"
  }

  retry_strategy {
    attempts = 3
  }
}

