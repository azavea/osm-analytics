#!/usr/bin/env python
import os
import subprocess
import boto3

orc_bucket = os.environ["PGDUMP_BUCKET"]
orc_key = os.environ["PGDUMP_KEY"]
pbf_bucket = os.environ["PBF_BUCKET"]
history_key = os.environ["HISTORY_KEY"]
snapshot_key = os.environ["SNAPSHOT_KEY"]
changeset_key = os.environ["CHANGESET_KEY"]
local_pgdump = "/tmp/osm.pgdump"
local_history = "/tmp/planet.osh.pbf"
local_snapshot = "/tmp/planet.osm.pbf"
local_changesets = "/tmp/planet.osc.xml.bz2"

client = boto3.client('s3')
client.download_file(pgdump_bucket, pgdump_key, local_pgdump)
subprocess.call(['/bin/planet-dump-ng',
    "-f", local_pgdump,
    "--history-pbf", local_history,
    "--pbf", local_snapshot,
    "--changesets", local_changesets
])
client.upload_file("/tmp/planet.osh.orc", pbf_bucket, history_key)
client.upload_file("/tmp/planet.osm.orc", pbf_bucket, snapshot_key)
client.upload_file("/tmp/planet.osc.xml.bz2", pbf_bucket, changeset_key)


