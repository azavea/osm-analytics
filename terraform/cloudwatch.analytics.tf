#
# Cloudwatch scheduling of lambda invocation upon batch completion
#
resource "aws_cloudwatch_event_rule" "schedule_analytics" {
  name        = "rule${var.environment}ScheduleAnalytics"
  description = "Rule to schedule generation of fresh ORC files from OSM pgdumps."

  # base this rule on output from batch.pbf2orc
    event_pattern = <<PATTERN
{
  "detail-type": [
    "Batch Job State Change"
  ],
  "source": [
    "aws.batch"
  ],
  "detail": {
    "jobDefinition": "${aws_batch_job_definition.pbf2orc.arn}",
    "status": "SUCCEEDED"
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "schedule_analytics" {
  rule      = "${aws_cloudwatch_event_rule.schedule_analytics.name}"
  target_id = "target${var.environment}ScheduleAnalytics"
  arn       = "${aws_lambda_function.schedule_analytics.arn}"

  input = <<INPUT
{
    "jobDefinition": "${aws_batch_job_definition.pgdump2pbf.name}"
}
INPUT
}

resource "aws_lambda_permission" "schedule_analytics" {
  statement_id  = "perm${var.environment}ScheduleFindAOIProjects"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.schedule_analytics.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.schedule_analytics.arn}"
}

