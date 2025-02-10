terraform {
  required_version = ">= 0.12"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.70.1"
    }
  }
}
provider "proxmox" {
  endpoint = var.virtual_environment_endpoint
  api_token = var.virtual_environment_api_token
  insecure = true
  ssh {
    agent = true
    username = "terraform"
  }
}

# Template resources
#resource "proxmox_virtual_environment_vm" "ubuntu" {
#  name = var.ubuntu_template
#  node_name = "pve2"
#}
#
#resource "proxmox_virtual_environment_vm" "windows2022" {
#  name = var.windows2022_template
#  node_name = "pve2"
#}

# Virtual Machine resources
resource "proxmox_virtual_environment_vm" "svr31" {
  name = var.vmconfig["svr31"]["name"]
  node_name = "pve2"
  description = var.vmconfig["svr31"]["description"]
  clone {
    vm_id = var.ubuntu_template
  }

  agent {
    enabled = true
  }
  cpu {
    cores = var.vmconfig["svr31"]["cores"]
  }
  memory {
    dedicated = var.vmconfig["svr31"]["memory"]
  }

  initialization {
    dns {
        servers = ["1.1.1.1"]
    }
    ip_config {
        ipv4 {
            address = var.vmconfig["svr31"]["ip_address"]
            gateway = var.vmconfig["svr31"]["gateway"]
        }
  }
  }
}
