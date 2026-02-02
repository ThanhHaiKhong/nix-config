# nix-config Repository - Development Context

## Project Overview

This is a personal Nix configuration repository for managing macOS system configurations using:
- **nix-darwin** for macOS system-level configuration
- **home-manager** for user environment management
- **Nix flakes** for declarative dependency management
- **Just** as a task runner for common operations

The configuration supports multiple hosts, specifically:
- `macbook-pro` - Personal machine
- `mac-mini` - Work machine

## Directory Structure

```
├── .envrc                   # Direnv configuration to automatically load Nix environment
├── .sops.yaml              # SOPS (Secrets OPerationS) configuration for encrypted secrets
├── AGENTS.md               # Development guidelines for agentic coding assistants
├── flake.lock              # Locked flake dependencies
├── flake.nix               # Main flake definition with inputs and outputs
├── home.nix                # Home Manager configuration for user environment
├── justfile                # Just task runner commands
├── README.md               # Basic project description
├── setup.sh                # Bootstrap script for initial setup
├── shell.nix               # Development shell environment
├── configs/                # Configuration files for various tools
├── hosts/                  # Host-specific configurations
├── lib/                    # Shared Nix utility functions
├── modules/                # Reusable Nix modules
├── secrets/                # Encrypted secrets managed by SOPS
└── testing/                # Test configurations
```

## Key Features

### System Configuration
- macOS-specific configurations via nix-darwin
- Homebrew integration via nix-homebrew module
- TouchID authentication for sudo
- Customized Finder, Dock, Safari, and other macOS defaults

### User Environment
- Zsh shell with Oh My Zsh, syntax highlighting, and auto-suggestions
- Git configuration with custom settings and LFS support
- Neovim with plugin management
- Terminal tools like wezterm, starship, fzf, bat, eza, lf, htop
- Development tools and languages (Go, Node.js, etc.)

### Security & Secrets
- SOPS for managing encrypted secrets with age encryption
- Secure storage of sensitive configuration data
- Integration with nix-darwin for seamless secret deployment

## Building and Running

### Prerequisites
- Nix package manager (preferably Determinate Systems Nix installer)
- macOS system for nix-darwin configurations

### Primary Commands

```bash
# Build and switch to system config (default)
just

# Build nix-darwin config without switching to it
just build [target_host]

# Build with trace for debugging
just trace [target_host]

# Build and switch to specific host configuration
just switch macbook-pro

# Update flake inputs to latest versions
just update

# Run garbage collection to clean old packages
just gc
```

### Direct Nix Commands

```bash
# Check flake validity
nix flake check

# Show available flake outputs
nix flake show

# Build specific configuration
nix build ".#darwinConfigurations.macbook-pro.system"

# Update specific input
nix flake lock --update-input nixpkgs

# Enter development shell
nix develop
```

### Initial Setup

To bootstrap a new system:
```bash
./setup.sh [hostname]
```

This script performs pre-flight checks, validates the configuration, backs up existing settings, and activates the nix-darwin configuration.

## Development Conventions

### Nix Code Style
- Use 2-space indentation
- Group related attributes together with comments
- Use descriptive variable names
- Follow camelCase for variables and snake_case for file names
- Leverage `let ... in` expressions for complex configurations
- Use overlays for package modifications when needed

### Configuration Organization
- Host-specific configurations in `hosts/darwin/[hostname]/`
- Common configurations in `hosts/common/`
- User environment in `home.nix`
- Shared utilities in `lib/`
- Tool-specific configs in `configs/`

### Secrets Management
- Store secrets in `secrets/secrets.yaml` encrypted with SOPS
- Configure encryption keys in `.sops.yaml`
- Never commit unencrypted secrets to the repository

## Key Dependencies

The flake includes these main inputs:
- nixpkgs (stable and unstable channels)
- nix-darwin for macOS system configuration
- home-manager for user environment
- sops-nix for secrets management
- nix-homebrew for Homebrew integration

## Troubleshooting

Common issues and solutions:
- If flake lock is outdated: run `just update`
- For build failures: use `just trace` for detailed error information
- For permission issues: ensure proper sudo access for system switches
- For cache issues: use `just gc` to clean old packages

## Development Workflow

1. Make changes to configuration files
2. Validate with `nix flake check`
3. Build with `just build` to test configuration
4. Apply with `just` to switch to new configuration
5. Test functionality on the target system