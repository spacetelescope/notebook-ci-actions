# 🎯 Testing Decision Tree

Use this flowchart to quickly decide which testing approach to use:

```
🤔 What do you want to test?
│
├─ 📝 Just changed workflow files?
│   └─ ✅ ./scripts/validate-workflows.sh (30 seconds)
│
├─ 📓 Changed notebooks or dependencies?
│   ├─ 🏃‍♂️ Quick check during development?
│   │   └─ ✅ EXECUTION_MODE=validation-only ./scripts/test-local-ci.sh (1-2 min)
│   │
│   ├─ 🔬 Testing specific notebook?
│   │   └─ ✅ SINGLE_NOTEBOOK=path/to/notebook.ipynb ./scripts/test-local-ci.sh (2-5 min)
│   │
│   └─ 🎯 Full validation before commit?
│       └─ ✅ ./scripts/test-local-ci.sh (5-15 min)
│
└─ 🚀 Ready to push/create PR?
    └─ ✅ ./scripts/test-with-act.sh pull_request (5-10 min)
```

## ⚡ Speed vs. Thoroughness

```
Validation Only     Quick Test        Full Test         Act Testing
(30 seconds)       (1-2 minutes)     (5-15 minutes)    (5-10 minutes)
     ├─────────────────├─────────────────├─────────────────┤
   Speed            Balance          Thoroughness      Complete
```

## 🎮 Choose Your Testing Style

### 🏃‍♂️ **Speed Demon** (Development Mode)
```bash
# Minimal testing for rapid iteration
./scripts/validate-workflows.sh
EXECUTION_MODE=validation-only ./scripts/test-local-ci.sh
```
**Use when**: Making frequent small changes, debugging

### 🔬 **Balanced Tester** (Default Mode)  
```bash
# Good coverage without too much time
./scripts/validate-workflows.sh
./scripts/test-local-ci.sh
```
**Use when**: Normal development, testing features

### 🛡️ **Quality Guardian** (Pre-Push Mode)
```bash
# Maximum confidence before sharing
./scripts/validate-workflows.sh
./scripts/test-local-ci.sh
./scripts/test-with-act.sh pull_request
```
**Use when**: Creating PRs, major changes

## 📍 Repository Quick Start

Based on your repository type:

### 🌟 Hello Universe (Educational)
```bash
# Lightweight testing
RUN_SECURITY_SCAN=false ./scripts/test-local-ci.sh
```

### 🔭 JDAT Notebooks (JWST)
```bash
# With CRDS environment
export CRDS_SERVER_URL="https://jwst-crds.stsci.edu"
export CRDS_PATH="/tmp/crds_cache"
./scripts/test-local-ci.sh
```

### 🚀 JWST Pipeline
```bash
# Full testing (jdaviz may need validation-only mode locally)
EXECUTION_MODE=validation-only ./scripts/test-local-ci.sh
```

### 📡 HST Notebooks
```bash
# Validation only (hstcal environment complex)
EXECUTION_MODE=validation-only ./scripts/test-local-ci.sh
```

### 🌌 MAST Notebooks
```bash
# Standard testing
./scripts/test-local-ci.sh
```

## 🔧 One-Line Setups

Copy and paste these for instant testing:

```bash
# Quick validation
./scripts/validate-workflows.sh && echo "✅ Workflows valid!"

# Development testing  
EXECUTION_MODE=validation-only ./scripts/test-local-ci.sh && echo "✅ Quick test passed!"

# Full confidence testing
./scripts/validate-workflows.sh && ./scripts/test-local-ci.sh && echo "✅ Ready to commit!"

# Complete pre-push testing
./scripts/validate-workflows.sh && ./scripts/test-local-ci.sh && ./scripts/test-with-act.sh pull_request && echo "✅ Ready to push!"
```
