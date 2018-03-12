import os
import json
import boto3

from datetime import datetime, timedelta

environment = os.getenv('ENVIRONMENT', 'Staging')

batch = boto3.client('batch')


def handler(event, context):
    date = (datetime.now() - timedelta(days=1)).strftime('%Y-%m-%d')

    response = batch.submit_job(
        jobName='{}-{}'.format(event['jobDefinition'], date),
        jobQueue='queue{}Default'.format(environment),
        jobDefinition=event['jobDefinition'],
        parameters={
            'date': date
        }
    )

    print(json.dumps(response, indent=2))

