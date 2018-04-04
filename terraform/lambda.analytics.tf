#
# Lambda to kick off analysis of osm orc files
#
resource "null_resource" "schedule_analytics" {
  triggers {
    uuid = "${uuid()}"
  }

  provisioner "local-exec" {
    command = <<EOF
ls -1 ${path.module}/lambda-functions/schedule_analytics \
    | grep -v schedule_analytics.py \
    | grep -v requirements.txt \
    | xargs rm -rf
pip install --no-cache-dir -t ${path.module}/lambda-functions/schedule_analytics \
    -r ${path.module}/lambda-functions/schedule_analytics/requirements.txt
EOF
  }
}

data "archive_file" "schedule_analytics" {
  type        = "zip"
  source_dir  = "${path.module}/lambda-functions/schedule_analytics"
  output_path = "${path.module}/../../.tmp/schedule_analytics.zip"

  depends_on = [
    "null_resource.schedule_analytics",
  ]
}

resource "aws_lambda_function" "schedule_analytics" {
  filename         = "${data.archive_file.schedule_analytics.output_path}"
  source_code_hash = "${data.archive_file.schedule_analytics.output_base64sha256}"
  function_name    = "func${var.environment}ScheduleAnalytics"
  description      = "Function to schedule daily scene imports via AWS Batch."
  role             = "${aws_iam_role.schedule_analytics.arn}"
  handler          = "schedule_analytics.handler"
  runtime          = "python3.6"
  timeout          = 10
  memory_size      = 128

  environment {
    variables = {
      ENVIRONMENT          = "${var.environment}"
    }
  }

  tags {
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}

