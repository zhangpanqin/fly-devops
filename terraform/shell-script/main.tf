terraform {
  required_version = ">= 1.1.7"

  required_providers {
    shell = {
      source  = "scottwinkler/shell"
      version = "~> 1.7.10"
    }
  }
}

provider "shell" {
}

data "shell_script" "styra_system" {
  for_each = var.bound_styra_systems
  lifecycle_commands {
    read = "/bin/bash ${path.module}/system/read.sh"
  }
  environment = {
    SYSTEM_NAME = each.value
  }
  working_directory = path.module
}

resource "shell_script" "styra_system_policy_edit_rolebinding" {
  for_each = var.bound_styra_systems

  lifecycle_commands {
    create = "/bin/bash ${path.module}/rolebings/create.sh"
    delete = "/bin/bash ${path.module}/rolebings/delete.sh"
  }

  environment = {
    MY_NAME         = "PANQIN2"
    RESOURCE_FILTER = jsonencode({ id = data.shell_script.styra_system[each.key].output["system_id"], kind = "system" })
  }

  working_directory = path.module
}
