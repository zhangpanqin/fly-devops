terraform {
  required_version = ">= 1.1.7"

  backend "local" {
    path = "relative/terraform.tfstate"
  }
}
