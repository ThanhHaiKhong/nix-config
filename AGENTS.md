# AGENTS.md - Development Guidelines for nix-config

This document provides development guidelines, build commands, and coding standards for agentic coding assistants working on this Nix configuration repository.

## Project Overview

This is a personal Nix configuration repository using:
- **nix-darwin** for macOS system configuration
- **home-manager** for user environment management
- **Nix flakes** for dependency management
- **Just** as a task runner

## Build/Lint/Test Commands

### Primary Build Commands (via Just)

```bash
# Build and switch to system config (default)
just

# Build nix-darwin config without switching
just build [target_host]

# Build with trace for debugging
just trace [target_host]

# Build NixOS config (Linux)
just build [target_host]  # on Linux systems

# Update all flake inputs
just update

# Garbage collect
just gc
```

### Flake Operations

```bash
# Check flake validity
nix flake check

# Show flake outputs
nix flake show

# Update specific input
nix flake lock --update-input nixpkgs

# Build specific configuration
nix build ".#darwinConfigurations.macbook-pro.system"
```

### Development Shell

```bash
# Enter development environment
nix-shell

# Or with direnv (if configured)
direnv allow
```

### Testing & Validation

```bash
# Run flake checker (CI equivalent)
nix flake check

# Validate specific host configuration
nix build ".#darwinConfigurations.macbook-pro.system" --dry-run

# Test home-manager config
home-manager build --flake ".#thanhhaikhong@macbook-pro"
```

### Single Test Execution

```bash
# Test flake validity (equivalent to "single test")
nix flake check

# Test specific host build
nix build ".#darwinConfigurations.macbook-pro.system" --no-link
```

## Code Style Guidelines

### Nix Code Style

#### File Structure
- Use `let ... in` expressions for complex configurations
- Group related attributes together
- Use descriptive variable names
- Keep files focused on single responsibilities

#### Formatting
- 2-space indentation
- Align attribute names in sets when it improves readability
- Use consistent spacing around operators
- Break long lines appropriately

#### Example Patterns
```nix
{ inputs, pkgs, ... }:
let
  inherit (inputs) nixpkgs;
  username = "thanhhaikhong";
in {
  # Group related configurations
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Group by category with comments
    # Development tools
    git
    just

    # System utilities
    coreutils
    jq
  ];

  # Use overlays for package modifications
  nixpkgs.overlays = [
    (final: prev: {
      customPackage = prev.package.overrideAttrs (old: {
        # modifications here
      });
    })
  ];
}
```

#### Naming Conventions
- Use `camelCase` for variable names
- Use `snake_case` for file names (e.g., `common-packages.nix`)
- Prefix host-specific files with hostname
- Use descriptive, hierarchical directory structure

#### Imports and Dependencies
- Use relative imports within the repository
- Leverage `inputs` for external dependencies
- Follow flake input patterns consistently
- Document non-obvious imports

### Lua Code Style (Neovim Configuration)

#### Plugin Configuration
```lua
-- plugins.lua
require("lazy").setup({
  {
    "plugin/name",
    config = function()
      -- Configuration here
    end
  }
})
```

#### Keymaps and Options
- Group related configurations
- Use descriptive variable names
- Follow Lua naming conventions
- Document complex keybindings

### Shell Scripts and Configuration

#### Zsh/Tmux Configuration
- Keep configurations modular
- Use descriptive comments
- Follow POSIX shell standards where possible
- Test configurations across different environments

## Security & Best Practices

### Secrets Management
- Use **sops-nix** for secrets (`.sops.yaml` configured)
- Never commit secrets directly
- Use `git-crypt` for additional encryption if needed
- Validate secret handling in CI

### Package Management
- Prefer stable packages over unstable when possible
- Document rationale for unstable packages
- Use overlays for package customizations
- Keep package lists organized by category

### System Configuration
- Test configurations on non-production systems first
- Use feature flags for experimental features
- Document breaking changes
- Maintain backup configurations

## Development Workflow

### Pre-commit Checks
```bash
# Run before committing
nix flake check
git diff --check  # Check for whitespace issues
```

### Pull Request Process
- Ensure flake builds successfully
- Test on target systems when possible
- Update documentation for significant changes
- Follow conventional commit messages

### Common Tasks

#### Adding a New Package
1. Add to appropriate package list (e.g., `common-packages.nix`)
2. Test build: `just build`
3. Test functionality on target system

#### Modifying System Configuration
1. Edit relevant Nix files
2. Build: `just build`
3. Switch: `just` (on target system)

#### Testing Configuration Changes
1. Build without switching: `just build`
2. Review generated config: `nix build --no-link`
3. Switch when confident: `just`

## File Organization

```
├── flake.nix                 # Main flake definition
├── justfile                  # Task runner commands
├── lib/                      # Shared Nix utilities
├── hosts/                    # Host-specific configurations
│   ├── common/              # Shared configurations
│   └── darwin/              # macOS-specific hosts
├── home/                     # User environment configs
├── modules/                  # Reusable NixOS modules
└── testing/                  # Test configurations
```

## Error Handling

### Common Issues
- **Flake lock outdated**: Run `just update`
- **Build failures**: Use `just trace` for detailed errors
- **Permission issues**: Ensure proper sudo access for system switches
- **Cache issues**: Clear Nix cache or use `--no-cache`

### Debugging
- Use `--show-trace` for detailed error information
- Check `/var/log/system.log` on macOS for system-level issues
- Validate flake inputs: `nix flake metadata`

## Performance Considerations

- Use `colmena` for multi-host deployments
- Leverage Nix caching effectively
- Minimize rebuild scope when possible
- Profile builds with `nix build --rebuild`

## Integration Points

### External Tools
- **home-manager**: User environment management
- **nix-homebrew**: macOS Homebrew integration
- **sops-nix**: Secrets management
- **colmena**: Multi-host deployment

### CI/CD
- GitHub Actions flake checker runs on push
- Automated testing via `nix flake check`
- Scheduled updates via cron

This document should be updated when significant changes are made to the development workflow or coding standards.</content>
<parameter name="filePath">/Users/thanhhaikhong/tmp/nix-config/AGENTS.md