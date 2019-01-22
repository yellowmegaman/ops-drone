job "autoscaler" {
  datacenters = ["[[.common.dc]]"]
  type = "service"
  group "autoscaler" {
    update {
      stagger = "10s"
      max_parallel = 1
    }
    count = "1"
    restart {
      attempts = 5
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }
    task "autoscaler" {
      kill_timeout = "180s"
      env {
        CONSUL                     = "${attr.unique.hostname}.node.${attr.consul.datacenter}.consul"
        DRONE_HTTP_HOST            = "${attr.unique.hostname}"
        DRONE_HTTP_PORT            = ":[[.autoscaler.port]]"
        DRONE_INTERVAL             = "[[.autoscaler.interval]]"
        DRONE_POOL_MIN             = "[[.autoscaler.min]]"
        DRONE_POOL_MAX             = "[[.autoscaler.max]]"
        DRONE_POOL_MIN_AGE         = "[[.autoscaler.age]]"
        DRONE_SERVER_PROTO         = "[[.autoscaler.proto]]"
        DRONE_SERVER_HOST          = "[[.common.dc]].[[.common.domain]]"
        DRONE_SERVER_TOKEN         = "[[.drone.token]]"
        DRONE_AGENT_TOKEN          = "[[.drone.rpc_secret]]"
        DRONE_AGENT_IMAGE          = "[[.agent.image]]:[[.agent.tag]]"
        DRONE_AGENT_CONCURRENCY    = "[[.agent.concurrency]]"
        DRONE_LOGS_PRETTY          = "true"
        DRONE_LOGS_COLOR           = "false"
        DRONE_LOGS_DEBUG           = "true"
        DRONE_GOOGLE_REGION        = "[[.google.zone]]"
        DRONE_GOOGLE_ZONE          = "[[.google.zone]]"
        DRONE_GOOGLE_PROJECT       = "[[.google.project]]"
        DRONE_GOOGLE_MACHINE_IMAGE = "[[.google.project]]/[[.google.image]]"
        DRONE_GOOGLE_MACHINE_TYPE  = "[[.google.machine]]"
        DRONE_GOOGLE_DISK_SIZE     = "[[.google.disk]]"
        DRONE_GOOGLE_TAGS          = "[[.google.tags]]"
	DRONE_DATABASE_DATASOURCE  = "/data/database.sqlite"
      }
      driver = "docker"
      config {
        logging {
            type = "syslog"
            config {
              tag = "${NOMAD_JOB_NAME}${NOMAD_ALLOC_INDEX}"
            }
        }
        network_mode       = "host"
        force_pull         = true
        image              = "[[.autoscaler.image]]:[[.autoscaler.tag]]"
        hostname           = "${attr.unique.hostname}"
        dns_servers        = ["${attr.unique.network.ip-address}"]
        dns_search_domains = ["consul","service.consul","node.consul"]
        volumes            = [
          "/opt/autoscaler:/data"
        ]
      }
      resources {
        memory  = "[[.autoscaler.ram]]"
        network {
          mbits = 10
          port "healthcheck" { static = "[[.autoscaler.port]]" }
        } #network
      } #resources
      service {
        name = "autoscaler"
        tags = ["[[.autoscaler.tag]]"]
        port = "healthcheck"
        check {
          name     = "autoscaler-internal-port-check"
          port     = "healthcheck"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        } #check
      } #service
    } #task
  } #group
} #job
