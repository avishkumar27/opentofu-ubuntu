variable "cloudinit_template_name" {
    type = string 
}

variable "proxmox_node" {
    type = string
}

variable "ssh_key" {
  type = string 
  sensitive = true
}


data "vault_kv_secret_v2" "test" {
  mount = "kv-v2" 
  name  = "proxmox" 
}

resource "proxmox_vm_qemu" "k8s-1" {
  count = 1
  name = "tf-${count.index + 1}"
  target_node = var.proxmox_node
  clone = var.cloudinit_template_name
  full_clone = true
  agent = 1
  onboot = true
  os_type = "cloud-init"
  #clone_wait = 0
  cores = 2
  sockets = 1
  cpu = "host"
  memory = 2048
  cloudinit_cdrom_storage = "local-lvm"
  scsihw = "virtio-scsi-pci"
  bootdisk = "scsi0"

  disks {
      scsi {
          scsi0 {
              disk {
                  backup             = true
                  cache              = "none"
                  discard            = true
                  emulatessd         = true
                  #iothread           = true
                  mbps_r_burst       = 0.0
                  mbps_r_concurrent  = 0.0
                  mbps_wr_burst      = 0.0
                  mbps_wr_concurrent = 0.0
                  replicate          = true
                  size               = 32
                  storage            = "local-lvm"
                }
            }
        }
    }


  network {
    model = "virtio"
    bridge = "vmbr1"
    firewall = false
    tag = 150
  }
  
  ciuser = data.vault_kv_secret_v2.test.data["user"]
  cipassword = data.vault_kv_secret_v2.test.data["password"]
  ipconfig0 = "ip=<ip>,gw=<gw>"
  nameserver = "<dns ip>"

  sshkeys = <<EOF
  ${var.ssh_key}
  EOF

  
 
}
