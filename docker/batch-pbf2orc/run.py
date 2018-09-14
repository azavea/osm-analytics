#!/usr/bin/env python
import os
import subprocess
import boto3
import shutil

parser = argparse.ArgumentParser(description='Produce PBFs from an OSM PGDump.')
parser.add_argument('--output-bucket', metavar='S3BUCKET', type=str, help='An S3 bucket for holding processed files', dest="output_bucket")
parser.add_argument('--output-prefix', metavar='S3KEY', type=str, help='An S3 bucket for holding processed files', dest="output_prefix")

# Recursively delete the provided path
def rm(path):
    if os.path.isfile(path):
        os.remove(path)
    else if os.path.isdir(path):
        shutil.rmtree(path, True)

# Construct full key (including datetime) to filename
def construct_key(prefix, filename, suffix):
    date = (datetime.now() - timedelta(days=1)).strftime('%Y-%m-%d')
    return "{}/{}-{}.{}".format(prefix, filename, date, suffix)


if __name__ == "__main__":
    args = parser.parse_args()
    client = boto3.client('s3')
    local_snapshot_pbf = "/tmp/data/planet.osm.pbf"
    local_history_pbf = "/tmp/data/planet.osh.pbf"
    local_changeset_xmlbz2 = "/tmp/data/planet.osc.xml.bz2"
    local_changeset_xml = "/tmp/data/planet.osc.xml"
    local_history_orc = "/tmp/data/planet.osh.orc"
    local_snapshot_orc = "/tmp/data/planet.osm.orc"
    local_changeset_orc = "/tmp/data/planet.osc.orc"

    fname = "???"
    # history
    client.download_file(args.output_bucket, construct_key(args.output_prefix, fname, "osh.pbf"), local_history_pbf)
    subprocess.call(['osm2orc', local_history_pbf, local_history_orc])
    client.upload_file(local_history_orc, args.output_bucket, construct_key(args.output_prefix, fname, "osh.orc"))
    rm(local_history_pbf)
    rm(local_history_orc)

    # snapshot
    client.download_file(args.output_bucket, construct_key(args.output_prefix, fname, "osm.pbf"), local_snapshot_pbf)
    subprocess.call(['osm2orc', local_snapshot_pbf, local_snapshot_orc])
    client.upload_file(local_snapshot_orc, args.output_bucket, construct_key(args.output_prefix, fname, "osm.orc"))
    rm(local_snapshot_pbf)
    rm(local_snapshot_orc)

    # changeset
    client.download_file(args.output_bucket, construct_key(args.output_prefix, fname, "osc.xml.bz2"), local_changeset_xmlbz2)
    subprocess.call(['lbzip2', "-d", local_changeset_xmlbz2])
    subprocess.call(['osm2orc', "--changesets", local_changeset_xml, local_changeset_orc])
    client.upload_file(local_changeset_orc, args.output_bucket, construct_key(args.output_prefix, fname, "osc.orc"))


