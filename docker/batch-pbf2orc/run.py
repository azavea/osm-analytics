#!/usr/bin/env python
import os
import subprocess
import boto3

history_bucket = os.environ["HISTORY_BUCKET"]
history_key = os.environ["HISTORY_KEY"]
changeset_bucket = os.environ["CHANGESET_BUCKET"]
changeset_key = os.environ["CHANGESET_KEY"]
orc_bucket = os.environ["ORC_BUCKET"]
orc_key = os.environ["ORC_KEY"]

client = boto3.client('s3')
client.download_file(history_bucket, history_key, "/tmp/planet.osh.pbf")
client.download_file(changeset_bucket, changeset_key, "/tmp/planet.osc.xml.bz2")
subprocess.call(['osm2orc', "/tmp/planet.osh.pbf", "/tmp/planet.osh.orc"])
subprocess.call(['lbzip2', "-d", "/tmp/planet.osc.xml.bz2"])
subprocess.call(['osm2orc', "--changesets", "/tmp/planet.osc.xml", "/tmp/planet.osc.orc"])
client.upload_file("/tmp/planet.osh.orc", orc_bucket, orc_key)


