packer {
  required_plugins {
    hyperv = {
      source  = "github.com/hashicorp/hyperv"
      version = ">= 1.1.0"
    }
  }
}

variable "iso_path"     { type = string }
variable "iso_checksum" { type = string }
variable "switch_name"  { type = string }
variable "vm_name" {
  type    = string
  default = "image-factory-demo"
}
variable "memory" {
  type    = number
  default = 4096
}
variable "cpus" {
  type    = number
  default = 2
}

source "hyperv-iso" "windows" {
  vm_name          = var.vm_name
  cpus             = var.cpus
  memory           = var.memory
  disk_size        = 61440
  iso_url          = var.iso_path
  iso_checksum     = var.iso_checksum
  communicator     = "winrm"
  winrm_username   = "packer"
  winrm_password   = "ChangeThisToARandomLabOnlyPassword!"
  winrm_timeout    = "6h"
  switch_name      = var.switch_name
  headless         = false
  output_directory = "packer/output-${var.vm_name}"
  shutdown_command = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer shutdown\""
  # Windows ISO boot command and unattended setup vary by Windows release.
  # Add and test a matching autounattend.xml/boot_command for your licensed media.
}

build {
  name    = "windows-image-factory"
  sources = ["source.hyperv-iso.windows"]

  provisioner "powershell" {
    inline = [
      "New-Item -ItemType Directory -Force -Path C:\\ImageFactory\\config,C:\\ImageFactory\\scripts,C:\\ImageFactory\\logs | Out-Null",
      "Set-Content -Path C:\\ImageFactory\\README.txt -Value 'Image Factory prototype baseline customization'",
      "New-Item -ItemType Directory -Force -Path C:\\ImageFactory\\apps,C:\\ImageFactory\\drivers | Out-Null"
    ]
  }
}
