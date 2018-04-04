#
# Lambda to kick off pgdump -> orc pipeline
#
resource "null_resource" "schedule_pgdump2orc" {
  triggers {
    uuid = "${uuid()}"
  }

  provisioner "local-exec" {
    command = <<EOF
ls -1 ${path.module}/lambda-functions/schedule_pgdump2orc \
    | grep -v schedule_pgdump2orc.py \
    | grep -v requirements.txt \
    | xargs rm -rf
pip install --no-cache-dir -t ${path.module}/lambda-functions/schedule_pgdump2orc \
    -r ${path.module}/lambda-functions/schedule_pgdump2orc/requirements.txt
EOF
  }
}

data "archive_file" "schedule_pgdump2orc" {
  type        = "zip"
  source_dir  = "${path.module}/lambda-functions/schedule_pgdump2orc"
  output_path = "${path.module}/../../.tmp/schedule_pgdump2orc.zip"

  depends_on = [
    "null_resource.schedule_pgdump2orc",
  ]
}

resource "aws_lambda_function" "schedule_pgdump2orc" {
  filename         = "${data.archive_file.schedule_pgdump2orc.output_path}"
  source_code_hash = "${data.archive_file.schedule_pgdump2orc.output_base64sha256}"
  function_name    = "func${var.environment}SchedulePGDump2Orc"
  description      = "Function to schedule daily scene imports via AWS Batch."
  role             = "${aws_iam_role.schedule_pgdump2orc.arn}"
  handler          = "schedule_pgdump2orc.handler"
  runtime          = "python3.6"
  timeout          = 10
  memory_size      = 128

  environment {
    variables = {
      ENVIRONMENT          = "${var.environment}",
      PGDUMP_BUCKET        = "${var.pgdump_bucket}"
      PGDUMP_PREFIX        = "${var.pgdump_prefix}"
      OUTPUT_BUCKET        = "${var.output_bucket}"
    }
  }

  tags {
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}

# TODO: REPLACE LAMBDA S3 TRIGGERS WITH SOMETHING LIKE THIS
resource "aws_s3_bucket_notification" "osm_pgdump_notification" {
  bucket = "${aws_s3_bucket.repository_uploads.id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.schedule_pgdump2orc.arn}
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".orc"
  }
}

