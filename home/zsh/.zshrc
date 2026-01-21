# ============================================================================
# .zshrc - Interactive shell configuration
# Loaded for every interactive zsh session
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
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# ============================================================================
# Starship prompt (must be AFTER oh-my-zsh to override its theme)
# ============================================================================
eval "$(starship init zsh)"

# ============================================================================
# Custom functions and aliases
# ============================================================================
function lg() { lazygit "$@"; }