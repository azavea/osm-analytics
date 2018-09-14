resource "aws_s3_bucket" "osm_pgdump" {
  bucket = "${var.pgdump_bucket}"
}

resource "aws_s3_bucket" "osm_orc" {
  bucket = "${var.output_bucket}"
}
