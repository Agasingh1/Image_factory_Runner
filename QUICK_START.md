# Quick Start Guide - Self-Hosted Runner Setup

This is a condensed checklist for setting up your self-hosted GitHub Actions runner on GCP. For detailed explanations, see [SELF_HOSTED_SETUP.md](SELF_HOSTED_SETUP.md).

## Checklist

### ☐ Part 1: GCP Setup (10 minutes)

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Navigate to **Compute Engine → VM instances → CREATE INSTANCE**
3. Configure:
   - Name: `github-runner-windows`
   - Machine type: `e2-standard-2`
   - Boot disk: **Windows Server 2022 Datacenter** (50 GB)
4. Click **CREATE**
5. Once running, set Windows password (RDP dropdown → Set Windows password)
6. **Save password somewhere safe!**

### ☐ Part 2: Connect to VM (2 minutes)

1. Download RDP file (RDP dropdown → Download RDP file)
2. Open RDP file and connect with username/password from Part 1

### ☐ Part 3: Install Software on VM (10 minutes)

**In Windows VM PowerShell (as Administrator):**

```powershell
# Install Git
winget install --id Git.Git -e --source winget

# Verify installations
git --version
$PSVersionTable.PSVersion  # Should be 5.1+
```

### ☐ Part 4: Register GitHub Runner (5 minutes)

**On GitHub:**
1. Go to your repository → **Settings → Actions → Runners**
2. Click **New self-hosted runner**
3. Select **Windows** and **x64**
4. **Keep this page open**

**In Windows VM PowerShell (as Administrator):**

```powershell
# Create runner directory
mkdir C:\actions-runner
cd C:\actions-runner

# Download runner (copy command from GitHub page)
Invoke-WebRequest -Uri https://github.com/actions/runner/releases/download/v2.XXX.X/actions-runner-win-x64-2.XXX.X.zip -OutFile actions-runner.zip

# Extract
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory("$PWD\actions-runner.zip", "$PWD")

# Configure (copy command from GitHub page - includes your token)
.\config.cmd --url https://github.com/YOUR_USERNAME/YOUR_REPO --token YOUR_TOKEN

# When prompted:
# - Runner name: [Press Enter for default]
# - Runner group: [Press Enter for default]
# - Labels: Type "windows" and press Enter
# - Work folder: [Press Enter for default]

# Install and start as service
.\svc.cmd install
.\svc.cmd start
```

### ☐ Part 5: Verify Setup (2 minutes)

1. Go to GitHub: **Settings → Actions → Runners**
2. Verify runner shows as **Idle** (green dot)
3. Go to **Actions** tab → **Windows Image Factory Demo**
4. Click **Run workflow → Run workflow**
5. Watch it run on your self-hosted runner!

## Common Issues

| Issue | Solution |
|-------|----------|
| Runner shows "Offline" | In VM: `cd C:\actions-runner` then `.\svc.cmd start` |
| "No runner matching labels" | Verify labels in GitHub Settings exactly match `[self-hosted, windows]` |
| PowerShell script errors | Run: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser` |
| VM too slow | Stop VM, change machine type to `e2-standard-4`, restart |

## Stop VM When Not in Use

**To save money:**

1. In GCP Console → **Compute Engine → VM instances**
2. Select your VM → Click **STOP**
3. To restart: **START/RESUME**

**Cost:** Running 24/7 ≈ $50/month. Stopped ≈ $2/month (storage only).

## Next Steps

- ✅ Runner is configured and ready!
- 📚 Read [README.md](README.md) for project overview
- 🔧 Customize [configs/device.yaml](configs/device.yaml) for your needs
- 📝 Review [SELF_HOSTED_SETUP.md](SELF_HOSTED_SETUP.md) for detailed explanations

---

**Total Setup Time:** ~30 minutes

**Need help?** Check [SELF_HOSTED_SETUP.md](SELF_HOSTED_SETUP.md) for detailed troubleshooting.
