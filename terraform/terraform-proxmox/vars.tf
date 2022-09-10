# Credential vars

variable "api_url" {
  default = ""
}
variable "api_token_id" {
  default = ""
}
variable "api_token_secret" {
  default = ""
}

# Proxmox ve specific vars

variable "proxmox_host" {
  default = "pve"
}
variable "template_name" {
  default = "ubuntu-server-jammy"
}
variable "proxmox_storage" {
  default = "STORAGE"
}
variable "ips" {
  description = "IPs of the VMs, respective to the hostname order"
  type        = list(string)
  default     = ["192.168.99.231", "192.168.99.232"]
}
variable "ssh_keys" {
  type = map(any)
  default = {
    pub  = "/root/.ssh/cicd.pub"
    priv = "/root/.ssh/cicd"
  }
}
variable "ssh_pub_key" {
  default = ""
}
variable "ssh_password" {
  default = ""
}
variable "user" {
  default     = ""
  description = "User used to SSH into the machine and provision it"
}