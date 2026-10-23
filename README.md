# Windows Image Factory Demo

[![Windows Image Factory Demo](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/image-factory.yml/badge.svg)](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/image-factory.yml)

A demonstration project for building Windows system images using GitHub Actions with self-hosted runners on Google Cloud Platform.

## Overview

This project simulates a Windows image factory pipeline that validates configurations, builds system images, and generates deployment packages. It's designed to run on self-hosted Windows runners for enterprise environments.

## Features

- ✅ Configuration validation
- ✅ Automated image building simulation
- ✅ Artifact validation and packaging
- ✅ Tanium package generation
- ✅ Self-hosted runner support
- ✅ PowerShell-based automation

## Project Structure

```
image-factory-demo/
├── .github/
│   └── workflows/
│       └── image-factory.yml    # GitHub Actions workflow (self-hosted)
├── configs/
│   └── device.yaml              # Device configuration
├── scripts/
│   ├── validate-config.ps1      # Config validation
│   ├── simulate-build.ps1       # Image build simulation
│   ├── validate-artifacts.ps1   # Artifact validation
│   └── new-tanium-package.ps1   # Tanium package generator
├── tests/
│   └── Test-Project.ps1         # Project smoke tests
├── packer/
│   ├── windows.pkr.hcl          # Packer template
│   └── variables.pkr.hcl.example # Packer variables
├── artifacts/                   # Build outputs (generated)
└── SELF_HOSTED_SETUP.md        # Self-hosted runner setup guide
```

## Quick Start

### Prerequisites

- Google Cloud Platform account
- GitHub repository
- Basic knowledge of PowerShell (helpful but not required)

### Setup Steps

1. **Fork or clone this repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/image-factory-demo.git
   cd image-factory-demo
   ```

2. **Set up your self-hosted runner**
   
   Follow the comprehensive guide: **[SELF_HOSTED_SETUP.md](SELF_HOSTED_SETUP.md)**
   
   This guide covers:
   - Creating a Windows VM in GCP
   - Installing required software
   - Registering the GitHub runner
   - Testing your setup

3. **Push a change or run workflow manually**
   ```bash
   git add .
   git commit -m "Initial setup"
   git push origin main
   ```
   
   Or use GitHub's UI:
   - Go to **Actions** tab
   - Select **Windows Image Factory Demo**
   - Click **Run workflow**

## How It Works

### Workflow Triggers

The workflow runs automatically when:
- Changes are pushed to `main` branch
- Pull requests are opened to `main`
- Manually triggered via `workflow_dispatch`

### Workflow Steps

1. **Checkout** - Clones the repository
2. **Validate Configuration** - Checks `configs/device.yaml` for errors
3. **Run Smoke Test** - Executes project tests
4. **Simulate Image Build** - Simulates Windows image creation
5. **Validate Artifacts** - Verifies build outputs
6. **Generate Tanium Package** - Creates deployment package
7. **Upload Artifacts** - Stores build outputs

## Configuration

### Device Configuration (`configs/device.yaml`)

Defines the target device specifications and software packages:

```yaml
device:
  model: "Enterprise Desktop"
  os_version: "Windows 11 Enterprise"
  drivers:
    - elo-touchscreen
    - barcode-scanner
  applications:
    - chrome
    - adobe-reader
```

### Runner Configuration

The workflow is configured for self-hosted Windows runners with labels:
```yaml
runs-on: [self-hosted, windows]
```

## Development

### Running Scripts Locally

```powershell
# Validate configuration
.\scripts\validate-config.ps1 -ConfigPath .\configs\device.yaml

# Run tests
.\tests\Test-Project.ps1

# Simulate build
.\scripts\simulate-build.ps1 -ConfigPath .\configs\device.yaml -ArtifactDirectory .\artifacts
```

### Adding New Applications

1. Edit `configs/device.yaml`
2. Add application installer to `apps/` directory
3. Update `scripts/install-applications.ps1` if custom logic needed

### Adding New Drivers

1. Place driver files in `drivers/<driver-name>/`
2. Update `configs/device.yaml`
3. Drivers are injected via `scripts/inject-drivers-offline.ps1`

## Troubleshooting

### Workflow Not Running

- Verify runner is online: **Settings → Actions → Runners**
- Check runner labels match `[self-hosted, windows]`
- Ensure VM is running in GCP Console

### Script Execution Errors

```powershell
# Enable script execution
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Build Artifacts Missing

- Check workflow logs in GitHub Actions tab
- Verify `artifacts/` directory permissions on runner
- Ensure disk space is available on VM

## Cost Management

**GCP VM Costs:**
- Running 24/7: ~$50-100/month (depending on machine type)
- Stopped VM: ~$2/month (storage only)

**Recommendation:** Stop your GCP VM when not actively running workflows.

```bash
# Stop VM via gcloud CLI
gcloud compute instances stop github-runner-windows --zone=us-central1-a

# Start VM
gcloud compute instances start github-runner-windows --zone=us-central1-a
```

## Security Considerations

- ✅ Runner uses least-privilege service account
- ✅ Workflow has read-only content permissions
- ✅ No secrets required for simulation mode
- ⚠️ Restrict RDP access to trusted IP ranges only
- ⚠️ Regularly update Windows Server and runner software

## Advanced Configuration

### Using Real Packer Builds

To build actual Windows images (not simulations):

1. Install HashiCorp Packer on your runner
2. Configure Hyper-V or VMware on the VM
3. Update workflow to use `packer build` instead of `simulate-build.ps1`

See [packer/windows.pkr.hcl](packer/windows.pkr.hcl) for template configuration.

### Multi-Runner Setup

For parallel builds:

1. Create additional GCP VMs
2. Register each as a separate runner
3. GitHub automatically distributes jobs across available runners

## Documentation

- **[Self-Hosted Setup Guide](SELF_HOSTED_SETUP.md)** - Complete runner setup instructions
- **[GitHub Actions Docs](https://docs.github.com/en/actions)** - Official GitHub Actions documentation
- **[GCP Compute Engine](https://cloud.google.com/compute/docs)** - Google Cloud VM documentation

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is provided as-is for demonstration purposes.

## Support

For issues or questions:

1. Check the **[Troubleshooting](#troubleshooting)** section
2. Review GitHub Actions logs
3. Check GCP VM logs in Cloud Console
4. Open an issue in this repository

---

**Ready to get started? Follow the [Self-Hosted Setup Guide](SELF_HOSTED_SETUP.md) now!**
