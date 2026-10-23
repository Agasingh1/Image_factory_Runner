
packer {
  required_plugins {
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = "~> 1"
    }
  }
}

variable "project_id" {
  type    = string
  default = "burner-anstiwar-7035"
}

variable "zone" {
  type    = string
  default = "us-central1-a"
}

variable "image_name" {
  type    = string
  default = "mcd-linux-packer-demo-v2"
}

source "googlecompute" "linux" {
  project_id              = var.project_id
  source_image_family     = "ubuntu-2204-lts"
  source_image_project_id = ["ubuntu-os-cloud"]
  instance_name           = "packer-linux-image-factory"
  use_internal_ip         = true
  omit_external_ip        = true
  use_iap                 = true

  zone                    = var.zone
  machine_type            = "e2-small"
  disk_size               = 20
  tags                    = ["packer-iap-ssh"]
  image_name              = var.image_name
  image_description       = "Linux image factory demo built with Packer"
  image_storage_locations = ["us-central1"]

  ssh_username = "packer"
}

build {
  name    = "linux-image-factory"
  sources = ["source.googlecompute.linux"]

  provisioner "shell" {
    inline = [
      "sudo mkdir -p /opt/image-factory/config /opt/image-factory/scripts /opt/image-factory/logs /opt/image-factory/apps /opt/image-factory/drivers",
      "echo 'Linux image built successfully with Packer' | sudo tee /opt/image-factory/README.txt",
      "sudo chmod -R a+rX /opt/image-factory"
    ]
  }
}