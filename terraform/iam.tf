#
# Spot Fleet IAM resources
#
data "aws_iam_policy_document" "container_instance_spot_fleet_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["spotfleet.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "container_instance_spot_fleet" {
  name               = "fleet${var.environment}ServiceRole"
  assume_role_policy = "${data.aws_iam_policy_document.container_instance_spot_fleet_assume_role.json}"
}

resource "aws_iam_role_policy_attachment" "spot_fleet_policy" {
  role       = "${aws_iam_role.container_instance_spot_fleet.name}"
  policy_arn = "${var.aws_spot_fleet_service_role_policy_arn}"
}


#
# Batch IAM resources
#
data "aws_iam_policy_document" "container_instance_batch_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["batch.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "container_instance_batch" {
  name               = "batch${var.environment}ServiceRole"
  assume_role_policy = "${data.aws_iam_policy_document.container_instance_batch_assume_role.json}"
}

resource "aws_iam_role_policy_attachment" "batch_policy" {
  role       = "${aws_iam_role.container_instance_batch.name}"
  policy_arn = "${var.aws_batch_service_role_policy_arn}"
}


#
# Lambda IAM resources
#
data "aws_iam_policy_document" "schedule_pgdump2orc_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "schedule_pgdump2orc" {
  name               = "lambda${var.environment}SchedulePGDump2Orc"
  assume_role_policy = "${data.aws_iam_policy_document.schedule_pgdump2orc_assume_role.json}"
}

resource "aws_iam_role_policy_attachment" "schedule_pgdump2orc_lambda_policy" {
  role       = "${aws_iam_role.schedule_pgdump2orc.name}"
  policy_arn = "${var.aws_lambda_service_role_policy_arn}"
}

resource "aws_iam_role_policy_attachment" "schedule_pgdump2orc_batch_policy" {
  role       = "${aws_iam_role.schedule_pgdump2orc.name}"
  policy_arn = "${var.aws_batch_policy_arn}"
}

data "aws_iam_policy_document" "alert_batch_failures_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "alert_batch_failures" {
  name               = "lambda${var.environment}AlertBatchFailures"
  assume_role_policy = "${data.aws_iam_policy_document.alert_batch_failures_assume_role.json}"
}

resource "aws_iam_role_policy_attachment" "alert_batch_failures_lambda_policy" {
  role       = "${aws_iam_role.alert_batch_failures.name}"
  policy_arn = "${var.aws_lambda_service_role_policy_arn}"
}

