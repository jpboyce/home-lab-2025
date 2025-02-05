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
variable "ubuntu_iso_file" {
    type = string                   # The path of the ISO file to boot from
}
variable "iso_storage_pool" {
    type = string                   # The name of the storage pool where the ISO file is located
}
variable "vm_storage_pool" {
    type = string                   # The name of the storage pool where the VM disk will be created
    default = "local-lvm"
}
variable "virtio_iso_file" {
    type = string                   # The path of the VirtIO ISO file to install drivers from
}
variable "cores" {
    type = number                   # The number of CPU cores to allocate to the VM
    default = 4
}
variable "sockets" {
    type = number                   # The number of CPU sockets to allocate to the VM
    default = 1
}
variable "memory" {
    type = number                   # The amount of memory in MB to allocate to the VM
    default = 8192
}
variable "disk_size" {
    type = string                   # The size of the disk in GB
    default = "32G"
}

# Proxmox plugin
packer {
    required_plugins {
        proxmox = {
            version = ">= 1.2.2"
            source = "github.com/hashicorp/proxmox"
        }
    }
}

source "proxmox-iso" "ubuntu" {
    # Connection Settings
    proxmox_url = "${var.proxmox_url}"
    username = "${var.proxmox_username}"
    token = "${var.proxmox_password}"
    insecure_skip_tls_verify = true

    node = "${var.proxmox_node}"
    vm_name = "ubuntu-base"
    template_description = "Ubuntu 20.04.3 LTS - Built on ${formatdate("YYYY-MM-DD hh:mm:ss ZZZ", timestamp())}"

    # ISO Settings
    #iso_file = "${var.ubuntu_iso_file}"                        # The path of the ISO file to boot from
    boot_iso {
        iso_file = "${var.ubuntu_iso_file}"                # The path of the ISO file to boot from
        unmount = false                                 # The default is false, true unmounts the ISO after installation
        type = "scsi"                                       
    }
    #iso_storage_pool = "${var.iso_storage_pool}"        # The name of the storage pool where the ISO file is located
    #unmount_iso = false                                 # The default is false, true unmounts the ISO after installation

    # Extra drive for VirtIO drivers
    #additional_iso_files {
    #    unmount = true              # The default is false, true unmounts the ISO after installation
    #    device = "sata5"
    #    iso_file = "${var.virtio_iso_file}"
    #}

    # VM Hard Disk Settings
    scsi_controller = "virtio-scsi-single" # The default is lsi, but we are setting this to virtio-scsi-single for best performance
    disks {
        type = "virtio"             # The default for type is scsi, but we are setting this to virtio for best performance
        storage_pool = "${var.vm_storage_pool}"  # The name of the storage pool where the disk will be created
        disk_size = "${var.disk_size}" # The size of the disk in GB
        cache_mode = "none"         # The default is none
        #format = "qcow2"            # This will depend on your backing storage, block storage such as LVM/ZFS/Ceph require raw, 
                                    # while file storage such as NFS support qcow2 or raw
                                    # qcows2 allows snapshots and thin provisioning
        io_thread = true            # The default is false, true improves performance but requires a virtio-scsci-single controller
        discard = false             # The default is false, true enables TRIM support
        ssd = false                 # The default is false, true enables SSD emulation
    }

    # VM CPU Settings
    cores = var.cores        # The default is 1
    sockets = var.sockets    # The default is 1

    # VM Memory Settings
    memory = var.memory      # The default is 512, but we are setting this to 2048 for best performance

    # VM Network Settings
    network_adapters {
        model = "virtio"    # The default for model is E1000, but we are setting this to virtio for best performance
        packet_queues = 0   # The default is 0. Set to the number of CPU cores for best performance
        bridge = "vmbr0"    # The default bridge is vmbr0, but you can change this to any bridge you have configured
        firewall = false    # The default is false, but you can set this to true if you want to enable the firewall
    }

    # Other VM Settings
    os = "l26"            # The default is other, but we are setting this to win11 for Windows 2022
    machine = "pc"         # The default is pc, but we are setting this to q35
    qemu_agent = true       # The default is true, but you can set this to false if you don't want to install the QEMU agent
    #cd_files = ["./http/meta-data", "./http/user-data"] # The path to the cloud-init files
    boot_command = [ 
        #"<esc><wait>",
        "c", 
        "linux /casper/vmlinuz -- autoinstall ds='nocloud-net;s=http://192.168.1.3:{{ .HTTPPort }}/'",
        "<enter><wait><wait>", 
        "initrd /casper/initrd", 
        "<enter><wait><wait>", 
        "boot<enter>"
        ]
    boot_wait = "13s"

    # x
    http_directory = "./http"  # The path to the directory containing the cloud-init files
    ssh_username = "ubuntu"
    ssh_password = "ubuntu"
    ssh_timeout = "20m"



}

# Build the VM
build {
    sources = ["source.proxmox-iso.ubuntu"]
}
