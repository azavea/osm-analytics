
resource "aws_batch_job_queue" "pgdump2orc" {
  name                 = "queue${var.environment}PGDump2ORC"
  priority             = 1
  state                = "ENABLED"
  compute_environments = ["${aws_batch_compute_environment.pbf2orc.arn}", "${aws_batch_compute_environment.pgdump2pbf.arn}"]
}

