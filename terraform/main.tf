terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "~> 2.9.11"
    }
  }
}

provider "proxmox" {
  pm_api_url      = "https://your-proxmox-server:8006/api2/json"
  pm_api_token_id = "terraform@pam!api-token"
  pm_api_token_secret = "your-secret-token"
  pm_tls_insecure = true  # Set to false if you have valid SSL
}


resource "proxmox_vm_qemu" "ubuntu" {
  name = var.ubuntu_template
  target_node = "pve2"
  clone = var.ubuntu_template

  # VM Hardware configuration
  cores = 2
  sockets = 1
  memory = 2048
  network {
    model = "virtio"
    bridge = "vmbr0"
  }
  disk {
    size = "32G"
    type = "scsi"
    storage = "local-lvm"
    iothread = true
  }

  # Network configuration
  ipconfig0 = "ip=dhcp"

  # Provisioning configuration
  # provisioner "remote-exec" {
  #   inline = [
  #     "echo 'Provisioning Ubuntu VM'",
  #     "apt-get update",
  #     "apt-get install -y apache2"
  #   ]
  # }
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
