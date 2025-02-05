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
  endpoint = "https://proxmox.example.com:8006/api2/json"
  api_token = "password"
  ssh {
    agent = true
    username = "terraform"
  }
}

resource "proxmox_virtual_environment_vm" "test" {
  name = "test"
  node_name = "pve2"
  clone {
    vm_id = proxmox_virtual_environment_vm.ubuntu_template.id
  }

  agent {
    enabled = true
  }
  memory {
    dedicated = 512
  }

  initialization {
    dns {
        servers = ["1.1.1.1"]
    }
    ip_config {
        ipv4 {
            address = "dhcp"
        }
  }
  }
}
