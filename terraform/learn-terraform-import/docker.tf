resource "docker_container" "web" {
  command = [
    "nginx",
    "-g",
    "daemon off;",
  ]
  cpu_shares = 0
  dns        = []
  dns_opts   = []
  dns_search = []
  entrypoint = [
    "/docker-entrypoint.sh",
  ]
  group_add         = []
  hostname          = "58975c109f62"
  image             = "sha256:9eee96112defa9d7b1880f18e76e174537491bcec6e31ad9a474cdea40f5abab"
  init              = false
  ipc_mode          = "private"
  log_driver        = "json-file"
  log_opts          = {}
  max_retry_count   = 0
  memory            = 0
  memory_swap       = 0
  name              = "hashicorp-learn"
  network_mode      = "default"
  privileged        = false
  publish_all_ports = false
  read_only         = false
  restart           = "no"
  rm                = false
  security_opts     = []
  shm_size          = 64
  stdin_open        = false
  storage_opts      = {}
  sysctls           = {}
  tmpfs             = {}
  tty               = false
  env               = []

  ports {
    external = 8080
    internal = 80
    ip       = "::"
    protocol = "tcp"
  }
  ports {
    external = 8080
    internal = 80
    ip       = "::"
    protocol = "tcp"
  }
}
