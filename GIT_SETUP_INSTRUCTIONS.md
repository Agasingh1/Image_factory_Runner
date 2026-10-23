# Git Setup Instructions

✅ **Git repository initialized!** Your project is now ready to be pushed to GitHub.

## What Was Done

1. ✅ Initialized git repository (`git init`)
2. ✅ Created [.gitignore](.gitignore) file to exclude build artifacts and logs
3. ✅ Staged all project files (`git add .`)
4. ⏳ **Ready for commit and push**

---

## Next Steps to Push to GitHub

### Step 1: Update Git User Information

Before committing, set your actual name and email:

```powershell
# Replace with your actual name and email
git config user.name "Your Actual Name"
git config user.email "your.email@example.com"
```

**Example:**
```powershell
git config user.name "John Doe"
git config user.email "john.doe@company.com"
```

### Step 2: Create Initial Commit

```powershell
git commit -m "Configure project for self-hosted GitHub Actions runner"
```

### Step 3: Create GitHub Repository

**Option A: Using GitHub Web UI**

1. Go to [github.com](https://github.com) and sign in
2. Click the **+** icon (top right) → **New repository**
3. Configure:
   - **Repository name:** `image-factory-demo` (or your preferred name)
   - **Description:** Windows Image Factory with self-hosted GitHub Actions runner
   - **Visibility:** Public or Private (your choice)
   - ⚠️ **DO NOT** initialize with README, .gitignore, or license
4. Click **Create repository**
5. **Copy the repository URL** (e.g., `https://github.com/YOUR_USERNAME/image-factory-demo.git`)

**Option B: Using GitHub CLI (if installed)**

```powershell
# Create repository using gh CLI
gh repo create image-factory-demo --public --source=. --remote=origin
```

### Step 4: Add Remote and Push

```powershell
# Add GitHub repository as remote (replace with your actual URL)
git remote add origin https://github.com/YOUR_USERNAME/image-factory-demo.git

# Rename branch to main (if needed)
git branch -M main

# Push to GitHub
git push -u origin main
```

**Complete Example:**
```powershell
git remote add origin https://github.com/johndoe/image-factory-demo.git
git branch -M main
git push -u origin main
```

---

## Verification

After pushing, verify:

1. ✅ Go to your GitHub repository URL in browser
2. ✅ You should see all files including:
   - [README.md](README.md)
   - [SELF_HOSTED_SETUP.md](SELF_HOSTED_SETUP.md)
   - [.github/workflows/image-factory.yml](.github/workflows/image-factory.yml)
3. ✅ GitHub Actions tab should show the workflow (not yet run)

---

## Complete Command Sequence (Copy-Paste Ready)

**Replace placeholders with your actual information:**

```powershell
# Step 1: Set git user info
git config user.name "YOUR_NAME"
git config user.email "YOUR_EMAIL"

# Step 2: Commit
git commit -m "Configure project for self-hosted GitHub Actions runner"

# Step 3: Add remote (replace URL)
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git

# Step 4: Rename branch and push
git branch -M main
git push -u origin main
```

---

## What's Included in This Commit

### Documentation Files (New)
- ✅ [README.md](README.md) - Project overview
- ✅ [SELF_HOSTED_SETUP.md](SELF_HOSTED_SETUP.md) - Complete setup guide
- ✅ [QUICK_START.md](QUICK_START.md) - Quick reference
- ✅ [ARCHITECTURE.md](ARCHITECTURE.md) - System architecture
- ✅ [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Problem solving
- ✅ [SETUP_STEPS_SUMMARY.md](SETUP_STEPS_SUMMARY.md) - Complete checklist
- ✅ [.gitignore](.gitignore) - Git exclusions

### Modified Files
- ✅ [.github/workflows/image-factory.yml](.github/workflows/image-factory.yml) - Self-hosted runner config

### Existing Project Files
- All PowerShell scripts in `scripts/`
- Configuration files in `configs/`
- Packer templates in `packer/`
- Test files in `tests/`

---

## Troubleshooting Git Setup

### "Authentication Failed" When Pushing

**Solution 1: Use Personal Access Token (PAT)**

1. GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Generate new token (classic)
3. Select scopes: `repo` (all)
4. Copy token and save securely
5. When prompted for password during push, use token instead

**Solution 2: Use SSH**

```powershell
# Generate SSH key (if not exists)
ssh-keygen -t ed25519 -C "your.email@example.com"

# Add to SSH agent
Get-Service ssh-agent | Set-Service -StartupType Automatic
Start-Service ssh-agent
ssh-add ~\.ssh\id_ed25519

# Copy public key
Get-Content ~\.ssh\id_ed25519.pub | Set-Clipboard

# Add to GitHub: Settings → SSH and GPG keys → New SSH key
# Paste key and save

# Update remote URL to use SSH
git remote set-url origin git@github.com:YOUR_USERNAME/YOUR_REPO.git
```

### "Repository Already Exists" on GitHub

If you already created the repository:

```powershell
# Just add remote and push
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git push -u origin main
```

### "Permission Denied" or "403 Forbidden"

- Verify you're logged into correct GitHub account
- Check repository permissions (must be owner or have write access)
- Ensure PAT has correct scopes

### "Updates Were Rejected" (Non-Fast-Forward)

If repository has existing commits:

```powershell
# Pull first, then push
git pull origin main --allow-unrelated-histories
git push -u origin main
```

---

## After Pushing to GitHub

### Immediate Next Steps

1. **Set up self-hosted runner** → Follow [SELF_HOSTED_SETUP.md](SELF_HOSTED_SETUP.md)
2. **Configure runner labels** → Use `[self-hosted, windows]`
3. **Test workflow** → Actions tab → Run workflow

### Update README Badge

In [README.md](README.md), update the badge URL:

```markdown
[![Windows Image Factory Demo](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/image-factory.yml/badge.svg)](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/image-factory.yml)
```

Replace `YOUR_USERNAME` and `YOUR_REPO` with actual values.

---

## Future Git Operations

### Making Changes

```powershell
# After editing files
git add .
git commit -m "Description of changes"
git push
```

### Checking Status

```powershell
git status              # See what changed
git log --oneline -10   # Recent commits
git diff                # See uncommitted changes
```

### Creating Branches

```powershell
# Create and switch to new branch
git checkout -b feature/new-feature

# Make changes, commit
git add .
git commit -m "Add new feature"

# Push branch
git push -u origin feature/new-feature

# Create PR on GitHub
```

---

## Summary

✅ Repository is initialized and ready  
⏳ **Next:** Run the PowerShell commands above to commit and push  
🎯 **Goal:** Get code on GitHub so you can set up self-hosted runner  

**Need help?** Check troubleshooting section above or refer to [Git documentation](https://git-scm.com/doc).
