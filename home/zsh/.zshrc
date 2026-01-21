# ============================================================================
# .zshrc - Interactive shell configuration
# Loaded for every interactive zsh session
# ============================================================================

# ============================================================================
# Oh My Zsh setup (managed here since Home Manager dotDir conflicts with ~ locations)
# ============================================================================
export ZSH="${pkgs.oh-my-zsh}/share/oh-my-zsh"
export ZSH_THEME="robbyrussell"
export plugins=(git docker kubectl)

# Source oh-my-zsh
if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
    source "$ZSH/oh-my-zsh.sh"
fi

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
# Starship prompt (loaded after oh-my-zsh)
# ============================================================================
eval "$(starship init zsh)"