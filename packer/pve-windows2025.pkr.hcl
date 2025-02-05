# Variable definitions
variable "proxmox_url" {
    type = string                   # The URL of the Proxmox server in the format of https://<IP>:<PORT>/api2/json
}
variable "proxmox_username" {
    type = string                   # The username to authenticate with the Proxmox server
}
variable "proxmox_password" {
    type = string                   # The password to authenticate with the Proxmox server
}
variable "proxmox_node" {
    type = string                   # The name of the Proxmox node to create the VM on
}
variable "win2025_iso_file" {
    type = string                   # The path of the ISO file to boot from
}
variable "iso_storage_pool" {
    type = string                   # The name of the storage pool where the ISO file is located
}
variable "vm_storage_pool" {
    type = string                   # The name of the storage pool where the VM disk will be created
}
variable "virtio_iso_file" {
    type = string                   # The path of the VirtIO ISO file to install drivers from
}
# Proxmox plugin
packer {
    required_plugins {
        proxmox = {
            version = "~> 1"
            source = "github.com/hashicorp/proxmox"
        }
    }
}

source "proxmox-iso" "windows2025" {
    # Connection Settings
    proxmox_url = "${var.proxmox_url}"
    username = "${var.proxmox_username}"
    token = "${var.proxmox_password}"
    insecure_skip_tls_verify = true

    node = "${var.proxmox_node}"
    vm_name = "windows2025-base"
    template_description = "Windows 2025 Base"

    # ISO Settings
    iso_file = "${var.win2025_iso_file}"                        # The path of the ISO file to boot from
    iso_storage_pool = "${var.iso_storage_pool}"        # The name of the storage pool where the ISO file is located
    unmount_iso = false                                 # The default is false, true unmounts the ISO after installation

    # Extra Drive for AutoUnattend.xml
    additional_iso_files {
        unmount = true              # The default is false, true unmounts the ISO after installation
        iso_storage_pool = "${var.iso_storage_pool}"
        device = "sata4"
        cd_files = [
            "answer_files/2025/proxmox/autounattend.xml", # The path to the answer file to use for the installation
            "scripts/windows/proxmox-bootstrap.ps1"        # The path to the script to bootstrap
        ]
    }
    # Extra drive for VirtIO drivers
    additional_iso_files {
        unmount = true              # The default is false, true unmounts the ISO after installation
        device = "sata5"
        iso_file = "${var.virtio_iso_file}"
    }

    # VM Hard Disk Settings
    scsi_controller = "virtio-scsi-single" # The default is lsi, but we are setting this to virtio-scsi-single for best performance
    disks {
        type = "virtio"             # The default for type is scsi, but we are setting this to virtio for best performance
        storage_pool = "${var.vm_storage_pool}"  # The name of the storage pool where the disk will be created
        disk_size = "50G"           # The size of the disk in GB
        cache_mode = "none"         # The default is none
        io_thread = true            # The default is false, true improves performance but requires a virtio-scsci-single controller
        discard = false             # The default is false, true enables TRIM support
        ssd = false                 # The default is false, true enables SSD emulation
    }

    # VM CPU Settings
    cores = 2

    # VM Memory Settings
    memory = 8192           

    # VM Network Settings
    network_adapters {
        model = "virtio"    # The default for model is E1000, but we are setting this to virtio for best performance
        packet_queues = 0   # The default is 0. Set to the number of CPU cores for best performance
        bridge = "vmbr0"    # The default bridge is vmbr0, but you can change this to any bridge you have configured
        firewall = false    # The default is false, but you can set this to true if you want to enable the firewall
    }

    # Other VM Settings
    os = "win11"            # The default is other, but we are setting this to win11 for Windows 2025
    machine = "q35"         # The default is pc, but we are setting this to q35 for Windows 2025?
    qemu_agent = true       # The default is true, but you can set this to false if you don't want to install the QEMU agent
    boot_command = ["<spacebar><spacebar>"]
    boot_wait = "13s"

    # Communicator options
    communicator = "winrm"
    winrm_use_ssl = false
    winrm_insecure = true
    #winrm_timeout = "3m"
    winrm_username = "packer"
    winrm_password = "packer"


}

# Build the Windows 2025 Base VM
build {
    sources = ["source.proxmox-iso.windows2025"]
}
