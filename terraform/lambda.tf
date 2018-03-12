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
    | grep -v schedule_batch.py \
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
      ENVIRONMENT          = "${var.environment}"
    }
  }

  tags {
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}


#
# Cloudwatch scheduling of lambda invocation
#
resource "aws_cloudwatch_event_rule" "schedule_pgdump2orc" {
  name        = "rule${var.environment}SchedulePGDump2orc"
  description = "Rule to schedule generation of fresh ORC files from OSM pgdumps."

  # 7 UTC, 12AM PT, 3AM ET
  schedule_expression = "cron(0 7 * * ? *)"
}

resource "aws_cloudwatch_event_target" "schedule_pgdump2orc" {
  rule      = "${aws_cloudwatch_event_rule.schedule_pgdump2orc.name}"
  target_id = "target${var.environment}SchedulePGDump2Orc"
  arn       = "${aws_lambda_function.schedule_pgdump2orc.arn}"

  input = <<INPUT
{
    "jobDefinition": "${aws_batch_job_definition.pgdump2pbf.name}"
}
INPUT
}

resource "aws_lambda_permission" "schedule_pgdump2orc" {
  statement_id  = "perm${var.environment}ScheduleFindAOIProjects"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.schedule_pgdump2orc.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.schedule_pgdump2orc.arn}"
}
