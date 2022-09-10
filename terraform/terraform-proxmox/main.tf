provider "proxmox" {
  pm_api_url          = var.api_url
  pm_api_token_id     = var.api_token_id
  pm_api_token_secret = var.api_token_secret
  pm_tls_insecure     = true
}

resource "proxmox_vm_qemu" "pmx_tf_vm" {
  count            = length(var.ips)
  name             = "tf-${terraform.workspace}-0${count.index + 1}"
  target_node      = var.proxmox_host
  clone            = var.template_name
  agent            = 0
  automatic_reboot = true
  os_type          = "cloud-init"
  cores            = 2
  sockets          = 1
  cpu              = "host"
  memory           = 2048
  scsihw           = "virtio-scsi-pci"
  bootdisk         = "scsi0"
  bios             = "seabios"
  disk {
    slot    = 0
    size    = "20G"
    type    = "virtio"
    storage = var.proxmox_storage
  }

  network {
    model     = "virtio"
    bridge    = "vmbr0"
    firewall  = false
    link_down = false
  }

  lifecycle {
    ignore_changes = [
      network,
    ]
  }

  ipconfig0 = "ip=${var.ips[count.index]}/24,gw=${cidrhost(format("%s/24", var.ips[count.index]), 1)}"

  sshkeys = <<EOF
  ${file(var.ssh_keys["pub"])}
  EOF


  connection {
    type        = "ssh"
    host        = var.ips[count.index]
    password    = var.ssh_password
    user        = var.user
    private_key = file(var.ssh_keys["priv"])
    agent       = false
    timeout     = "15m"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'SSH test OK'"
    ]
  }

  # Ansible provisioner
  #  provisioner "local-exec" {
  #    working_dir = var.ansible_work_dir
  #    command     = "ansible-playbook -u ${var.user} --key-file ${var.ssh_keys["priv"]} -i ${var.ips[count.index]}, main.yml"
  #  }

}