# GitHub Push Troubleshooting Guide

Common errors when pushing to GitHub and how to fix them.

## Error 1: "fatal: could not read Username for 'https://github.com': No such device or address"

**Cause**: Git can't authenticate over HTTPS (network issue or missing credentials)

**Solution A: Use GitHub Personal Access Token (Recommended)**
```bash
# 1. Create a Personal Access Token at: https://github.com/settings/tokens
#    - Scope: repo (full control of private repos)
#    - Save the token securely

# 2. Configure git to use token
git config --global credential.helper store
git push https://github.com/shantoshdurai/ClassNow-app.git main

# When prompted:
# Username: shantoshdurai (your GitHub username)
# Password: <paste your Personal Access Token here>

# 3. Git will save credentials locally for future pushes
```

**Solution B: Use SSH (More Secure)**
```bash
# 1. Generate SSH key (if you don't have one)
ssh-keygen -t ed25519 -C "shantoshdurai06@gmail.com"
# Press Enter for all prompts (or set custom passphrase)

# 2. Add SSH key to GitHub
# - Copy: cat ~/.ssh/id_ed25519.pub
# - Go to: https://github.com/settings/keys
# - Click "New SSH Key" and paste

# 3. Configure git to use SSH
git remote set-url origin git@github.com:shantoshdurai/ClassNow-app.git

# 4. Push
git push origin main
```

## Error 2: "fatal: the current branch main has no upstream branch"

**Cause**: Local branch not tracking remote branch

**Solution**:
```bash
# Set upstream branch
git push -u origin main

# Or configure existing branch
git branch --set-upstream-to=origin/main main
git push origin main
```

## Error 3: "error: failed to push some refs to 'https://github.com/...'"

**Cause**: Remote has commits you don't have locally (someone else pushed)

**Solution**:
```bash
# Pull latest changes first
git pull origin main

# Resolve any merge conflicts if prompted
# Then push
git push origin main
```

## Error 4: "Please make sure you have the correct access rights"

**Cause**: SSH key not configured or wrong key permissions

**Solution**:
```bash
# Check if SSH key works
ssh -T git@github.com

# Should say: "Hi shantoshdurai! You've successfully authenticated..."

# If fails, regenerate SSH key (see Solution B above)
```

## One-Time Setup (Do This Once)

```bash
# Set git credentials globally (choose one method above)
# Then you won't need to authenticate on every push

# For HTTPS + Token:
git config --global credential.helper store

# For SSH:
ssh-keygen -t ed25519 -C "your_email@gmail.com"
# Add public key to GitHub
```

## Quick Reference

**To push after setup:**
```bash
git add -A
git commit -m "your message"
git push origin main
```

**To check current remote:**
```bash
git remote -v
```

**To change between HTTPS and SSH:**
```bash
# HTTPS
git remote set-url origin https://github.com/shantoshdurai/ClassNow-app.git

# SSH
git remote set-url origin git@github.com:shantoshdurai/ClassNow-app.git
```

---

> **Recommendation**: Use SSH for better security. Set it up once and forget about it.
