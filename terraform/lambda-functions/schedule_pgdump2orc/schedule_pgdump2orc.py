import os
import json
import boto3

from datetime import datetime, timedelta

environment = os.getenv('ENVIRONMENT')
pgdump_bucket = os.getenv('PGDUMP_BUCKET')
orc_bucket = os.getenv('ORC_BUCKET')

# pgdump bucket
# output bucket
# output pbf prefix
# output orc prefix

date = (datetime.now() - timedelta(days=1)).strftime('%Y-%m-%d')
history_object = "{}.osh.pbf".format(date)
snapshot_object = "{}.osh.pbf".format(date)
changeset_object = "{}.osh.pbf".format(date)

client = boto3.client('batch')


def handler(event, context):
    print(event)
    head_rec = event['Records'][0]
    s3key = head_rec['s3']['object']['key']

    key_split = s3key.split('/')
    pbfpath = '/'.join(key_split[0:-1])
    pbfpath = '/'.join(key_split[0:-1])
    s3object = key_split[-1]

    pgdump_response = client.submit_job(
        jobName='pgdump2pbf-{}-{}'.format(pgdump_bucket, s3key, date),
        jobQueue='queue{}PGDump2ORC'.format(environment),
        jobDefinition=event['jobDefinition'],
        parameters={
            'pgdump-bucket': pgdump_bucket,
            'pgdump-key': pgdump-key,
            'pbf-bucket': output_bucket,
            'history-key-pbf': output_bucket + '/' + history_object,
            'snapshot-key-pbf': output_bucket + '/' + snapshot_object,
            'changeset-key-xml': output_bucket + '/' + changeset_object
        }
    )

    orc_response = client.submit_job(
        jobName='pbf2orc-{}-{}'.format(orc_bucket, s3key, date),
        jobQueue='queue{}PGDump2ORC'.format(environment),
        jobDefinition=event['jobDefinition'],
        dependsOn: ['pgdump2pbf-{}-{}'.format(s3key, date)],
        parameters={
            'pbf-bucket': output_bucket,
            'history-key-pbf': s3path + '/' + history_object,
            'snapshot-key-pbf': s3path + '/' + snapshot_object,
            'changeset-key-xml': s3path + '/' + changeset_object
            pbf-bucket = "${aws_s3_bucket.osm_pgdump.bucket}",
            pbf-history-key = "${var.output_prefix}planet.osh.pbf",
            pbf-snapshot-key = "${var.output_prefix}planet.osm.pbf",
            xml-changeset-key = "${var.output_prefix}planet.osc.pbf",
            orc-bucket = "${aws_s3_bucket.osm_orc.bucket}",
            orc-history-key = "${var.output_prefix}planet.osh.orc",
            orc-snapshot-key = "${var.output_prefix}planet.osm.orc",
            orc-changeset-key = "${var.output_prefix}planet.osc.orc"
        }
    )

    print(json.dumps({ "pgdump_job": pgdump_response, "orc_job": orc_response }, indent=2))

