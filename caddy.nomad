job "caddy" {
  datacenters = ["[[.common.dc]]"]
  type = "service"
  group "caddy" {
    count = "1"
    task "caddy" {
      template {
        data = <<EOH
[[.common.dc]].[[.common.domain]] {
  proxy / localhost:[[.drone.port]] {
     websocket
     transparent
  }
}
as[[.common.dc]].[[.common.domain]] {
  proxy / localhost:[[.autoscaler.port]] {
     websocket
     transparent
  }
}
EOH
        destination         = "local/caddyfile"
        change_mode         = "signal"
        change_signal       = "SIGHUP"
      }
      artifact {
        source = "https://github.com/mholt/caddy/releases/download/v[[.caddy.version]]/caddy_v[[.caddy.version]]_linux_amd64.tar.gz"
      }
      driver = "raw_exec"
      config {
        command = "caddy"
        args    = ["-agree=true", "-conf=local/caddyfile", "-email=[[.common.email]]"]
      }
      resources {
        cpu    = 100
        memory = "[[.autoscaler.ram]]"
        network {
          mbits = 10
          port "healthcheck" { static = 80 }
        }
      }
      service {
        name = "caddy"
        tags = ["v[[.caddy.version]]"]
        port = "healthcheck"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
