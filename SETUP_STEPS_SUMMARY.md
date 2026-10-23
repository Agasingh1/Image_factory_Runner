# Complete Setup Steps Summary

This document provides a complete overview of what you need to do to get your self-hosted GitHub Actions runner working with this project.

## 🎯 Your Goal

Run the Windows Image Factory Demo workflow on your own Windows VM in Google Cloud Platform instead of using GitHub's shared runners.

## 📅 Timeline

- **Total Time:** ~30-45 minutes
- **Technical Level:** Beginner-friendly (no DevOps experience required)
- **Cost:** ~$50/month if running 24/7, or ~$2/month if stopped when not in use

---

## 🔢 Step-by-Step Checklist

### Phase 1: Prerequisites (5 minutes)

- [ ] **Google Cloud Platform account** with billing enabled
- [ ] **GitHub account** with this repository
- [ ] **Basic computer skills** (opening browser, following instructions)

### Phase 2: Create GCP VM (10 minutes)

**What:** Set up a Windows Server virtual machine in Google Cloud

**How:** Follow [SELF_HOSTED_SETUP.md](SELF_HOSTED_SETUP.md) Part 1

**Steps:**
1. Go to [GCP Console](https://console.cloud.google.com)
2. Navigate to Compute Engine → VM instances
3. Click CREATE INSTANCE
4. Configure:
   - Name: `github-runner-windows`
   - Machine type: `e2-standard-2`
   - Boot disk: Windows Server 2022 (50 GB)
5. Click CREATE
6. Set Windows password (RDP dropdown)
7. **Save password securely!**

**Verification:** VM shows green checkmark (Running status)

### Phase 3: Connect to VM (5 minutes)

**What:** Access your Windows VM using Remote Desktop

**How:** Follow [SELF_HOSTED_SETUP.md](SELF_HOSTED_SETUP.md) Part 2

**Steps:**
1. Download RDP file from GCP Console
2. Open RDP file
3. Enter username and password from Phase 2
4. Accept certificate warnings

**Verification:** You see Windows Server desktop

### Phase 4: Install Software (10 minutes)

**What:** Install Git and PowerShell on the Windows VM

**How:** Follow [SELF_HOSTED_SETUP.md](SELF_HOSTED_SETUP.md) Part 3

**Steps (in VM PowerShell as Administrator):**
```powershell
# Install Git
winget install --id Git.Git -e --source winget

# Verify
git --version
$PSVersionTable.PSVersion
```

**Verification:** Both commands return version numbers

### Phase 5: Register Runner (10 minutes)

**What:** Connect your VM to GitHub as a self-hosted runner

**How:** Follow [SELF_HOSTED_SETUP.md](SELF_HOSTED_SETUP.md) Part 4

**Steps:**

**On GitHub:**
1. Go to your repo → Settings → Actions → Runners
2. Click New self-hosted runner
3. Select Windows and x64
4. **Keep this page open**

**In VM PowerShell:**
```powershell
# Create directory
mkdir C:\actions-runner
cd C:\actions-runner

# Download runner (copy command from GitHub)
Invoke-WebRequest -Uri [URL_FROM_GITHUB] -OutFile actions-runner.zip

# Extract
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory("$PWD\actions-runner.zip", "$PWD")

# Configure (copy command from GitHub)
.\config.cmd --url https://github.com/YOUR_USERNAME/YOUR_REPO --token YOUR_TOKEN

# When prompted:
# Name: [Press Enter]
# Group: [Press Enter]
# Labels: Type "windows" and press Enter
# Work folder: [Press Enter]

# Install and start service
.\svc.cmd install
.\svc.cmd start
```

**Verification:** GitHub Settings → Actions → Runners shows green "Idle" status

### Phase 6: Test Workflow (5 minutes)

**What:** Run your first workflow on the self-hosted runner

**How:** Manual workflow dispatch

**Steps:**
1. Go to GitHub repo → Actions tab
2. Click "Windows Image Factory Demo"
3. Click "Run workflow" → "Run workflow"
4. Watch the workflow execute

**Verification:** All steps complete with green checkmarks (✓)

---

## 📊 Success Criteria

You'll know everything is working when:

- ✅ GCP VM shows "Running" in Console
- ✅ GitHub runner shows "Idle" (green dot)
- ✅ Workflow completes successfully in ~1-2 minutes
- ✅ Artifacts are uploaded and downloadable

---

## 📚 Documentation Map

**Where to go for what:**

| Document | Purpose | When to Use |
|----------|---------|-------------|
| **[README.md](README.md)** | Project overview | First-time visitors |
| **[QUICK_START.md](QUICK_START.md)** | Condensed setup checklist | Quick reference |
| **[SELF_HOSTED_SETUP.md](SELF_HOSTED_SETUP.md)** | Detailed setup guide | Step-by-step setup |
| **[ARCHITECTURE.md](ARCHITECTURE.md)** | System architecture | Understanding how it works |
| **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** | Problem solving | When things go wrong |
| **[SETUP_STEPS_SUMMARY.md](SETUP_STEPS_SUMMARY.md)** (this file) | Complete checklist | Planning and tracking |

---

## 🔍 What Changed in the Project?

We updated your project to support self-hosted runners:

### Modified Files

1. **[.github/workflows/image-factory.yml](.github/workflows/image-factory.yml)**
   - Changed: `runs-on: windows-latest`
   - To: `runs-on: [self-hosted, windows]`
   - Why: Routes jobs to your GCP VM instead of GitHub's servers

### New Files Created

1. **[README.md](README.md)** - Project overview and quick start
2. **[SELF_HOSTED_SETUP.md](SELF_HOSTED_SETUP.md)** - Complete setup guide (beginner-friendly)
3. **[QUICK_START.md](QUICK_START.md)** - Condensed checklist
4. **[ARCHITECTURE.md](ARCHITECTURE.md)** - System diagrams and explanations
5. **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Solutions to common issues
6. **[SETUP_STEPS_SUMMARY.md](SETUP_STEPS_SUMMARY.md)** - This file

---

## 👥 Who Should Do What?

**If you're a developer:**
- Read [README.md](README.md)
- Follow [QUICK_START.md](QUICK_START.md)
- Reference [TROUBLESHOOTING.md](TROUBLESHOOTING.md) when needed

**If you're new to DevOps:**
- Start with this file (SETUP_STEPS_SUMMARY.md)
- Follow [SELF_HOSTED_SETUP.md](SELF_HOSTED_SETUP.md) step-by-step
- Don't skip steps!

**If you want to understand the system:**
- Read [ARCHITECTURE.md](ARCHITECTURE.md)
- Review diagrams and data flows

---

## ⏰ Daily Operations

### Starting Your Day

```bash
# If VM was stopped overnight (cost savings)
gcloud compute instances start github-runner-windows --zone=us-central1-a

# Wait 2-3 minutes, then verify runner is online
# GitHub repo → Settings → Actions → Runners → Should show "Idle"
```

### Ending Your Day

```bash
# Stop VM to save costs (optional)
gcloud compute instances stop github-runner-windows --zone=us-central1-a

# Savings: ~$50/month → ~$2/month (storage only)
```

### Running a Workflow

**Method 1: Push code**
```bash
git add .
git commit -m "Your changes"
git push origin main
# Workflow runs automatically
```

**Method 2: Manual trigger**
1. GitHub repo → Actions tab
2. Select "Windows Image Factory Demo"
3. Click "Run workflow" button
4. Click "Run workflow" (confirm)

---

## 💰 Cost Management

### Monthly Costs (Running 24/7)

| Component | Cost |
|-----------|------|
| VM (e2-standard-2) | $49 |
| Disk (50 GB) | $2 |
| Network egress | $1-5 |
| **Total** | **~$52-56** |

### Cost-Saving Strategies

**Option 1: Manual Stop/Start**
- Stop VM when not in use
- Cost: ~$2/month + runtime hours
- Best for: Development/testing

**Option 2: Scheduled Hours**
- Use Cloud Scheduler (9 AM - 6 PM weekdays)
- Cost: ~$15-20/month
- Best for: Team environments

**Option 3: Spot VMs**
- 60-91% cheaper
- Can be interrupted
- Cost: ~$12-20/month
- Best for: Non-critical workloads

### Set Budget Alert

1. GCP Console → Billing → Budgets & alerts
2. Create budget: $50/month
3. Alert at: 50%, 90%, 100%

---

## ⚠️ Common Pitfalls to Avoid

1. **Forgetting to save Windows password**
   - ⚠️ Cannot recover later
   - ✅ Save in password manager immediately

2. **Using expired registration token**
   - ⚠️ Tokens expire after 1 hour
   - ✅ Generate new token if setup takes longer

3. **Wrong runner labels**
   - ⚠️ Workflow won't find runner
   - ✅ Use exactly: `[self-hosted, windows]`

4. **Leaving VM running 24/7**
   - ⚠️ Costs $50+/month
   - ✅ Stop when not actively developing

5. **Skipping security updates**
   - ⚠️ Vulnerable to exploits
   - ✅ Run Windows Update monthly

---

## 🎓 Learning Path

**Day 1: Setup**
- [ ] Complete Phase 1-6 above
- [ ] Run first successful workflow
- [ ] Celebrate! 🎉

**Week 1: Familiarization**
- [ ] Read [ARCHITECTURE.md](ARCHITECTURE.md)
- [ ] Customize [configs/device.yaml](configs/device.yaml)
- [ ] Run workflow multiple times
- [ ] Download and inspect artifacts

**Week 2: Customization**
- [ ] Add new application to config
- [ ] Modify PowerShell scripts
- [ ] Test error handling
- [ ] Review runner logs

**Month 1: Optimization**
- [ ] Set up cost alerts
- [ ] Implement stop/start schedule
- [ ] Benchmark performance
- [ ] Document your customizations

---

## 🔗 External Resources

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Self-Hosted Runners Guide](https://docs.github.com/en/actions/hosting-your-own-runners)
- [GCP Free Tier](https://cloud.google.com/free) ($300 credit for new users)
- [GCP Compute Pricing](https://cloud.google.com/compute/pricing)
- [PowerShell Tutorial](https://learn.microsoft.com/en-us/powershell/scripting/learn/ps101/01-getting-started)

---

## ❓ FAQ

**Q: Do I need DevOps experience?**  
A: No! The guides are written for beginners. Just follow step-by-step.

**Q: Can I use Azure or AWS instead of GCP?**  
A: Yes, but this guide focuses on GCP. The runner setup is the same.

**Q: How do I stop paying for the VM?**  
A: Delete the VM in GCP Console. You'll lose all data, so export anything important first.

**Q: Can multiple people use the same runner?**  
A: Yes, but only one job runs at a time. For parallel jobs, create multiple runners.

**Q: Is my code secure on a self-hosted runner?**  
A: More secure than public runners for private code. Review [ARCHITECTURE.md](ARCHITECTURE.md) security section.

**Q: What if I get stuck?**  
A: Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) first, then open an issue in the repo.

---

## ✅ Final Checklist

Before you start:

- [ ] I have a GCP account with billing enabled
- [ ] I have admin access to the GitHub repository
- [ ] I have 30-45 minutes available
- [ ] I have a password manager ready
- [ ] I'm ready to follow instructions carefully

After setup:

- [ ] GCP VM is running
- [ ] Runner shows "Idle" in GitHub
- [ ] Workflow completed successfully
- [ ] I saved my Windows password
- [ ] I set up a billing alert
- [ ] I bookmarked [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

---

## 🚀 Ready to Start?

**Your next step:** Open [SELF_HOSTED_SETUP.md](SELF_HOSTED_SETUP.md) and begin with Part 1.

**Estimated completion time:** 30-45 minutes

**Difficulty level:** Beginner-friendly ⭐⭐☆☆☆

---

**Good luck! You've got this. 💪**
