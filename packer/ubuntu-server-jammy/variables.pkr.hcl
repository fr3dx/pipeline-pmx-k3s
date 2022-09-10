# Credential vars

variable "proxmox_api_url" {
  type = string
}
variable "proxmox_api_token_id" {
  type = string
}
variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}
variable "proxmox_vm_user" {
  type = string
}

# Proxmox ve specific vars

variable "proxmox_node" {
  type    = string
  default = "pve"
}
variable "proxmox_vm_id" {
  type    = string
  default = "9003"
}
variable "proxmox_vm_name" {
  type    = string
  default = "ubuntu-server-jammy"
}
variable "proxmox_iso_file" {
  type    = string
  default = "/zfs01/ISO/template/iso/ubuntu-22.04.1-live-server-amd64.iso"
}
variable "proxmox_iso_storage_pool" {
  type    = string
  default = "ISO"
}
variable "proxmox_storage_pool" {
  type    = string
  default = "STORAGE"
}
variable "proxmox_storage_pool_type" {
  type    = string
  default = "zfspool"
}
variable "proxmox_cloud_init_storage_pool" {
  type    = string
  default = "local-btrfs"
}
