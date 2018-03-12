#cloud-config

packages:
 - awslogs

runcmd:
  - curl -o /etc/papertrail-bundle.pem https://papertrailapp.com/tools/papertrail-bundle.pem

write_files:
  - path: /etc/awslogs/awslogs.conf
    permissions: 0644
    owner: root:root
    content: |
      [general]
      state_file = /var/lib/awslogs/agent-state

      [/var/log/dmesg]
      file = /var/log/dmesg
      log_group_name = log${environment}ContainerInstance
      log_stream_name = dmesg/{instance_id}

      [/var/log/messages]
      file = /var/log/messages
      log_group_name = log${environment}ContainerInstance
      log_stream_name = messages/{instance_id}
      datetime_format = %b %d %H:%M:%S

      [/var/log/docker]
      file = /var/log/docker
      log_group_name = log${environment}ContainerInstance
      log_stream_name = docker/{instance_id}
      datetime_format = %Y-%m-%dT%H:%M:%S.%f

      [/var/log/ecs/ecs-init.log]
      file = /var/log/ecs/ecs-init.log.*
      log_group_name = log${environment}ContainerInstance
      log_stream_name = ecs-init/{instance_id}
      datetime_format = %Y-%m-%dT%H:%M:%SZ

      [/var/log/ecs/ecs-agent.log]
      file = /var/log/ecs/ecs-agent.log.*
      log_group_name = log${environment}ContainerInstance
      log_stream_name = ecs-agent/{instance_id}
      datetime_format = %Y-%m-%dT%H:%M:%SZ

  - path: /etc/init/awslogs.conf
    permissions: 0644
    owner: root:root
    content: |
      description "Configure and start CloudWatch Logs agent on Amazon ECS container instance"
      author "Amazon Web Services"
      start on started ecs

      script
          exec 2>>/var/log/ecs/cloudwatch-logs-start.log
          set -x

          until curl -s http://localhost:51678/v1/metadata
          do
              sleep 1
          done

          service awslogs start
          chkconfig awslogs on
      end script

  - path: /var/lib/statsd/config.js
    permissions: 0644
    owner: root:root
    content: |
      {
          , backends: ["statsd-librato-backend"]
          , port: 8125
          , keyNameSanitize: false
          , deleteIdleStats: true
      }
