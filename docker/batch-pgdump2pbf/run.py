#!/usr/bin/env python
import os
import subprocess
import boto3
import argparse
from datetime import datetime, timedelta


parser = argparse.ArgumentParser(description='Produce PBFs from an OSM PGDump.')
parser.add_argument('--pgdump-bucket', metavar='S3BUCKET', type=str, help='An S3 bucket for an OSM pgdump', dest="pgdump_bucket")
parser.add_argument('--pgdump-key', metavar='S3KEY', type=str, help='An S3 key for an OSM pgdump', dest="pgdump_key")
parser.add_argument('--output-bucket', metavar='S3BUCKET', type=str, help='An S3 bucket for holding processed files', dest="output_bucket")
parser.add_argument('--output-prefix', metavar='S3PREFIX', type=str, help='An S3 prefix for holding processed files', dest="output_prefix")

# Construct full key (including datetime) to filename
def construct_key(prefix, filename, suffix):
    date = (datetime.now() - timedelta(days=1)).strftime('%Y-%m-%d')
    return "{}/{}-{}.{}".format(prefix, filename, date, suffix)


if __name__ == "__main__":
    args = parser.parse_args()
    client = boto3.client('s3')
    pgdump_filename = args.pgdump_key.split('/')[-1].split('.')[0]
    local_pgdump = "/tmp/osm.pgdump"
    local_history = "/tmp/planet.osh.pbf"
    local_snapshot = "/tmp/planet.osm.pbf"
    local_changesets = "/tmp/planet.osc.xml.bz2"

    client.download_file(args.pgdump_bucket, args.pgdump_key, local_pgdump)
    subprocess.call(['/bin/planet-dump-ng',
        "-f", local_pgdump,
        "--history-pbf", local_history,
        "--pbf", local_snapshot,
        "--changesets", local_changesets
    ])
    client.upload_file(local_history, args.pbf_bucket, construct_key(args.output_prefix, pgdump_filename, 'osh.pbf'))
    client.upload_file(local_snapshot, args.pbf_bucket, construct_key(args.output_prefix, pgdump_filename, 'osm.pbf'))
    client.upload_file(local_changesets, args.pbf_bucket, construct_key(args.output_prefix, pgdump_filename, 'osc.xml.bz2'))

