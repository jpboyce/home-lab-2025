# ProxMox Variables
proxmox_url = "https://<Proxmox Host>:8006/api2/json" # Proxmox Host URL
proxmox_username = "packer@pve!templates" # Packer API user
proxmox_password = "<token>" # Packer API user token
proxmox_node = "pve2" # Proxmox Node

# Storage Pool Variables
iso_storage_pool = "local"
vm_storage_pool = "local-lvm"

# Windows ISO and VirtIO ISO Variables
win2025_iso_file = "local:iso/26100.1742.240906-0331.ge_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso"
win2022_iso_file = "local:iso/SERVER_EVAL_x64FRE_en-us.iso"
virtio_iso_file = "local:iso/virtio-win-0.1.240.iso"

# Ubuntu ISO Variables
ubuntu_iso_file = "local:iso/ubuntu-24.04.1-live-server-amd64.iso"
