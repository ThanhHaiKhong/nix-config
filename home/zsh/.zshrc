# ============================================================================
# .zshrc - Interactive shell configuration
# Loaded for every interactive zsh session
# ============================================================================

# ============================================================================
# Oh My Zsh setup
# ============================================================================
# Note: Oh My Zsh is configured via Home Manager, but we provide fallback here
# Home Manager should handle this, but this ensures it works

# ============================================================================
# Zsh Syntax Highlighting
# ============================================================================
# Load zsh-syntax-highlighting if available in standard locations
if [[ -f "$HOME/.nix-profile/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source "$HOME/.nix-profile/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# ============================================================================
# Zsh Autosuggestions
# ============================================================================
# Load zsh-autosuggestions if available in standard locations
if [[ -f "$HOME/.nix-profile/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "$HOME/.nix-profile/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# ============================================================================
# VSCode Shell Integration
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
# Custom functions and aliases
# ============================================================================
lg() { lazygit "$@"; }

# Make ~ alone go to home directory
~() { cd ~; }

# Shell aliases
alias cat="bat"
alias ls="eza"
alias ll="eza -l"
alias la="eza -la"
alias tree="eza --tree"
alias cd="z"
alias vi="nvim"
alias vim="nvim"
alias diff="diff-so-fancy"
