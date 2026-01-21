# ============================================================================
# .zshrc - Interactive shell configuration
# Loaded for every interactive zsh session
#
# Note: Oh My Zsh is configured via Home Manager in thanhhaikhong.nix
# This file contains only interactive shell specific customizations
# ============================================================================

# ============================================================================
# VSCode Shell Integration
# Ref: https://code.visualstudio.com/docs/terminal/shell-integration
# ============================================================================
if [[ "$TERM_PROGRAM" == "vscode" ]]; then
    # VSCode terminal integration is handled automatically
    # No manual sourcing needed
fi

# ============================================================================
# Pyenv initialization (for interactive shells)
# ============================================================================
if command -v pyenv &> /dev/null; then
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
fi

# ============================================================================
# Starship prompt (configured after oh-my-zsh in Home Manager)
# ============================================================================
eval "$(starship init zsh)"