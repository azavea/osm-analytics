import os
import json
import boto3

from datetime import datetime, timedelta

environment = os.getenv('ENVIRONMENT', 'Staging')

emr = boto3.client('emr')

s3_log_dir = "s3://some/path/for/logs"
emr_bid_price = ""

def handler(event, context):
    date = (datetime.now() - timedelta(days=1)).strftime('%Y-%m-%d')

    response = emr.run_job_flow(
        Name='OSM Statistics Generation',
        LogUri=s3_log_dir,
        ReleaseLabel='emr-5.12.0',
        Instances={
            'MasterInstanceType': 'm5.xlarge',
            'SlaveInstanceType': 'm5.2xlarge',
            'InstanceCount': 101,
            'InstanceGroups': [
              {
                'Name': 'Master',
                'Market': 'SPOT',
                'InstanceRole': 'MASTER',
                'BidPrice': emr_bid_price,
                'InstanceType': 'm5.xlarge',
                'InstanceCount': 100,
                'Configurations': [
                  {
                    "Classification": "spark",
                    "Properties": {
                      "maximizeResourceAllocation": "false"
                    }
                  },
                  {
                    "Classification": "spark-defaults",
                    "Properties": {
                      "spark.driver.maxResultSize": "3G",
                      "spark.dynamicAllocation.enabled": "true",
                      "spark.shuffle.service.enabled": "true",
                      "spark.shuffle.compress": "true",
                      "spark.shuffle.spill.compress": "true",
                      "spark.rdd.compress": "true",
                      "spark.yarn.executor.memoryOverhead": "1G",
                      "spark.yarn.driver.memoryOverhead": "1G",
                      "spark.driver.maxResultSize": "3G",
                      "spark.executor.extraJavaOptions" : "-XX:+UseParallelGC -Dgeotrellis.s3.threads.rdd.write=64"
                    }
                  },
                  {
                    "Classification": "hdfs-site",
                    "Properties": {
                      "dfs.replication": "1",
                      "dfs.permissions": "false",
                      "dfs.datanode.max.xcievers": "16384",
                      "dfs.datanode.max.transfer.threads": "16384",
                      "dfs.datanode.balance.max.concurrent.moves": "1000",
                      "dfs.datanode.balance.bandwidthPerSec": "100000000"
                    }
                  },
                  {
                    "Classification": "yarn-site",
                    "Properties": {
                      "yarn.resourcemanager.am.max-attempts": "1",
                      "yarn.nodemanager.vmem-check-enabled": "false",
                      "yarn.nodemanager.pmem-check-enabled": "false"
                    }
                  },
                  {
                    "Classification": "hadoop-env",
                    "Configurations": [
                      {
                        "Classification": "export",
                        "Properties": {
                          "JAVA_HOME": "/usr/lib/jvm/java-1.8.0",
                          "GDAL_DATA": "/usr/local/share/gdal",
                          "LD_LIBRARY_PATH": "/usr/local/lib",
                          "PYSPARK_PYTHON": "python27",
                          "PYSPARK_DRIVER_PYTHON": "python27"
                        }
                      }
                    ]
                  },
                  {
                    "Classification": "spark-env",
                    "Configurations": [
                      {
                        "Classification": "export",
                        "Properties": {
                          "JAVA_HOME": "/usr/lib/jvm/java-1.8.0",
                          "GDAL_DATA": "/usr/local/share/gdal",
                          "LD_LIBRARY_PATH": "/usr/local/lib",
                          "SPARK_PRINT_LAUNCH_COMMAND": "1",
                          "PYSPARK_PYTHON": "python27",
                          "PYSPARK_DRIVER_PYTHON": "python27"
                        }
                      }
                    ]
                  },
                  {
                    "Classification": "yarn-env",
                    "Configurations": [
                      {
                        "Classification": "export",
                        "Properties": {
                          "JAVA_HOME": "/usr/lib/jvm/java-1.8.0",
                          "GDAL_DATA": "/usr/local/share/gdal",
                          "LD_LIBRARY_PATH": "/usr/local/lib",
                          "PYSPARK_PYTHON": "python27",
                          "PYSPARK_DRIVER_PYTHON": "python27"
                        }
                      }
                    ]
                  }
                ]
              }
            ],
            'InstanceFleets': [
                {
                    'Name': 'string',
                    'InstanceFleetType': 'MASTER'|'CORE'|'TASK',
                    'TargetOnDemandCapacity': 123,
                    'TargetSpotCapacity': 123,
                    'InstanceTypeConfigs': [
                        {
                            'InstanceType': 'string',
                            'WeightedCapacity': 123,
                            'BidPrice': 'string',
                            'BidPriceAsPercentageOfOnDemandPrice': 123.0,
                            'EbsConfiguration': {
                                'EbsBlockDeviceConfigs': [
                                    {
                                        'VolumeSpecification': {
                                            'VolumeType': 'string',
                                            'Iops': 123,
                                            'SizeInGB': 123
                                        },
                                        'VolumesPerInstance': 123
                                    },
                                ],
                                'EbsOptimized': True|False
                            },
                            'Configurations': [
                                {
                                    'Classification': 'string',
                                    'Configurations': {'... recursive ...'},
                                    'Properties': {
                                        'string': 'string'
                                    }
                                },
                            ]
                        },
                    ],
                    'LaunchSpecifications': {
                        'SpotSpecification': {
                            'TimeoutDurationMinutes': 123,
                            'TimeoutAction': 'SWITCH_TO_ON_DEMAND'|'TERMINATE_CLUSTER',
                            'BlockDurationMinutes': 123
                        }
                    }
                },
            ],
            'Ec2KeyName': 'string',
            'Placement': {
                'AvailabilityZone': 'string',
                'AvailabilityZones': [
                    'string',
                ]
            },
            'KeepJobFlowAliveWhenNoSteps': False,
            'TerminationProtected': False,
            'HadoopVersion': '2.8.3',
            'Ec2SubnetId': 'string',
            'Ec2SubnetIds': [ 'string', ],
            'EmrManagedMasterSecurityGroup': 'string',
            'EmrManagedSlaveSecurityGroup': 'string',
            'ServiceAccessSecurityGroup': 'string'
        },
        Steps=[
            {
                'Name': 'string',
                'ActionOnFailure': 'TERMINATE_CLUSTER',
                'HadoopJarStep': {
                    'Properties': [
                        {
                            'Key': 'string',
                            'Value': 'string'
                        },
                    ],
                    'Jar': 'string',
                    'MainClass': 'osmesa.analytics.oneoffs.StatsJobCommand',
                    'Args': [
                        '', ''
                    ]
                }
            },
            {
                'Name': 'string',
                'ActionOnFailure': 'TERMINATE_CLUSTER',
                'HadoopJarStep': {
                    'Properties': [
                        {
                            'Key': 'string',
                            'Value': 'string'
                        },
                    ],
                    'Jar': 'string',
                    'MainClass': 'osmesa.analytics.oneoffs.FootprintByCampaign',
                    'Args': [
                        'string',
                    ]
                }
            },
            {
                'Name': 'string',
        ],
        BootstrapActions=[
            {
                'Name': 'string',
                'ScriptBootstrapAction': {
                    'Path': 'string',
                    'Args': [
                        'string',
                    ]
                }
            },
        ],
        SupportedProducts=[
            'string',
        ],
        NewSupportedProducts=[
            {
                'Name': 'string',
                'Args': [
                    'string',
                ]
            },
        ],
        Applications= [
            {
                'Name': 'Ganglia',
                'Version': 'string',
                'Args': [
                    'string',
                ]
            },
            {
                'Name': 'Hadoop',
                'Version': 'string',
                'Args': [
                    'string',
                ]
            },
            {
                'Name': 'Hue',
                'Version': 'string',
                'Args': [
                    'string',
                ]
            },
            {
                'Name': 'Spark',
                'Version': 'string',
                'Args': [
                    'string',
                ]
            },
            {
                'Name': 'Zeppelin',
                'Version': 'string',
                'Args': [
                    'string',
                ]
            }
        ],
        Configurations=[
            {
                'Classification': 'string',
                'Configurations': {'... recursive ...'},
                'Properties': {
                    'string': 'string'
                }
            },
        ],
        VisibleToAllUsers=True|False,
        JobFlowRole='string',
        ServiceRole='string',
        Tags=[
            {
                'Key': 'string',
                'Value': 'string'
            },
        ],
        SecurityConfiguration='string',
        AutoScalingRole='string',
        ScaleDownBehavior='TERMINATE_AT_INSTANCE_HOUR'|'TERMINATE_AT_TASK_COMPLETION',
        CustomAmiId='string',
        EbsRootVolumeSize=123,
        RepoUpgradeOnBoot='SECURITY'|'NONE',
        KerberosAttributes={
            'Realm': 'string',
            'KdcAdminPassword': 'string',
            'CrossRealmTrustPrincipalPassword': 'string',
            'ADDomainJoinUser': 'string',
            'ADDomainJoinPassword': 'string'
        }
    )

    print(json.dumps(response, indent=2))

