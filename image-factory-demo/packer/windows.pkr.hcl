
packer {
  required_plugins {
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = "~> 1"
    }
  }
}

variable "windows_project_id" {
  type    = string
  default = "burner-anstiwar-7035"
}

variable "windows_zone" {
  type    = string
  default = "us-central1-a"
}

variable "windows_image_name" {
  type        = string
  description = "Unique name for the generated Windows Server 2022 golden image"
}

# Official Google Cloud Windows Server 2022 Datacenter source image.
variable "windows_source_image" {
  type    = string
  default = "windows-server-2022-dc-v20260909"
}

variable "windows_source_image_project_id" {
  type    = string
  default = "windows-cloud"
}

source "googlecompute" "windows" {
  project_id              = var.windows_project_id
  source_image            = var.windows_source_image
  source_image_project_id = [var.windows_source_image_project_id]

  zone         = var.windows_zone
  machine_type = "e2-medium"
  disk_size    = 60

  service_account_email = "image-factory-github@burner-anstiwar-7035.iam.gserviceaccount.com"

  tags = [
    "packer-winrm",
    "packer-iap-winrm"
  ]

  image_storage_locations = ["us-central1"]

  use_internal_ip  = true
  omit_external_ip = true
  use_iap          = true

  image_name        = var.windows_image_name
  image_description = "Custom Windows Server 2022 golden image built with Packer"

  communicator   = "winrm"
  winrm_username = "packer_user"
  winrm_use_ssl  = true
  winrm_insecure = true
  winrm_timeout  = "30m"

  metadata = {
    sysprep-specialize-script-cmd = "winrm quickconfig -quiet & net user /add packer_user & net localgroup administrators packer_user /add & winrm set winrm/config/service/auth @{Basic=\"true\"}"
  }
}


build {
  name    = "windows-server-2022-image-factory"
  sources = ["source.googlecompute.windows"]

  provisioner "powershell" {
    inline = [
      "New-Item -ItemType Directory -Force -Path C:\\ImageFactory\\config,C:\\ImageFactory\\scripts,C:\\ImageFactory\\logs,C:\\ImageFactory\\apps,C:\\ImageFactory\\drivers | Out-Null",
      "Set-Content -Path C:\\ImageFactory\\README.txt -Value 'Windows Server 2022 Image Factory prototype baseline customization'",
      "Write-Output 'Windows Server 2022 Image Factory baseline completed'"
    ]
  }

  provisioner "powershell" {
    inline = [
      "$ErrorActionPreference = 'Stop'",
      "$folder = 'C:\\Deploymentshare'",
      "New-Item -Path $folder -ItemType Directory -Force | Out-Null",
      "'hello world' | Set-Content -Path (Join-Path $folder 'hello.txt') -Encoding ascii",
      "$content = Get-Content -Raw (Join-Path $folder 'hello.txt')",
      "if ($content.Trim() -ne 'hello world') { throw 'Deploymentshare file validation failed' }",
      "Write-Output 'Deploymentshare hello.txt validation passed'"
    ]
  }
}
