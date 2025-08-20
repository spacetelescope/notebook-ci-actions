#!/bin/bash

# Deploy Notebook CI/CD workflows to hellouniverse repository
# Usage: ./deploy-to-hellouniverse.sh [path-to-hellouniverse-repo]

set -e

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Deploying Notebook CI/CD to hellouniverse${NC}"
echo ""

# Get target repository path
TARGET_REPO="$1"
if [ -z "$TARGET_REPO" ]; then
    echo -e "${YELLOW}Please provide the path to hellouniverse repository:${NC}"
    echo "Usage: $0 /path/to/hellouniverse"
    exit 1
fi

# Verify target repo exists
if [ ! -d "$TARGET_REPO" ]; then
    echo "❌ Directory $TARGET_REPO does not exist"
    exit 1
fi

if [ ! -d "$TARGET_REPO/.git" ]; then
    echo "❌ $TARGET_REPO is not a git repository"
    exit 1
fi

echo -e "${BLUE}📋 Target repository: $TARGET_REPO${NC}"

# Create .github/workflows directory if it doesn't exist
mkdir -p "$TARGET_REPO/.github/workflows"

# Copy the main on-demand workflow
echo -e "${BLUE}📝 Copying on-demand workflow...${NC}"
cp "examples/caller-workflows/notebook-on-demand.yml" "$TARGET_REPO/.github/workflows/"
echo "  ✅ notebook-on-demand.yml"

# Copy other essential workflows (optional)
echo -e "${BLUE}📝 Copying additional workflow templates...${NC}"
cp "examples/caller-workflows/notebook-pr.yml" "$TARGET_REPO/.github/workflows/"
echo "  ✅ notebook-pr.yml"

cp "examples/caller-workflows/notebook-merge.yml" "$TARGET_REPO/.github/workflows/"
echo "  ✅ notebook-merge.yml"

# Copy notebooks directory for testing (if it doesn't exist)
if [ ! -d "$TARGET_REPO/notebooks" ]; then
    echo -e "${BLUE}📓 Copying sample notebooks...${NC}"
    cp -r "notebooks" "$TARGET_REPO/"
    echo "  ✅ notebooks/ directory with samples"
else
    echo "  ℹ️  notebooks/ directory already exists, skipping"
fi

# Copy documentation
echo -e "${BLUE}📚 Copying essential documentation...${NC}"
mkdir -p "$TARGET_REPO/docs"
cp "docs/configuration-reference.md" "$TARGET_REPO/docs/" 2>/dev/null || echo "  ⚠️  configuration-reference.md not found"
cp "docs/troubleshooting-unified.md" "$TARGET_REPO/docs/" 2>/dev/null || echo "  ⚠️  troubleshooting-unified.md not found"

echo ""
echo -e "${GREEN}🎉 Deployment completed!${NC}"
echo ""
echo -e "${BLUE}📋 Next steps:${NC}"
echo "1. cd $TARGET_REPO"
echo "2. git add .github/workflows/ notebooks/ docs/"
echo "3. git commit -m 'Add notebook CI/CD workflows'"
echo "4. git push"
echo ""
echo -e "${BLUE}🎯 Available workflows in hellouniverse:${NC}"
echo "  - notebook-on-demand.yml (10 action types)"
echo "  - notebook-pr.yml (PR validation)"
echo "  - notebook-merge.yml (merge/main branch)"
echo ""
echo -e "${BLUE}💡 To test:${NC}"
echo "  - Go to GitHub Actions in hellouniverse repository"
echo "  - Run 'Notebook CI - On-Demand Actions' workflow"
echo "  - Select action type (validate-all, execute-all, etc.)"
