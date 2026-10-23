# Self-Hosted Runner Setup Guide

This guide walks you through setting up a self-hosted GitHub Actions runner on Google Cloud Platform (GCP) for the Windows Image Factory Demo project.

## Prerequisites

- A Google Cloud Platform (GCP) account with billing enabled
- A GitHub repository (this project)
- Basic familiarity with web browsers and following instructions

---

## Part 1: Create a Windows VM in GCP

### Step 1: Access Google Cloud Console

1. Go to [https://console.cloud.google.com](https://console.cloud.google.com)
2. Sign in with your Google account
3. Select or create a project from the top dropdown menu

### Step 2: Create a Windows Virtual Machine

1. In the left navigation menu, click **Compute Engine** → **VM instances**
2. Click the **CREATE INSTANCE** button
3. Configure your VM with these settings:

   **Basic Settings:**
   - **Name:** `github-runner-windows`
   - **Region:** Choose a region close to you (e.g., `us-central1`)
   - **Zone:** Leave default or select any zone in your region

   **Machine Configuration:**
   - **Series:** E2
   - **Machine type:** `e2-standard-2` (2 vCPUs, 8 GB memory)
     - *Note: You can start with `e2-medium` but Windows works better with more RAM*

   **Boot Disk:**
   - Click **CHANGE**
   - **Operating system:** Windows Server
   - **Version:** Windows Server 2022 Datacenter
   - **Boot disk type:** Balanced persistent disk
   - **Size:** 50 GB (minimum recommended for Windows)
   - Click **SELECT**

   **Firewall:**
   - ☑ Allow HTTP traffic
   - ☑ Allow HTTPS traffic

4. Click **CREATE** at the bottom
5. Wait 2-3 minutes for the VM to start (status will show a green checkmark when ready)

### Step 3: Set Windows Password

1. In the VM instances list, find your `github-runner-windows` VM
2. Click the **RDP** dropdown next to your VM → **Set Windows password**
3. Enter your username (e.g., `admin` or your email username)
4. Click **SET**
5. **IMPORTANT:** Copy and save the generated password somewhere safe

---

## Part 2: Connect to Your Windows VM

### Step 4: Download RDP File

1. In the VM instances list, click the **RDP** dropdown next to your VM
2. Click **Download the RDP file**
3. Open the downloaded RDP file
4. When prompted:
   - **Username:** The username you set in Step 3
   - **Password:** The password you saved in Step 3
5. Click **Yes** if asked about certificate warnings
6. You should now see the Windows Server desktop

---

## Part 3: Install PowerShell and Git on Windows VM

### Step 5: Install PowerShell 7+ (if not already installed)

1. In your Windows VM, open **Windows PowerShell** (search in Start menu)
2. Run this command to check PowerShell version:
   ```powershell
   $PSVersionTable.PSVersion
   ```
3. If version is less than 7, install PowerShell 7:
   ```powershell
   winget install --id Microsoft.PowerShell --source winget
   ```
4. Close and reopen PowerShell as **Administrator**

### Step 6: Install Git for Windows

1. Download Git from: [https://git-scm.com/download/win](https://git-scm.com/download/win)
2. Run the installer with default settings
3. Verify installation:
   ```powershell
   git --version
   ```

---

## Part 4: Register GitHub Actions Runner

### Step 7: Get Runner Registration Token from GitHub

1. Go to your GitHub repository in a web browser
2. Click **Settings** (top right of repository page)
3. In the left sidebar, click **Actions** → **Runners**
4. Click the green **New self-hosted runner** button
5. Select:
   - **Runner image:** Windows
   - **Architecture:** x64
6. **Keep this page open** — you'll need the commands shown

### Step 8: Set Up Runner on Windows VM

1. In your Windows VM, open **PowerShell as Administrator**
2. Create a folder for the runner:
   ```powershell
   mkdir C:\actions-runner
   cd C:\actions-runner
   ```

3. **Copy the download command from GitHub** (from Step 7) and run it:
   ```powershell
   # Example (your URL will be different):
   Invoke-WebRequest -Uri https://github.com/actions/runner/releases/download/v2.xxx.x/actions-runner-win-x64-2.xxx.x.zip -OutFile actions-runner-win-x64-2.xxx.x.zip
   ```

4. Extract the downloaded file:
   ```powershell
   Add-Type -AssemblyName System.IO.Compression.FileSystem
   [System.IO.Compression.ZipFile]::ExtractToDirectory("$PWD\actions-runner-win-x64-2.xxx.x.zip", "$PWD")
   ```

5. **Copy the config command from GitHub** (from Step 7) and run it:
   ```powershell
   # Example (your URL and token will be different):
   .\config.cmd --url https://github.com/YOUR_USERNAME/YOUR_REPO --token YOUR_TOKEN
   ```

6. When prompted:
   - **Enter name of runner:** Press Enter (default name is fine)
   - **Enter runner group:** Press Enter (use default)
   - **Enter labels:** Type `windows` and press Enter
   - **Enter work folder:** Press Enter (use default)

### Step 9: Install and Start Runner as a Service

1. Install the runner as a Windows service:
   ```powershell
   .\svc.cmd install
   ```

2. Start the service:
   ```powershell
   .\svc.cmd start
   ```

3. Verify the runner is online:
   - Go back to your GitHub repository
   - Click **Settings** → **Actions** → **Runners**
   - You should see your runner with a green "Idle" status

---

## Part 5: Verify Your Setup

### Step 10: Test the Workflow

1. In your GitHub repository, go to the **Actions** tab
2. Click **Windows Image Factory Demo** workflow (left sidebar)
3. Click the **Run workflow** button (right side) → **Run workflow**
4. Watch the workflow execute on your self-hosted runner
5. Verify all steps complete successfully

---

## Troubleshooting

### Runner shows as "Offline"

1. In your Windows VM, check service status:
   ```powershell
   .\svc.cmd status
   ```
2. If stopped, restart:
   ```powershell
   .\svc.cmd stop
   .\svc.cmd start
   ```

### Workflow fails with "No runner matching labels"

1. Verify runner labels in GitHub Settings → Actions → Runners
2. Ensure labels match exactly: `[self-hosted, windows]`
3. If needed, reconfigure runner:
   ```powershell
   cd C:\actions-runner
   .\config.cmd remove
   # Then repeat Step 8
   ```

### PowerShell scripts fail to run

1. Set execution policy:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

### VM is too slow or runs out of memory

1. Stop the VM in GCP Console
2. Click **EDIT**
3. Change machine type to `e2-standard-4` (4 vCPUs, 16 GB)
4. Click **SAVE** and restart the VM

---

## Cost Management

### Stopping Your VM When Not in Use

1. In GCP Console, go to **Compute Engine** → **VM instances**
2. Select your VM → Click **STOP**
3. To restart: Select VM → Click **START/RESUME**

**Note:** You are only charged for compute when the VM is running. Storage costs apply even when stopped.

### Estimated Monthly Costs (if running 24/7)

- **e2-standard-2:** ~$50/month
- **e2-medium:** ~$25/month
- **Storage (50 GB):** ~$2/month

**Recommendation:** Stop the VM when not actively running workflows to save costs.

---

## Security Best Practices

1. **Use a dedicated service account** (not your personal account) for the runner
2. **Restrict network access** using GCP firewall rules
3. **Regularly update** Windows Server and GitHub runner software
4. **Monitor runner activity** in GitHub Actions logs
5. **Rotate passwords** for RDP access periodically

---

## Next Steps

- Review [GitHub's self-hosted runner documentation](https://docs.github.com/en/actions/hosting-your-own-runners)
- Customize your workflow in [`.github/workflows/image-factory.yml`](.github/workflows/image-factory.yml)
- Add more runners for parallel job execution
- Configure runner groups for team access control

---

## Getting Help

- **GitHub Actions Issues:** Check the Actions tab in your repository
- **GCP VM Issues:** Check GCP Console → Compute Engine → VM instances → Logs
- **Runner Logs:** On Windows VM, check `C:\actions-runner\_diag\` folder

---

**Congratulations! Your self-hosted runner is now configured and ready to build Windows images.**
