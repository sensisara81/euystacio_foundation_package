#!/bin/bash

# =============================================================================
# Euystacio Foundation - Git Repository Initialization Script
# =============================================================================
# 
# This script automates the process of initializing a Git repository,
# configuring it for the Euystacio Foundation, and pushing to GitHub.
#
# Author: Euystacio Foundation
# Version: 1.0.0
# License: GPL v3 (same as repository)
#
# =============================================================================

# Color codes for output formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Script configuration
FOUNDATION_USER_NAME="Euystacio Foundation"
FOUNDATION_USER_EMAIL="foundation@euystacio.org"
DEFAULT_BRANCH="main"

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BOLD}${CYAN}$1${NC}"
}

# Display usage information
show_usage() {
    cat << EOF
${BOLD}Euystacio Foundation - Git Repository Initialization Script${NC}

${BOLD}USAGE:${NC}
    $0 <project_directory> <github_repository_url>

${BOLD}PARAMETERS:${NC}
    project_directory      Path to the project directory to initialize
    github_repository_url  GitHub repository URL (e.g., https://github.com/user/repo.git)

${BOLD}EXAMPLES:${NC}
    $0 /path/to/my/project https://github.com/user/my-repo.git
    $0 ./my-local-project git@github.com:user/my-repo.git

${BOLD}DESCRIPTION:${NC}
    This script will:
    • Navigate to the specified project directory
    • Initialize a Git repository (if not already initialized)
    • Configure Git user credentials for Euystacio Foundation
    • Add all files to the repository
    • Commit changes with an appropriate message (if there are staged changes)
    • Add or update the remote GitHub repository
    • Set the default branch to 'main'
    • Attempt to push to GitHub (may require authentication)
    • Display completion message and authentication setup instructions

${BOLD}AUTHENTICATION:${NC}
    This script may prompt for GitHub authentication. For automated workflows,
    consider setting up SSH keys or Personal Access Tokens as described in
    the completion message.

EOF
}

# Validate command line arguments
validate_arguments() {
    if [ $# -ne 2 ]; then
        print_error "Invalid number of arguments provided."
        show_usage
        exit 1
    fi

    PROJECT_DIR="$1"
    GITHUB_URL="$2"

    # Validate project directory
    if [ -z "$PROJECT_DIR" ]; then
        print_error "Project directory cannot be empty."
        exit 1
    fi

    # Validate GitHub URL format
    if [[ ! "$GITHUB_URL" =~ ^(https://github\.com/|git@github\.com:).+\.git$ ]] && [[ ! "$GITHUB_URL" =~ ^(https://github\.com/|git@github\.com:).+$ ]]; then
        print_error "Invalid GitHub repository URL format."
        print_info "Expected formats: https://github.com/user/repo.git or git@github.com:user/repo.git"
        exit 1
    fi
}

# Check if directory exists and is accessible
validate_directory() {
    if [ ! -d "$PROJECT_DIR" ]; then
        print_error "Directory '$PROJECT_DIR' does not exist."
        print_info "Please create the directory first or provide a valid path."
        exit 1
    fi

    if [ ! -r "$PROJECT_DIR" ] || [ ! -w "$PROJECT_DIR" ]; then
        print_error "Directory '$PROJECT_DIR' is not readable/writable."
        exit 1
    fi
}

# =============================================================================
# MAIN FUNCTIONS
# =============================================================================

# Navigate to project directory
navigate_to_directory() {
    print_info "Navigating to project directory: $PROJECT_DIR"
    cd "$PROJECT_DIR" || {
        print_error "Failed to navigate to directory '$PROJECT_DIR'"
        exit 1
    }
    print_success "Successfully navigated to $(pwd)"
}

# Initialize Git repository if it doesn't exist
initialize_git_repo() {
    if [ -d ".git" ]; then
        print_info "Git repository already initialized in this directory."
    else
        print_info "Initializing Git repository..."
        if git init; then
            print_success "Git repository initialized successfully."
        else
            print_error "Failed to initialize Git repository."
            exit 1
        fi
    fi
}

# Configure Git user credentials
configure_git_credentials() {
    print_info "Configuring Git user credentials for Euystacio Foundation..."
    
    if git config user.name "$FOUNDATION_USER_NAME" && git config user.email "$FOUNDATION_USER_EMAIL"; then
        print_success "Git user credentials configured:"
        print_info "  Name: $FOUNDATION_USER_NAME"
        print_info "  Email: $FOUNDATION_USER_EMAIL"
    else
        print_error "Failed to configure Git user credentials."
        exit 1
    fi
}

# Add all files to repository
add_files_to_repo() {
    print_info "Adding all files to the repository..."
    
    # Count files to be added
    if command -v find >/dev/null 2>&1; then
        file_count=$(find . -type f -not -path "./.git/*" | wc -l)
        print_info "Found $file_count files to add (excluding .git directory)"
    fi
    
    if git add .; then
        print_success "All files added to repository."
    else
        print_error "Failed to add files to repository."
        exit 1
    fi
}

# Commit changes if there are staged changes
commit_changes() {
    print_info "Checking for staged changes..."
    
    if git diff --cached --quiet; then
        print_warning "No staged changes found. Skipping commit."
        return 0
    else
        staged_files=$(git diff --cached --name-only | wc -l)
        print_info "Found $staged_files staged files to commit."
        
        # Create an appropriate commit message
        commit_message="Initial commit for Euystacio Foundation project

This commit includes all project files and initializes the repository
for the Euystacio Foundation with proper Git configuration.

Generated by: Euystacio Foundation Git Initialization Script
Date: $(date '+%Y-%m-%d %H:%M:%S')"
        
        print_info "Committing changes..."
        if git commit -m "$commit_message"; then
            print_success "Changes committed successfully."
        else
            print_error "Failed to commit changes."
            exit 1
        fi
    fi
}

# Add or update remote GitHub repository
configure_remote() {
    print_info "Configuring remote GitHub repository..."
    
    # Check if remote 'origin' already exists
    if git remote get-url origin >/dev/null 2>&1; then
        current_url=$(git remote get-url origin)
        print_warning "Remote 'origin' already exists: $current_url"
        
        if [ "$current_url" = "$GITHUB_URL" ]; then
            print_info "Remote URL is already correct."
        else
            print_info "Updating remote URL to: $GITHUB_URL"
            if git remote set-url origin "$GITHUB_URL"; then
                print_success "Remote URL updated successfully."
            else
                print_error "Failed to update remote URL."
                exit 1
            fi
        fi
    else
        print_info "Adding remote repository: $GITHUB_URL"
        if git remote add origin "$GITHUB_URL"; then
            print_success "Remote repository added successfully."
        else
            print_error "Failed to add remote repository."
            exit 1
        fi
    fi
}

# Set branch name to main
set_main_branch() {
    print_info "Setting default branch to '$DEFAULT_BRANCH'..."
    
    current_branch=$(git branch --show-current)
    if [ "$current_branch" = "$DEFAULT_BRANCH" ]; then
        print_info "Already on '$DEFAULT_BRANCH' branch."
    else
        print_info "Current branch: $current_branch"
        print_info "Renaming branch to '$DEFAULT_BRANCH'..."
        if git branch -M "$DEFAULT_BRANCH"; then
            print_success "Branch renamed to '$DEFAULT_BRANCH'."
        else
            print_error "Failed to rename branch to '$DEFAULT_BRANCH'."
            exit 1
        fi
    fi
}

# Attempt to push to GitHub
push_to_github() {
    print_info "Attempting to push to GitHub..."
    print_warning "This may prompt for authentication if not already configured."
    
    # Set upstream and push
    if git push -u origin "$DEFAULT_BRANCH"; then
        print_success "Successfully pushed to GitHub!"
    else
        print_warning "Failed to push to GitHub. This is often due to authentication issues."
        print_info "Don't worry - the repository is properly configured locally."
        print_info "See the authentication instructions below to resolve this."
        return 1
    fi
}

# Display completion message and authentication instructions
show_completion_message() {
    print_header "=============================================="
    print_header "  REPOSITORY INITIALIZATION COMPLETE!"
    print_header "=============================================="
    echo
    print_success "Your Git repository has been successfully initialized and configured!"
    echo
    print_info "Repository Details:"
    print_info "  Location: $(pwd)"
    print_info "  Remote URL: $GITHUB_URL"
    print_info "  Default Branch: $DEFAULT_BRANCH"
    print_info "  Git User: $FOUNDATION_USER_NAME <$FOUNDATION_USER_EMAIL>"
    echo

    # Show git status
    print_info "Current Repository Status:"
    git status --short --branch
    echo

    print_header "AUTHENTICATION SETUP INSTRUCTIONS:"
    echo
    print_info "If you encountered authentication issues during push, set up one of the following:"
    echo
    print_info "${BOLD}Option 1: SSH Keys (Recommended for regular use)${NC}"
    print_info "  1. Generate SSH key: ${CYAN}ssh-keygen -t ed25519 -C \"$FOUNDATION_USER_EMAIL\"${NC}"
    print_info "  2. Add to SSH agent: ${CYAN}ssh-add ~/.ssh/id_ed25519${NC}"
    print_info "  3. Copy public key: ${CYAN}cat ~/.ssh/id_ed25519.pub${NC}"
    print_info "  4. Add to GitHub: Settings → SSH and GPG keys → New SSH key"
    print_info "  5. Test connection: ${CYAN}ssh -T git@github.com${NC}"
    echo
    print_info "${BOLD}Option 2: Personal Access Token (For HTTPS)${NC}"
    print_info "  1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)"
    print_info "  2. Generate new token with 'repo' scope"
    print_info "  3. Use token as password when prompted"
    print_info "  4. Optional: Store credentials with ${CYAN}git config --global credential.helper store${NC}"
    echo
    print_info "${BOLD}Option 3: GitHub CLI (Easiest for one-time setup)${NC}"
    print_info "  1. Install GitHub CLI: ${CYAN}https://cli.github.com/${NC}"
    print_info "  2. Authenticate: ${CYAN}gh auth login${NC}"
    print_info "  3. Follow the interactive prompts"
    echo
    print_info "${BOLD}Manual Push (if needed):${NC}"
    print_info "  After setting up authentication, manually push with:"
    print_info "  ${CYAN}cd $(pwd)${NC}"
    print_info "  ${CYAN}git push -u origin main${NC}"
    echo
    print_header "=============================================="
    print_success "Happy coding for the Euystacio Foundation! 🚀"
    print_header "=============================================="
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    # Show header
    print_header "=============================================="
    print_header "  Euystacio Foundation Git Init Script"
    print_header "=============================================="
    echo

    # Validate arguments
    validate_arguments "$@"
    
    # Validate directory
    validate_directory
    
    # Execute main workflow
    navigate_to_directory
    initialize_git_repo
    configure_git_credentials
    add_files_to_repo
    commit_changes
    configure_remote
    set_main_branch
    
    # Attempt push (don't exit on failure)
    if ! push_to_github; then
        PUSH_FAILED=true
    fi
    
    # Show completion message
    show_completion_message
    
    # Exit with appropriate code
    if [ "${PUSH_FAILED:-false}" = "true" ]; then
        exit 2  # Special exit code for authentication issues
    else
        exit 0
    fi
}

# Handle help flags
case "${1:-}" in
    -h|--help|help)
        show_usage
        exit 0
        ;;
esac

# Run main function with all arguments
main "$@"