# Windows Image Factory Demo

A staged prototype for YAML-driven Windows image customization and CI/CD.

## Important
- Use only Windows installation media and driver/application packages you are licensed and authorized to deploy.
- A placeholder/demo package is not a production PT installer.
- The GitHub Actions workflow defaults to a safe validation/package simulation. Real Hyper-V builds require a properly configured self-hosted Windows runner with Hyper-V and Packer's Hyper-V plugin available.
- Producing a valid WIM/ISO requires a real Windows source image and the appropriate Windows ADK/Deployment Tools. The starter pipeline does not label dummy files as bootable images.

## Repository layout
- `configs/device.yaml`: device profile
- `packer/windows.pkr.hcl`: Hyper-V ISO builder template (environment-specific; review before use)
- `scripts/`: validation, customization, driver, app, artifact and package scripts
- `tests/`: basic configuration checks
- `artifacts/`: local output (ignored by Git)
- `.github/workflows/image-factory.yml`: CI workflow

## 1. Workstation prerequisites
Open PowerShell. Install Git, VS Code, and Packer using your organization's approved software process. If using winget:

```powershell
winget install --id Git.Git -e
winget install --id Microsoft.VisualStudioCode -e
winget install --id Hashicorp.Packer -e
```

Close and reopen PowerShell, then verify:

```powershell
git --version
code --version
packer --version
```

For Hyper-V, check Windows edition and virtualization:
```powershell
Get-ComputerInfo | Select-Object WindowsProductName, HyperVisorPresent
Get-CimInstance Win32_ComputerSystem | Select-Object HypervisorPresent
Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
```
Hyper-V support depends on Windows edition, firmware virtualization, and host policy. Do not enable it on a managed device without IT approval.

## 2. Create a working copy
Extract this archive, then in PowerShell:

```powershell
cd .\image-factory-demo
git init
git add .
git commit -m "Initial Windows image factory prototype"
```

If Git asks for identity:
```powershell
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

## 3. Run the safe local demo first
The scripts use built-in PowerShell and don't require third-party YAML modules for the starter checks.

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\scripts\validate-config.ps1 -ConfigPath .\configs\device.yaml
.\scripts\simulate-build.ps1 -ConfigPath .\configs\device.yaml
.\scripts\validate-artifacts.ps1 -ArtifactDirectory .\artifacts
.\scripts\new-tanium-package.ps1 -ArtifactDirectory .\artifacts
Get-ChildItem .\artifacts -Recurse
```

The safe simulation creates a manifest and package metadata, not a bootable Windows image.

## 4. Change configuration to demonstrate config-as-code
Edit `configs/device.yaml`, for example change `device: POS` to `device: KIOSK`, or change `driver_version: v1` to `v2`, then run:

```powershell
.\scripts\validate-config.ps1 -ConfigPath .\configs\device.yaml
.\scripts\simulate-build.ps1 -ConfigPath .\configs\device.yaml
Get-Content .\artifacts\build-manifest.json
git add configs/device.yaml
git commit -m "Change device profile to KIOSK and driver version v2"
```

The generated manifest records the profile values so the change is visible.

## 5. Configure GitHub
Create an empty repository named `image-factory-demo` in GitHub. Do not initialize it with a README if you already have this project locally. Then:

```powershell
git branch -M main
git remote add origin https://github.com/YOUR-ORG/image-factory-demo.git
git push -u origin main
```

Replace `YOUR-ORG` with your GitHub username or organization. Each push triggers `.github/workflows/image-factory.yml`. The default workflow validates the config and uploads simulated package artifacts.

## 6. Real Packer/Hyper-V build (environment-specific)
1. Prepare a dedicated self-hosted Windows runner with Hyper-V, Packer, sufficient disk/RAM/CPU, and approved Windows installation media.
2. Add a Hyper-V virtual switch and confirm its exact name.
3. Review `packer/windows.pkr.hcl` and `packer/variables.pkrvars.hcl.example`.
4. Use a supported Windows ISO, a valid checksum, and a tested unattended setup answer file. Do not commit product keys or credentials.
5. Run validation:
```powershell
packer init .\packer
packer fmt -check .\packer
packer validate -var-file .\packer\variables.pkrvars.hcl .\packer\windows.pkr.hcl
```
6. Build only after environment-specific values and Windows setup automation are tested:
```powershell
packer build -var-file .\packer\variables.pkrvars.hcl .\packer\windows.pkr.hcl
```

The sample HCL is a starting point, not a universal plug-and-play template. Hyper-V switch names, ISO checksum, boot sequence, WinRM setup, Windows version, and unattended installation need to match your environment. First run on a disposable lab host.

## 7. Driver injection
`drivers/elo/` and `drivers/scanner/` contain README placeholders. Put authorized extracted `.inf`, `.sys`, and `.cat` driver files in their folders. Offline injection uses DISM against a mounted Windows image:
```powershell
dism.exe /Image:C:\Mount\Windows /Add-Driver /Driver:C:\Drivers\elo /Recurse
dism.exe /Image:C:\Mount\Windows /Get-Drivers /Format:Table
```
Run from an elevated shell and use the correct mounted image path. Never inject untrusted drivers. This offline command is not the same as installing drivers into a running VM.

## 8. WIM/ISO and PT/Tanium
To make real WIM/ISO outputs, implement a tested capture/export flow using Windows ADK DISM and Windows deployment tooling against a real prepared image. The included package-generation script creates a **simulation package** (metadata + PowerShell install wrapper). Integrate actual PT tooling, Tanium package definitions, signing, and repository/NAS credentials only after confirming the target platform's required format and approval process.

## Troubleshooting
- `packer is not recognized`: reopen PowerShell; verify `Get-Command packer`.
- GitHub runner can't use Hyper-V: use a self-hosted runner on a supported Windows host; GitHub-hosted runners should not be assumed to expose nested Hyper-V.
- DISM error 740: open an elevated PowerShell.
- DISM cannot find image: check the mounted image path and mount state.
- Workflow doesn't trigger: confirm file is under `.github/workflows/`, branch is `main`, and Actions are enabled.
