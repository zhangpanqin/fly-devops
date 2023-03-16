terraform {
  cloud {
    organization = "mflyyou"
    workspaces {
      name = "learn-terraform-import"
    }
  }

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.17.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }

  required_version = "~> 1.2"
}
provider "random" {
}
provider "docker" {
  # 兼容 colima
  host = "unix:///Users/panqinzhang/.colima/docker.sock"
}
