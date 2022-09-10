# Rocky Server Blue Onyx

source "proxmox" "rocky-server-blue-onyx" {

  proxmox_url              = "${var.proxmox_api_url}"
  username                 = "${var.proxmox_api_token_id}"
  password                 = "${var.proxmox_api_token_secret}"
  insecure_skip_tls_verify = true

  node                 = "${var.proxmox_node}"
  vm_id                = "${var.proxmox_vm_id}"
  vm_name              = "${var.proxmox_vm_name}"
  template_description = "Rocky Server Blue Onyx Template"
  iso_file             = "${var.proxmox_iso_file}"
  iso_storage_pool = "${var.proxmox_iso_storage_pool}"
  os               = "l26"
  unmount_iso      = true
  qemu_agent       = true
  scsi_controller  = "virtio-scsi-pci"
  disks {
    disk_size = "8G"
    storage_pool      = "${var.proxmox_storage_pool}"
    storage_pool_type = "${var.proxmox_storage_pool_type}"
    type              = "virtio"
  }
  cores  = "4"
  cpu_type   = "host"
  memory     = "4096"
  network_adapters {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = "false"
  }

  cloud_init              = true
  cloud_init_storage_pool = "${var.proxmox_cloud_init_storage_pool}"

  boot_command = [
    "<tab> text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/inst.ks<enter><wait>"
  ]
  boot_wait = "5s"

  http_directory = "http"
  http_port_min  = 8801
  http_port_max  = 8801

  ssh_username         = "${var.proxmox_vm_user}"
  ssh_private_key_file = "~/.ssh/cicd"
  ssh_timeout          = "30m"
}

build {

  name    = "rocky-server-blue-onyx"
  sources = ["source.proxmox.rocky-server-blue-onyx"]

  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      "yum install -y cloud-init qemu-guest-agent cloud-utils-growpart gdisk",
      "systemctl enable qemu-guest-agent",
      "shred -u /etc/ssh/*_key /etc/ssh/*_key.pub",
      "rm -f /var/run/utmp",
      ">/var/log/lastlog",
      ">/var/log/wtmp",
      ">/var/log/btmp",
      "rm -rf /tmp/* /var/tmp/*",
      "unset HISTFILE; rm -rf /home/*/.*history /root/.*history",
      "rm -f /root/*ks",
      "passwd -d root",
      "passwd -l root",
      "rm -f /etc/ssh/ssh_config.d/allow-root-ssh.conf"
    ]
  }
}
