#!/usr/bin/env zsh

set -euo pipefail
set -E  # ERR trap inheritance

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
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

# Function to check if running on macOS
check_macos() {
    if [[ "$(uname)" != "Darwin" ]]; then
        print_error "This script is designed for macOS only"
        exit 1
    fi
    print_success "Running on macOS"
}

# Function to check if Nix is installed (Determinate Systems)
check_nix() {
    if ! command -v nix &> /dev/null; then
        print_error "Nix is not installed. Please install Determinate Systems Nix first:"
        echo "curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install"
        exit 1
    fi
    print_success "Nix is installed"
}

# Function to check if we're in the nix-config directory
check_directory() {
    if [[ ! -f "flake.nix" ]]; then
        print_error "flake.nix not found. Please run this script from the nix-config directory"
        exit 1
    fi
    print_success "In nix-config directory"
}

# Function to backup existing configurations
backup_configs() {
    print_status "Backing up existing configurations..."

    # Create timestamp for backup
    local timestamp=$(date +"%Y%m%d_%H%M%S")

    # Backup /etc/zshenv if it exists
    if [[ -f "/etc/zshenv" ]]; then
        local backup_name="/etc/zshenv.backup.${timestamp}"
        if [[ "$DRY_RUN" == true ]]; then
            print_status "Would backup: /etc/zshenv -> $backup_name"
        else
            sudo cp /etc/zshenv "$backup_name"
            BACKUP_FILES+=("$backup_name")
            print_success "Backed up /etc/zshenv to $backup_name"
        fi

        # Remove existing /etc/zshenv to allow nix-darwin to manage it
        if [[ "$DRY_RUN" == true ]]; then
            print_status "Would remove: /etc/zshenv"
        else
            sudo rm /etc/zshenv
            print_status "Removed existing /etc/zshenv for nix-darwin management"
        fi
    else
        print_status "No existing /etc/zshenv to backup"
    fi

    print_success "Configuration backup completed"
}

