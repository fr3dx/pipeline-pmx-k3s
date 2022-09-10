# Ubuntu Server Jammy

source "proxmox" "ubuntu-server-jammy" {

  proxmox_url              = "${var.proxmox_api_url}"
  username                 = "${var.proxmox_api_token_id}"
  password                 = "${var.proxmox_api_token_secret}"
  insecure_skip_tls_verify = true

  node                 = "${var.proxmox_node}"
  vm_id                = "${var.proxmox_vm_id}"
  vm_name              = "${var.proxmox_vm_name}"
  template_description = "Ubuntu Server Jammy Template"
  iso_file             = "${var.proxmox_iso_file}"
  iso_storage_pool = "${var.proxmox_iso_storage_pool}"
  unmount_iso      = true
  qemu_agent       = true
  scsi_controller  = "virtio-scsi-pci"
  disks {
    disk_size = "20G"
    storage_pool      = "${var.proxmox_storage_pool}"
    storage_pool_type = "${var.proxmox_storage_pool_type}"
    type              = "virtio"
  }
  cores  = "4"
  memory = "4096"
  network_adapters {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = "false"
  }

  cloud_init              = true
  cloud_init_storage_pool = "${var.proxmox_cloud_init_storage_pool}"

  boot_command = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    "<bs><bs><bs><bs><wait>",
    "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
    "<f10><wait>"
  ]
  boot      = "c"
  boot_wait = "5s"

  http_directory = "http"
  http_port_min  = 8801
  http_port_max  = 8801

  ssh_username         = "${var.proxmox_vm_user}"
  ssh_private_key_file = "~/.ssh/cicd"
  ssh_timeout          = "30m"
}

build {

  name    = "ubuntu-server-jammy"
  sources = ["source.proxmox.ubuntu-server-jammy"]

  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      "sudo rm /etc/ssh/ssh_host_*",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo apt -y autoremove --purge",
      "sudo apt -y clean",
      "sudo apt -y autoclean",
      "sudo cloud-init clean",
      "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
      "sudo sync"
    ]
  }

  provisioner "file" {
    source      = "files/99-pve.cfg"
    destination = "/tmp/99-pve.cfg"
  }

  provisioner "shell" {
    inline = [
      "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg",
      "sudo rm /etc/netplan/*"
    ]
  }
}
