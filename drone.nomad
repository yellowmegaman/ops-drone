job "drone" {
  datacenters = ["[[.common.dc]]"]
  type = "service"
  group "drone" {
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
    task "drone" {
      kill_timeout = "180s"
      env {
	DRONE_GITHUB_SERVER        = "https://github.com"
	DRONE_GITHUB_CLIENT_ID     = "[[.github.client]]"
	DRONE_GITHUB_CLIENT_SECRET = "[[.github.secret]]"
	DRONE_SERVER_HOST          = "[[.common.dc]].[[.common.domain]]"
	DRONE_SERVER_PROTO         = "https"
	DRONE_REPOSITORY_FILTER    = "[[.github.org]]"
        DRONE_SERVER_PORT          = ":[[.drone.port]]"
        DRONE_LOGS_COLOR           = "false"
        DRONE_LOGS_DEBUG           = "true"
        DRONE_LOGS_PRETTY          = "false"
        DRONE_RPC_SECRET           = "[[.drone.rpc_secret]]"
        DRONE_TLS_AUTOCERT         = "false"
        DRONE_USER_CREATE          = "username:[[.drone.admin_user]],admin:true,token:[[.drone.token]]"
        DRONE_USER_FILTER          = "[[.github.org]],[[.drone.admin_user]]"
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
        image              = "[[.drone.image]]:[[.drone.tag]]"
        hostname           = "${attr.unique.hostname}"
        dns_servers        = ["${attr.unique.network.ip-address}"]
        dns_search_domains = ["consul","service.consul","node.consul"]
        volumes            = [
          "/opt/drone:/data"
        ]
      }
      resources {
        memory  = "[[.drone.ram]]"
        network {
          mbits = 10
          port "healthcheck" { static = "[[.drone.port]]" }
        } #network
      } #resources
      service {
        name = "drone"
        tags = ["[[.drone.tag]]"]
        port = "healthcheck"
        check {
          name     = "drone-internal-port-check"
          port     = "healthcheck"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        } #check
      } #service
    } #task
  } #group
} #job
