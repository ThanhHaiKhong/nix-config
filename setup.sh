#!/usr/bin/env zsh

set -euo pipefail

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
    
    # Backup /etc/zshenv if it exists and isn't already backed up
    if [[ -f "/etc/zshenv" && ! -f "/etc/zshenv.backup" ]]; then
        sudo cp /etc/zshenv /etc/zshenv.backup
        print_success "Backed up /etc/zshenv"
    fi
    
    # Remove existing /etc/zshenv to allow nix-darwin to manage it
    if [[ -f "/etc/zshenv" ]]; then
        sudo rm /etc/zshenv
        print_status "Removed existing /etc/zshenv for nix-darwin management"
    fi
    
    print_success "Configuration backup completed"
}

# Function to clean up previous failed builds
cleanup_failed_builds() {
    print_status "Cleaning up any previous failed builds..."
    
    # Clean nix store
    nix store gc --verbose
    
    # Clean home-manager if it exists
    if [[ -d ~/.config/home-manager ]]; then
        rm -rf ~/.config/home-manager
        print_status "Cleaned previous home-manager configuration"
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
    if sudo nix run nix-darwin -- switch --flake ".#$hostname"; then
        print_success "nix-darwin configuration activated successfully"
    else
        print_error "Failed to activate nix-darwin configuration"
        exit 1
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

# Function to handle errors
error_handler() {
    local line_number=$1
    print_error "Script failed on line $line_number"
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
    echo "=================================="
    
    # Pre-flight checks
    check_macos
    check_nix
    check_directory
    
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
    echo "Usage: $0 [hostname]"
    echo
    echo "Setup nix-darwin configuration from scratch"
    echo
    echo "Arguments:"
    echo "  hostname    Target hostname (default: current hostname)"
    echo
    echo "Options:"
    echo "  -h, --help  Show this help message"
    echo
    echo "Examples:"
    echo "  $0                    # Use current hostname"
    echo "  $0 macbook-pro        # Use specific hostname"
    echo "  $0 mac-mini           # Use specific hostname"
}

# Parse command line arguments
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac