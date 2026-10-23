# Complete Self-Hosted Runner Setup Guide

**Quick Navigation:**
- [Current Status: You're at RDP Connection Step](#step-4-connect-via-rdp)
- [What You've Done](#what-youve-completed-so-far)
- [What's Next](#whats-remaining)

---

## 📍 What You've Completed So Far

✅ **Git Repository Setup**
- Git initialized and configured (username: Agasingh1)
- Code committed and pushed to GitHub
- Repository: https://github.com/Agasingh1/Image_factory_Runner

✅ **GCP VM Creation**
- VM created: `github-runner-windows`
- Machine type: `e2-medium` ⚠️ (Recommended: `e2-standard-2` for better performance)
- Operating system: Windows Server 2022
- Windows password set and saved

✅ **Current Step**
- **YOU ARE HERE →** Step 4: Connect to Windows VM via RDP

---

## 🎯 What's Remaining

- ⏳ Step 4: Connect to Windows VM via RDP (YOU ARE HERE)
- ⏳ Step 5: Install Git on Windows VM
- ⏳ Step 6: Register GitHub Runner
- ⏳ Step 7: Test the Workflow

**Estimated time remaining:** ~20-25 minutes

---

# 📖 Complete Setup Steps

## Prerequisites (Already Done ✅)

- ✅ Google Cloud Platform account with billing enabled
- ✅ GitHub repository created: https://github.com/Agasingh1/Image_factory_Runner
- ✅ Code pushed to GitHub

---

## Step 1: Create GCP VM (Already Done ✅)

### 1.1 Access Google Cloud Console ✅

1. Go to [https://console.cloud.google.com](https://console.cloud.google.com)
2. Sign in with your Google account
3. Select or create a project

### 1.2 Create Windows Virtual Machine ✅

1. Navigate to **Compute Engine** → **VM instances**
2. Click **CREATE INSTANCE**
3. Configure:

   **Basic Settings:**
   - Name: `github-runner-windows`
   - Region: Your choice (e.g., `us-central1`)
   - Zone: Default

   **Machine Configuration:**
   - Series: E2
   - Machine type: **`e2-standard-2`** (2 vCPUs, 8 GB memory)
     - ⚠️ If you selected `e2-medium`, consider changing to `e2-standard-2` for better performance

   **Boot Disk:**
   - Operating system: Windows Server
   - Version: Windows Server 2022 Datacenter
   - Boot disk type: Balanced persistent disk
   - Size: 50 GB

   **Firewall:**
   - ☑ Allow HTTP traffic
   - ☑ Allow HTTPS traffic

4. Click **CREATE**
5. Wait 2-3 minutes for VM to start

### 1.3 Set Windows Password ✅

1. In VM instances list, find `github-runner-windows`
2. Click **RDP** dropdown → **Set Windows password**
3. Enter username (you used)
4. Click **SET**
5. **Save password securely!** ✅

---

## Step 2: Push Code to GitHub (Already Done ✅)

✅ Your code is live at: https://github.com/Agasingh1/Image_factory_Runner

---

## Step 3: Verify VM is Running (Already Done ✅)

✅ VM status: Running (green checkmark in GCP Console)

---

## Step 4: Connect to Windows VM via RDP 👈 **YOU ARE HERE**

### 4.1 Download RDP File

1. In GCP Console → **Compute Engine** → **VM instances**
2. Find your `github-runner-windows` VM
3. Click the **RDP** dropdown button
4. Click **Download the RDP file**
5. Save the `.rdp` file to your computer

### 4.2 Open RDP Connection

1. **Locate the downloaded RDP file** (usually in Downloads folder)
2. **Double-click the RDP file** to open it
3. When prompted:
   - **Username:** (The username you set in Step 1.3)
   - **Password:** (The password you saved in Step 1.3)
4. Click **Connect** or **Yes**
5. If you see certificate warnings, click **Yes** or **Continue**

### 4.3 Verify Connection

✅ **Success:** You should now see the Windows Server 2022 desktop

**If connection fails:**
- Verify VM is running in GCP Console
- Check if you're using the correct username/password
- See [Troubleshooting](#troubleshooting) section below

---

## Step 5: Install Git on Windows VM

**IMPORTANT:** All commands below must be run **INSIDE your Windows VM** (via RDP), not on your local computer!

### 5.1 Open PowerShell as Administrator

1. Inside the Windows VM, click **Start menu**
2. Type: `PowerShell`
3. Right-click **Windows PowerShell**
4. Select **Run as administrator**
5. Click **Yes** when prompted

### 5.2 Install Git

**Copy and paste this command into PowerShell:**

```powershell
winget install --id Git.Git -e --source winget
```

Press **Enter** and wait for installation to complete (~2-3 minutes).

### 5.3 Verify Git Installation

**Run this command:**

```powershell
git --version
```

**Expected output:** `git version 2.xx.x`

✅ **Success:** Git is installed!

### 5.4 Verify PowerShell Version

**Run this command:**

```powershell
$PSVersionTable.PSVersion
```

**Expected output:** Version 5.1 or higher

✅ **Success:** PowerShell is ready!

---

## Step 6: Register GitHub Actions Runner

### 6.1 Get Runner Registration Token from GitHub

**In a web browser (can be on your local computer):**

1. Go to: https://github.com/Agasingh1/Image_factory_Runner
2. Click **Settings** (top right of repository page)
3. In left sidebar → **Actions** → **Runners**
4. Click **New self-hosted runner** (green button)
5. Select:
   - **Runner image:** Windows
   - **Architecture:** x64
6. **KEEP THIS PAGE OPEN** — you'll need to copy commands from it

### 6.2 Create Runner Directory

**Back in the Windows VM PowerShell (as Administrator):**

```powershell
mkdir C:\actions-runner
cd C:\actions-runner
```

### 6.3 Download GitHub Runner

**Copy the download command from GitHub page (Step 6.1) and paste into PowerShell.**

It will look similar to this (your version number may differ):

```powershell
# Example - use the EXACT command from your GitHub page
Invoke-WebRequest -Uri https://github.com/actions/runner/releases/download/v2.XXX.X/actions-runner-win-x64-2.XXX.X.zip -OutFile actions-runner-win-x64-2.XXX.X.zip
```

Press **Enter** and wait for download (~1 minute).

### 6.4 Extract Runner Files

**Copy and paste this command:**

```powershell
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory("$PWD\actions-runner-win-x64-2.XXX.X.zip", "$PWD")
```

⚠️ **Note:** Replace `2.XXX.X` with the actual version number from the file you downloaded.

**Or use this safer version that works with any filename:**

```powershell
Expand-Archive -Path .\*.zip -DestinationPath .
```

### 6.5 Configure Runner

**Copy the config command from GitHub page (Step 6.1) and paste into PowerShell.**

It will look like this (with your actual URL and token):

```powershell
.\config.cmd --url https://github.com/Agasingh1/Image_factory_Runner --token YOUR_ACTUAL_TOKEN_HERE
```

Press **Enter**.

**You'll be prompted with several questions. Answer as follows:**

| Prompt | Your Answer |
|--------|-------------|
| **Enter the name of the runner** | Press **Enter** (accept default) |
| **Enter the name of runner group** | Press **Enter** (accept default) |
| **Enter any additional labels** | Type: `windows` and press **Enter** |
| **Enter name of work folder** | Press **Enter** (accept default) |

✅ **Success:** You should see "Settings Saved."

### 6.6 Install Runner as Windows Service

**Copy and paste this command:**

```powershell
.\svc.cmd install
```

Press **Enter**.

✅ **Expected output:** "Service actions.runner.xxx successfully installed"

### 6.7 Start Runner Service

**Copy and paste this command:**

```powershell
.\svc.cmd start
```

Press **Enter**.

✅ **Expected output:** "Service actions.runner.xxx started successfully"

### 6.8 Verify Runner is Online

**In your web browser:**

1. Go to: https://github.com/Agasingh1/Image_factory_Runner/settings/actions/runners
2. You should see your runner listed
3. Status should show: **Idle** with a green dot ✅

✅ **Success:** Your self-hosted runner is online and ready!

---

## Step 7: Test the Workflow

### 7.1 Trigger Workflow Manually

1. Go to: https://github.com/Agasingh1/Image_factory_Runner/actions
2. Click **Windows Image Factory Demo** (left sidebar)
3. Click **Run workflow** button (right side)
4. Click **Run workflow** (confirm)

### 7.2 Watch Workflow Execute

1. You'll see a new workflow run appear
2. Click on the workflow run to see details
3. Watch as each step executes on your self-hosted runner

### 7.3 Verify Success

✅ **All steps should complete with green checkmarks**

**Expected workflow duration:** ~1-2 minutes

**Steps that should complete:**
- Checkout
- Validate configuration
- Run project smoke test
- Simulate image build
- Validate generated artifacts
- Generate Tanium package simulation
- Upload demo artifacts

### 7.4 Download Artifacts (Optional)

1. Scroll to bottom of workflow run page
2. Under **Artifacts**, click the artifact name to download
3. Extract and inspect the build outputs

---

## 🎉 Congratulations!

You've successfully set up a self-hosted GitHub Actions runner on GCP!

**What you accomplished:**
- ✅ Created a Windows Server VM in Google Cloud
- ✅ Connected via RDP
- ✅ Installed Git and PowerShell
- ✅ Registered GitHub Actions runner
- ✅ Ran your first workflow on self-hosted infrastructure

---

## 📋 Daily Operations

### Starting Your Workday

If you stopped the VM to save costs:

**In GCP Console:**
1. Go to **Compute Engine** → **VM instances**
2. Select `github-runner-windows`
3. Click **START/RESUME**
4. Wait 2-3 minutes
5. Verify runner shows "Idle" in GitHub: https://github.com/Agasingh1/Image_factory_Runner/settings/actions/runners

### Running a Workflow

**Method 1: Automatic (on push)**
```powershell
# On your local computer
git add .
git commit -m "Your changes"
git push origin main
```

**Method 2: Manual trigger**
1. Go to: https://github.com/Agasingh1/Image_factory_Runner/actions
2. Select workflow → Run workflow

### Ending Your Workday (Save Costs)

**In GCP Console:**
1. Go to **Compute Engine** → **VM instances**
2. Select `github-runner-windows`
3. Click **STOP**

💰 **Cost savings:** ~$50/month → ~$2/month (storage only)

---

## 💰 Cost Management

### Monthly Costs (if running 24/7)

| Component | Cost |
|-----------|------|
| VM (e2-standard-2) | $49/month |
| VM (e2-medium) | $24/month |
| Disk (50 GB) | $2/month |
| Network egress | $1-5/month |
| **Total (e2-standard-2)** | **~$52-56/month** |
| **Total (e2-medium)** | **~$27-31/month** |

### Set Up Billing Alerts

1. GCP Console → **Billing** → **Budgets & alerts**
2. Click **CREATE BUDGET**
3. Set amount: $50/month
4. Set alerts: 50%, 90%, 100%
5. Click **FINISH**

---

## 🔧 Troubleshooting

### Cannot Connect via RDP

**Problem:** RDP connection fails or times out

**Solutions:**
1. **Verify VM is running:**
   - GCP Console → Compute Engine → VM instances
   - Status should be green checkmark
   
2. **Check firewall rules:**
   - GCP Console → VPC Network → Firewall
   - Ensure `default-allow-rdp` exists and is enabled
   
3. **Reset Windows password:**
   - VM instances → RDP dropdown → Set Windows password
   - Use the new password to connect

4. **Verify external IP:**
   - VM must have an external IP address
   - Check in VM instances list

### Runner Shows "Offline"

**Problem:** Runner appears offline in GitHub

**Solutions:**

**In Windows VM PowerShell:**
```powershell
cd C:\actions-runner
.\svc.cmd status
```

If service is stopped:
```powershell
.\svc.cmd start
```

If service doesn't exist:
```powershell
.\svc.cmd install
.\svc.cmd start
```

### Workflow Fails: "No runner matching labels"

**Problem:** Workflow can't find your runner

**Solution:**

1. **Check runner labels:**
   - https://github.com/Agasingh1/Image_factory_Runner/settings/actions/runners
   - Click your runner name
   - Labels should include: `self-hosted`, `Windows`, `X64`, `windows`

2. **Check workflow configuration:**
   - File: `.github/workflows/image-factory.yml`
   - Should have: `runs-on: [self-hosted, windows]`

3. **Re-register runner if needed:**
   ```powershell
   cd C:\actions-runner
   .\config.cmd remove
   # Then follow Step 6.5 again with new token
   ```

### PowerShell Scripts Fail to Execute

**Problem:** Workflow fails with script execution errors

**Solution:**

**In Windows VM PowerShell (as Administrator):**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
```

### Git Command Not Found

**Problem:** Workflow fails because git is not recognized

**Solution:**

**Restart the runner service after installing Git:**
```powershell
cd C:\actions-runner
.\svc.cmd stop
.\svc.cmd start
```

### VM is Slow or Runs Out of Memory

**Problem:** Workflows take 5-10+ minutes or fail with memory errors

**Solution:**

**Upgrade machine type:**

1. In GCP Console, **STOP** the VM
2. Click **EDIT** on the VM
3. Change machine type to `e2-standard-2` (8 GB RAM) or `e2-standard-4` (16 GB RAM)
4. Click **SAVE**
5. **START** the VM

---

## 📚 Additional Resources

### Project Documentation

- **Repository:** https://github.com/Agasingh1/Image_factory_Runner
- **Workflow File:** `.github/workflows/image-factory.yml`
- **Configuration:** `configs/device.yaml`
- **Scripts:** `scripts/` directory

### External Documentation

- [GitHub Self-Hosted Runners](https://docs.github.com/en/actions/hosting-your-own-runners)
- [GCP Compute Engine](https://cloud.google.com/compute/docs)
- [GCP Pricing Calculator](https://cloud.google.com/products/calculator)
- [PowerShell Documentation](https://learn.microsoft.com/en-us/powershell/)

### Support

- **GitHub Actions Logs:** Check workflow run details for error messages
- **Runner Logs:** `C:\actions-runner\_diag\` on Windows VM
- **GCP Logs:** GCP Console → Compute Engine → VM → Logs

---

## ✅ Final Checklist

**After completing all steps, verify:**

- [ ] GCP VM is running
- [ ] Can connect via RDP
- [ ] Git is installed on VM
- [ ] Runner shows "Idle" in GitHub
- [ ] Workflow runs successfully
- [ ] Artifacts are generated and uploaded
- [ ] Windows password is saved securely
- [ ] Billing alerts are configured

---

## 🚀 What's Next?

**Now that your runner is working:**

1. **Customize the workflow:**
   - Edit `.github/workflows/image-factory.yml`
   - Modify `configs/device.yaml` for your environment
   - Update PowerShell scripts in `scripts/` directory

2. **Optimize costs:**
   - Stop VM when not in use
   - Consider scheduled start/stop using Cloud Scheduler
   - Use preemptible VMs for non-critical workloads

3. **Scale up:**
   - Add more runners for parallel execution
   - Create runner groups for team management
   - Implement runner auto-scaling

4. **Security hardening:**
   - Restrict RDP access to specific IP ranges
   - Enable Windows Defender and firewall
   - Regularly update Windows Server
   - Rotate RDP passwords monthly

---

**You're all set! Your self-hosted GitHub Actions runner is ready for production use.** 🎉
