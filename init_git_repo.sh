#!/bin/bash

# Automated Git Repository Initialization and GitHub Push Script
# for Euystacio Foundation & Sentimento Codex Package
#
# This script will:
# 1. Navigate to the project directory
# 2. Initialize the git repository (if not already initialized)
# 3. Add all files
# 4. Commit the changes with a specific message
# 5. Add the remote repository (if not already added)
# 6. Set the branch name to main
# 7. Push to GitHub
# 8. Print a confirmation message on completion

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration variables - modify these as needed
REMOTE_REPO_URL="https://github.com/hannesmitterer/euystacio_foundation_package.git"
COMMIT_MESSAGE="Initial commit: Euystacio Foundation & Sentimento Codex package"
BRANCH_NAME="main"

echo -e "${BLUE}🚀 Starting Git Repository Initialization for Euystacio Foundation & Sentimento Codex${NC}"
echo "============================================================================="

# Step 1: Navigate to the project directory (current directory)
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo -e "${YELLOW}Step 1: Navigating to project directory${NC}"
echo "Project directory: $PROJECT_DIR"
cd "$PROJECT_DIR"

# Step 2: Initialize git repository (if not already initialized)
echo -e "${YELLOW}Step 2: Initializing Git repository${NC}"
if [ -d ".git" ]; then
    echo "✓ Git repository already initialized"
else
    git init
    echo "✓ Git repository initialized"
fi

# Configure Git user if not already configured
echo -e "${YELLOW}Step 2.1: Configuring Git user (if needed)${NC}"
if ! git config user.name >/dev/null 2>&1; then
    git config user.name "Euystacio Foundation"
    echo "✓ Git user name configured"
fi
if ! git config user.email >/dev/null 2>&1; then
    git config user.email "foundation@euystacio.org"
    echo "✓ Git user email configured"
fi

# Step 3: Add all files
echo -e "${YELLOW}Step 3: Adding all files to Git${NC}"
git add .
echo "✓ All files added to staging area"

# Check if there are any changes to commit
if git diff --cached --quiet; then
    echo -e "${GREEN}ℹ️  No changes to commit - repository is up to date${NC}"
else
    # Step 4: Commit the changes
    echo -e "${YELLOW}Step 4: Committing changes${NC}"
    git commit -m "$COMMIT_MESSAGE"
    echo "✓ Changes committed with message: '$COMMIT_MESSAGE'"
fi

# Step 5: Add remote repository (if not already added)
echo -e "${YELLOW}Step 5: Setting up remote repository${NC}"
if git remote get-url origin >/dev/null 2>&1; then
    CURRENT_REMOTE=$(git remote get-url origin)
    echo "✓ Remote 'origin' already exists: $CURRENT_REMOTE"
    if [ "$CURRENT_REMOTE" != "$REMOTE_REPO_URL" ]; then
        echo -e "${YELLOW}⚠️  Updating remote URL to: $REMOTE_REPO_URL${NC}"
        git remote set-url origin "$REMOTE_REPO_URL"
        echo "✓ Remote URL updated"
    fi
else
    git remote add origin "$REMOTE_REPO_URL"
    echo "✓ Remote 'origin' added: $REMOTE_REPO_URL"
fi

# Step 6: Set branch name to main
echo -e "${YELLOW}Step 6: Setting branch name to '$BRANCH_NAME'${NC}"
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "$BRANCH_NAME" ]; then
    # Check if main branch exists
    if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
        git checkout "$BRANCH_NAME"
        echo "✓ Switched to existing '$BRANCH_NAME' branch"
    else
        git checkout -b "$BRANCH_NAME"
        echo "✓ Created and switched to '$BRANCH_NAME' branch"
    fi
else
    echo "✓ Already on '$BRANCH_NAME' branch"
fi

# Step 7: Push to GitHub
echo -e "${YELLOW}Step 7: Pushing to GitHub${NC}"
# Check if we have any commits to push
if git rev-parse --verify HEAD >/dev/null 2>&1; then
    # Attempt to set upstream and push
    if git push -u origin "$BRANCH_NAME" 2>/dev/null; then
        echo "✓ Successfully pushed to GitHub (origin/$BRANCH_NAME)"
        PUSH_SUCCESS=true
    else
        echo -e "${YELLOW}⚠️  Push to GitHub failed - likely due to authentication${NC}"
        echo -e "${YELLOW}   This is normal if you need to set up authentication${NC}"
        PUSH_SUCCESS=false
    fi
else
    echo -e "${RED}❌ No commits found - cannot push empty repository${NC}"
    exit 1
fi

# Step 8: Print confirmation message
echo ""
echo "============================================================================="
if [ "$PUSH_SUCCESS" = true ]; then
    echo -e "${GREEN}🎉 SUCCESS: Git repository initialization and GitHub push completed!${NC}"
else
    echo -e "${GREEN}🎉 SUCCESS: Git repository initialization completed!${NC}"
    echo -e "${YELLOW}📝 Note: Push to GitHub requires authentication setup${NC}"
fi
echo ""
echo -e "${BLUE}Repository Details:${NC}"
echo "  📁 Project Directory: $PROJECT_DIR"
echo "  🌐 Remote Repository: $REMOTE_REPO_URL"
echo "  🌿 Branch: $BRANCH_NAME"
echo "  💬 Commit Message: $COMMIT_MESSAGE"
echo ""
if [ "$PUSH_SUCCESS" = true ]; then
    echo -e "${GREEN}The Euystacio Foundation & Sentimento Codex package has been successfully"
    echo -e "initialized and pushed to GitHub! 🚀${NC}"
else
    echo -e "${GREEN}The Euystacio Foundation & Sentimento Codex package has been successfully"
    echo -e "initialized locally! 🚀${NC}"
    echo ""
    echo -e "${YELLOW}To complete the GitHub push, please:${NC}"
    echo "  1. Set up GitHub authentication (SSH key or Personal Access Token)"
    echo "  2. Run: git push -u origin $BRANCH_NAME"
    echo "  3. Or configure your Git credentials and re-run this script"
fi
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  • Visit your GitHub repository to verify the upload"
echo "  • Set up branch protection rules if needed"
echo "  • Configure repository settings and collaborators"
echo "  • Start collaborating on the Euystacio Foundation project!"
echo ""