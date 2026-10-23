
packer {
  required_plugins {
    hyperv = {
      source  = "github.com/hashicorp/hyperv"
      version = "~> 1"
    }
  }
}

variable "iso_path" {
  type    = string
  default = "C:/Users/anstiwar/Downloads/SERVER_EVAL_x64FRE_en-us.iso"
}

source "hyperv-iso" "windows_server" {
  iso_url      = var.iso_path
  iso_checksum = "none"

  vm_name   = "windows-server-image-factory"
  cpus      = 4
  memory    = 8192
  disk_size = 61440

  communicator     = "none"
  shutdown_timeout = "30m"

  # Add the correct unattended installation file
  # and Hyper-V switch after checking your setup.
}

build {
  name    = "windows-local-image"
  sources = ["source.hyperv-iso.windows_server"]
}