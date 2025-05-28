# official telemate/proxmox provider from terraform registry
terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "3.0.1-rc9"
    }
  }
}
resource "proxmox_vm_qemu" "this" {              # Uses Cloud-Init options from Proxmox
  name        = var.vm_name
  target_node = var.target_node_name
  vmid        = var.vm_id
  kvm =   false
  clone       = var.base_template_name
  full_clone  = true                              # full clone of the existing template
  agent       = 1
  os_type     = "cloud-init"
   cpu {
  cores = var.vm_cores
  type = "qemu64"                                 # In case of kvm disabled in device use this to avoid kvm virtualization error
}
pool = var.vm_pool                            # # The destination resource pool for the new VM
 memory      = var.vm_memory_mb
 ciuser      = "ubuntu"
  sshkeys     = var.ssh_public_key
  ipconfig0   = "ip=${var.vm_ip_address},gw=${var.vm_gateway}"
  nameserver  = join(" ", var.vm_dns_servers)
  # network settings
  network {
    id = 0
    model  = "virtio"
    bridge = "vmbr1"
  }
  disk {
    slot = "scsi0"
    type    = "disk"
    storage = var.storage_pool_name
    size    = var.vm_disk_size
  }
  lifecycle {                                    # this is introduced so that proxmox do not modify anything on its own 
    ignore_changes = [network, disk]
  }
}
