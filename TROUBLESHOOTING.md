# Troubleshooting Guide

Comprehensive solutions for common issues when setting up and running self-hosted GitHub Actions runners on GCP.

## Table of Contents

- [Runner Issues](#runner-issues)
- [GCP VM Issues](#gcp-vm-issues)
- [Workflow Issues](#workflow-issues)
- [Network Issues](#network-issues)
- [Performance Issues](#performance-issues)
- [Cost Issues](#cost-issues)

---

## Runner Issues

### Runner Shows as "Offline" in GitHub

**Symptoms:**
- Green dot in GitHub Settings → Actions → Runners is gray or red
- Jobs stay in "Queued" state indefinitely

**Solutions:**

1. **Check if VM is running:**
   - Go to GCP Console → Compute Engine → VM instances
   - Verify status is green (Running)
   - If stopped, click **START/RESUME**

2. **Restart runner service:**
   ```powershell
   # RDP to VM, open PowerShell as Administrator
   cd C:\actions-runner
   .\svc.cmd status     # Check current status
   .\svc.cmd stop       # Stop service
   .\svc.cmd start      # Start service
   ```

3. **Check service logs:**
   ```powershell
   cd C:\actions-runner\_diag
   Get-Content -Path .\Runner_*.log -Tail 50
   ```

4. **Verify network connectivity:**
   ```powershell
   Test-NetConnection -ComputerName github.com -Port 443
   Test-NetConnection -ComputerName api.github.com -Port 443
   ```

---

### Runner Registration Fails

**Symptoms:**
- `config.cmd` returns error
- "Invalid token" or "Forbidden" messages

**Solutions:**

1. **Generate a new token:**
   - GitHub repo → Settings → Actions → Runners → New self-hosted runner
   - Tokens expire after 1 hour
   - Copy the new registration command

2. **Check repository permissions:**
   - Ensure you have admin access to the repository
   - Personal repos: You should be the owner
   - Organization repos: You need admin role

3. **Remove old registration:**
   ```powershell
   cd C:\actions-runner
   .\config.cmd remove --token YOUR_OLD_TOKEN
   # Then re-register with new token
   .\config.cmd --url https://github.com/YOUR_USERNAME/YOUR_REPO --token NEW_TOKEN
   ```

---

### "No Runner Matching Labels" Error

**Symptoms:**
- Workflow shows: "No runners matched the labels: self-hosted, windows"
- Jobs stay queued

**Solutions:**

1. **Verify runner labels:**
   - GitHub repo → Settings → Actions → Runners
   - Click your runner name
   - Check labels match exactly: `self-hosted`, `windows`

2. **Update workflow file:**
   ```yaml
   # .github/workflows/image-factory.yml
   runs-on: [self-hosted, windows]  # Must match runner labels
   ```

3. **Re-configure runner with correct labels:**
   ```powershell
   cd C:\actions-runner
   .\config.cmd remove
   .\config.cmd --url https://github.com/YOUR_USERNAME/YOUR_REPO --token YOUR_TOKEN
   # When prompted for labels, type: windows
   ```

---

### Runner Service Won't Start

**Symptoms:**
- `svc.cmd start` returns error
- Event Viewer shows service startup failures

**Solutions:**

1. **Check Windows Event Viewer:**
   - Press `Win + X` → Event Viewer
   - Windows Logs → Application
   - Look for errors from "actions.runner" source

2. **Verify service account permissions:**
   ```powershell
   # Check if service is installed
   Get-Service | Where-Object {$_.Name -like "*actions.runner*"}
   
   # Reinstall service
   cd C:\actions-runner
   .\svc.cmd uninstall
   .\svc.cmd install
   .\svc.cmd start
   ```

3. **Run runner interactively for debugging:**
   ```powershell
   cd C:\actions-runner
   .\run.cmd  # Run in foreground to see errors
   ```

---

## GCP VM Issues

### Cannot RDP to VM

**Symptoms:**
- RDP connection times out
- "Remote Desktop can't connect to the remote computer"

**Solutions:**

1. **Verify VM is running:**
   - GCP Console → Compute Engine → VM instances
   - Status should be green checkmark

2. **Check firewall rules:**
   - GCP Console → VPC Network → Firewall
   - Ensure rule exists allowing TCP port 3389
   - Default rule: `default-allow-rdp`

3. **Verify external IP:**
   - VM must have an external IP address
   - If missing, stop VM → Edit → Network → External IP → Ephemeral

4. **Reset Windows password:**
   - VM instances → RDP dropdown → Set Windows password
   - Try connecting with new password

5. **Use GCP Console SSH alternative:**
   - Not available for Windows, but you can:
   - VM instances → Click VM name → Remote access → View gcloud command

---

### VM Runs Out of Disk Space

**Symptoms:**
- Workflow fails with "No space left on device"
- Runner logs show disk errors

**Solutions:**

1. **Check disk usage:**
   ```powershell
   Get-PSDrive C | Select-Object Used,Free
   ```

2. **Clean up runner workspace:**
   ```powershell
   cd C:\actions-runner\_work
   # Delete old build directories
   Get-ChildItem -Directory | Where-Object {$_.Name -match '\d+'} | Remove-Item -Recurse -Force
   ```

3. **Increase disk size:**
   - GCP Console → Compute Engine → Disks
   - Select boot disk → EDIT → Increase size
   - After increase, RDP to VM and extend partition:
   ```powershell
   # Open Disk Management
   diskmgmt.msc
   # Right-click C: drive → Extend Volume
   ```

---

### VM Performance is Slow

**Symptoms:**
- Workflows take 5-10+ minutes
- RDP is laggy
- High CPU/memory usage

**Solutions:**

1. **Check resource usage:**
   ```powershell
   # Open Task Manager
   taskmgr
   # Or use PowerShell
   Get-Process | Sort-Object CPU -Descending | Select-Object -First 10
   ```

2. **Upgrade machine type:**
   - Stop VM in GCP Console
   - Click EDIT
   - Machine type → Select `e2-standard-4` (4 vCPUs, 16 GB)
   - Click SAVE
   - Start VM

3. **Optimize Windows:**
   ```powershell
   # Disable Windows Search indexing on C:
   Set-Service -Name "WSearch" -StartupType Disabled
   Stop-Service -Name "WSearch"
   
   # Disable unnecessary services
   Set-Service -Name "SysMain" -StartupType Disabled  # Superfetch
   Stop-Service -Name "SysMain"
   ```

---

## Workflow Issues

### PowerShell Scripts Fail to Execute

**Symptoms:**
- Workflow shows: "Cannot be loaded because running scripts is disabled"
- Exit code 1 from PowerShell steps

**Solutions:**

1. **Set execution policy on runner:**
   ```powershell
   # RDP to VM, PowerShell as Administrator
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
   ```

2. **Add execution policy to workflow:**
   ```yaml
   - name: Validate configuration
     shell: pwsh
     run: |
       Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
       ./scripts/validate-config.ps1 -ConfigPath ./configs/device.yaml
   ```

---

### Git Checkout Fails

**Symptoms:**
- Workflow fails at "Checkout" step
- "fatal: could not read Username for 'https://github.com'"

**Solutions:**

1. **Verify Git is installed:**
   ```powershell
   git --version
   # If not found, install:
   winget install --id Git.Git -e --source winget
   ```

2. **Check GitHub authentication:**
   - For public repos: No auth required
   - For private repos: Configure GitHub token
   ```yaml
   - name: Checkout
     uses: actions/checkout@v4
     with:
       token: ${{ secrets.GITHUB_TOKEN }}  # Automatic
   ```

3. **Clear Git credentials:**
   ```powershell
   git config --global --unset credential.helper
   ```

---

### Artifacts Upload Fails

**Symptoms:**
- Workflow fails at "Upload demo artifacts" step
- "No files were found with the provided path"

**Solutions:**

1. **Verify artifacts exist:**
   ```yaml
   - name: Debug artifacts
     shell: pwsh
     run: |
       Get-ChildItem -Path ./artifacts -Recurse
   ```

2. **Check artifact path in workflow:**
   ```yaml
   - name: Upload demo artifacts
     uses: actions/upload-artifact@v4
     with:
       name: image-factory-demo-${{ github.run_number }}
       path: artifacts/          # Ensure this matches output directory
       if-no-files-found: warn   # Change to 'warn' for debugging
   ```

3. **Verify directory permissions:**
   ```powershell
   icacls C:\actions-runner\_work\image-factory-demo\artifacts
   ```

---

## Network Issues

### Cannot Reach GitHub from VM

**Symptoms:**
- Runner can't connect to GitHub
- Workflows timeout during checkout

**Solutions:**

1. **Test connectivity:**
   ```powershell
   Test-NetConnection -ComputerName github.com -Port 443
   Test-NetConnection -ComputerName api.github.com -Port 443
   ```

2. **Check GCP firewall egress rules:**
   - GCP Console → VPC Network → Firewall
   - Ensure egress to 0.0.0.0/0 on port 443 is allowed
   - Default rule: `default-allow-egress`

3. **Verify DNS resolution:**
   ```powershell
   nslookup github.com
   # Should return IP addresses
   ```

4. **Check Windows Firewall:**
   ```powershell
   # Temporarily disable for testing
   Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
   # If this fixes it, add explicit allow rule:
   New-NetFirewallRule -DisplayName "GitHub HTTPS" -Direction Outbound -Protocol TCP -RemotePort 443 -Action Allow
   # Re-enable firewall
   Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
   ```

---

### Slow Download/Upload Speeds

**Symptoms:**
- Artifact uploads take 5+ minutes
- Git clone is very slow

**Solutions:**

1. **Check network tier:**
   - GCP charges extra for Premium network tier
   - Standard tier may be slower but cheaper

2. **Verify region:**
   - Choose GCP region close to your location
   - GitHub CDN endpoints are globally distributed

3. **Monitor network usage:**
   ```powershell
   Get-NetAdapterStatistics
   ```

---

## Performance Issues

### Workflows Take Too Long

**Expected time:** 1-2 minutes  
**Actual time:** 5-10+ minutes

**Solutions:**

1. **Check machine type:**
   - Minimum: `e2-medium` (2 vCPUs, 4 GB)
   - Recommended: `e2-standard-2` (2 vCPUs, 8 GB)
   - For production: `e2-standard-4` (4 vCPUs, 16 GB)

2. **Profile workflow steps:**
   - Check Actions tab for step-by-step timing
   - Identify slow steps

3. **Optimize PowerShell scripts:**
   ```powershell
   # Use -Parallel for ForEach-Object in PowerShell 7+
   Get-ChildItem | ForEach-Object -Parallel {
       # Process items in parallel
   } -ThrottleLimit 4
   ```

4. **Enable workflow caching:**
   ```yaml
   - name: Cache dependencies
     uses: actions/cache@v4
     with:
       path: |
         ~/.nuget/packages
         C:\temp\cache
       key: ${{ runner.os }}-cache-${{ hashFiles('**/packages.lock.json') }}
   ```

---

## Cost Issues

### Unexpected High Billing

**Symptoms:**
- GCP billing alert
- Monthly charges > $100

**Solutions:**

1. **Check VM uptime:**
   ```bash
   # In GCP Cloud Shell or local gcloud CLI
   gcloud compute instances list --format="table(name,status,creationTimestamp)"
   ```

2. **Stop VM when not needed:**
   ```bash
   gcloud compute instances stop github-runner-windows --zone=us-central1-a
   ```

3. **Review billing breakdown:**
   - GCP Console → Billing → Reports
   - Filter by: Compute Engine
   - Check for:
     - VM instance hours
     - Persistent disk charges
     - Network egress (data transfer out)

4. **Set up budget alerts:**
   - GCP Console → Billing → Budgets & alerts
   - Create budget: $50/month
   - Alert threshold: 50%, 90%, 100%

5. **Use cost-saving measures:**
   - **Committed use discounts:** 1-year or 3-year commitment (30-60% off)
   - **Sustained use discounts:** Automatic for VMs running >25% of month
   - **Spot VMs:** 60-91% cheaper but can be interrupted

---

## Advanced Debugging

### Enable Runner Diagnostic Mode

```powershell
# Stop runner service
cd C:\actions-runner
.\svc.cmd stop

# Run in diagnostic mode
$env:ACTIONS_RUNNER_PRINT_LOG_TO_STDOUT = 1
$env:ACTIONS_STEP_DEBUG = "true"
.\run.cmd
```

### Capture Network Traffic

```powershell
# Install Wireshark or use built-in pktmon
pktmon start --etw -p Microsoft-Windows-TCPIP -c
# Reproduce issue
pktmon stop
pktmon format pktmon.etl -o network-trace.txt
```

### Export Runner Logs

```powershell
cd C:\actions-runner\_diag
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
Compress-Archive -Path .\*.log -DestinationPath "C:\runner-logs-$timestamp.zip"
# Download via RDP or upload to cloud storage
```

---

## Getting Help

### Before Opening an Issue

1. ☑ Check this troubleshooting guide
2. ☑ Review GitHub Actions logs
3. ☑ Check runner diagnostic logs
4. ☑ Verify GCP VM is running and accessible
5. ☑ Search existing GitHub Issues

### What to Include in Issue Reports

- **Problem description:** What you expected vs. what happened
- **Workflow file:** `.github/workflows/image-factory.yml`
- **Runner version:** From GitHub Settings → Actions → Runners
- **Error messages:** Full text from logs
- **Steps to reproduce**
- **GCP VM details:** Machine type, region, OS version

### Useful Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Self-Hosted Runner Docs](https://docs.github.com/en/actions/hosting-your-own-runners)
- [GCP Compute Engine Docs](https://cloud.google.com/compute/docs)
- [PowerShell Documentation](https://learn.microsoft.com/en-us/powershell/)

---

**Still stuck?** Open an issue in the repository with details from the checklist above.