# Function to clean up previous failed builds
cleanup_failed_builds() {
    print_status "Cleaning up any previous failed builds..."

    # Clean nix store
    if [[ "$DRY_RUN" == true ]]; then
        print_status "Would run: nix store gc --verbose"
    else
        nix store gc --verbose
    fi

    # Clean home-manager if it exists
    if [[ -d ~/.config/home-manager ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            print_status "Would remove: ~/.config/home-manager"
        else
            rm -rf ~/.config/home-manager
            print_status "Cleaned previous home-manager configuration"
        fi
    fi

    print_success "Cleanup completed"
}

# Function to build and switch nix-darwin configuration
build_darwin_config() {
    local hostname=${1:-$(hostname -s)}

    print_status "Building and switching nix-darwin configuration for $hostname..."

    # Check if the configuration exists
    if ! nix flake show . | grep -q "$hostname"; then
        print_error "Configuration for '$hostname' not found in flake"
        print_status "Available configurations:"
        nix flake show . --json | jq -r '.darwinConfigurations | keys[]' 2>/dev/null || nix flake show .
        exit 1
    fi

    # Build and switch configuration
    if [[ "$DRY_RUN" == true ]]; then
        print_status "Would run: sudo nix run nix-darwin -- switch --flake \".#$hostname\""
        print_success "nix-darwin configuration activation simulated successfully"
    else
        if sudo nix run nix-darwin -- switch --flake ".#$hostname"; then
            print_success "nix-darwin configuration activated successfully"
        else
            print_error "Failed to activate nix-darwin configuration"
            exit 1
        fi
    fi
}

# Function to validate configuration before applying
validate_configuration() {
    local hostname=${1:-$(hostname -s)}

    print_status "Validating configuration for $hostname..."

    # Check if the configuration exists in flake
    if ! nix flake show . | grep -q "$hostname"; then
        print_error "Configuration for '$hostname' not found in flake"
        print_status "Available configurations:"
        nix flake show . --json | jq -r '.darwinConfigurations | keys[]' 2>/dev/null || nix flake show .
        exit 1
    fi

    # Validate flake configuration syntax
    if [[ "$DRY_RUN" == true ]]; then
        print_status "Would validate flake configuration: nix flake check . --show-trace"
    else
        if nix flake check . --show-trace; then
            print_success "Configuration validation passed"
        else
            print_error "Configuration validation failed"
            exit 1
        fi
    fi
}

# Function to verify installation
verify_installation() {
    print_status "Verifying installation..."

    # Check if nix-darwin was activated
    if [[ -d "/etc/nix-darwin" ]]; then
        print_success "nix-darwin is activated"
    else
        print_warning "nix-darwin directory not found, but this might be normal"
    fi

    # Check if home-manager configs are applied
    if [[ -L "$HOME/.config/wezterm/wezterm.lua" ]]; then
        print_success "Wezterm configuration is linked"
    else
        print_warning "Wezterm configuration not found"
    fi

    if [[ -L "$HOME/.config/starship.toml" ]]; then
        print_success "Starship configuration is linked"
    else
        print_warning "Starship configuration not found"
    fi

    # Check if key programs are available
    local programs=("wezterm" "starship" "eza" "fzf" "tmux")
    for program in "${programs[@]}"; do
        if command -v "$program" &> /dev/null; then
            print_success "$program is available"
        else
            print_warning "$program not found in PATH"
        fi
    done

    # Check if Homebrew packages are installed
    local brew_packages=("bitwarden-cli" "neovim" "chatgpt-atlas" "discord" "visual-studio-code")
    for package in "${brew_packages[@]}"; do
        if brew list "$package" &> /dev/null 2>&1; then
            print_success "$package is installed via Homebrew"
        else
            print_warning "$package not found via Homebrew"
        fi
    done
}

# Function to show post-installation information
post_install_info() {
    print_status "Post-installation information:"
    echo
    echo "🎉 Setup completed successfully!"
    echo
    echo "📝 Next steps:"
    echo "1. Restart your terminal to ensure all shell changes take effect"
    echo "2. Open Wezterm to test your terminal configuration"
    echo "3. Your custom dock configuration should now be active"
    echo "4. Homebrew apps have been installed and managed by nix-darwin"
    echo
    echo "🔧 Useful commands:"
    echo "- Rebuild configuration: sudo nix run nix-darwin -- switch --flake .#<hostname>"
    echo "- Check configuration: nix run nix-darwin -- check --flake .#<hostname>"
    echo "- Update packages: sudo nix run nix-darwin -- switch --flake .#<hostname> --update-input"
    echo
    echo "📁 Configuration locations:"
    echo "- Wezterm: ~/.config/wezterm/wezterm.lua"
    echo "- Starship: ~/.config/starship.toml"
    echo "- Tmux: ~/.config/tmux/tmux.conf"
    echo "- Zsh: ~/.zshrc"
    echo
    echo "If you encounter any issues, check the nix-darwin logs above."
}

# Global variables
DRY_RUN=false
VERBOSE=false

# Track backup files for potential rollback
BACKUP_FILES=()

# Function to rollback changes
rollback() {
    if [[ ${#BACKUP_FILES[@]} -gt 0 ]]; then
        print_warning "Rolling back changes..."
        for backup_file in "${BACKUP_FILES[@]}"; do
            original_file="${backup_file%.backup}"
            if [[ -f "$backup_file" ]]; then
                if [[ "$DRY_RUN" == true ]]; then
                    print_status "Would restore: $backup_file -> $original_file"
                else
                    sudo cp "$backup_file" "$original_file"
                    print_status "Restored: $backup_file -> $original_file"
                fi
            fi
        done
    fi

    if [[ "$DRY_RUN" == false ]]; then
        # Clean up any temporary home-manager config
        if [[ -d ~/.config/home-manager ]]; then
            rm -rf ~/.config/home-manager
            print_status "Cleaned up temporary home-manager config"
        fi
    fi
}

# Function to handle errors
error_handler() {
    local line_number=$1
    print_error "Script failed on line $line_number"
    if [[ "$DRY_RUN" == false ]]; then
        rollback
    fi
    print_status "Please check the error message above and try again"
    exit 1
}

# Set up error handling
trap 'error_handler $LINENO' ERR

# Main function
main() {
    local hostname=${1:-$(hostname -s)}

    echo "🚀 Starting nix-darwin setup process..."
    echo "Hostname: $hostname"
    echo "Dry run mode: $DRY_RUN"
    echo "=================================="

    # Pre-flight checks
    check_macos
    check_nix
    check_directory

    # Validate configuration before proceeding
    validate_configuration "$hostname"

    # Setup process
    backup_configs
    cleanup_failed_builds
    build_darwin_config "$hostname"

    # Verification
    verify_installation

    # Post-installation information
    post_install_info

    print_success "Setup completed successfully! 🎉"
}

# Help function
show_help() {
    echo "Usage: $0 [OPTIONS] [hostname]"
    echo
    echo "Setup nix-darwin configuration from scratch"
    echo
    echo "Arguments:"
    echo "  hostname    Target hostname (default: current hostname)"
    echo
    echo "Options:"
    echo "  -n, --dry-run    Show what would be done without making changes"
    echo "  -v, --verbose    Enable verbose output"
    echo "  -h, --help       Show this help message"
    echo
    echo "Examples:"
    echo "  $0                    # Use current hostname"
    echo "  $0 macbook-pro        # Use specific hostname"
    echo "  $0 mac-mini           # Use specific hostname"
    echo "  $0 -n               # Dry run with current hostname"
    echo "  $0 -v macbook-pro   # Verbose mode with specific hostname"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            break
            ;;
    esac
done

if [[ "$DRY_RUN" == true ]]; then
    print_warning "DRY RUN MODE: Script will not make any changes"
fi

main "$@"