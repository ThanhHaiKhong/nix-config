# ============================================================================
# .zshrc - Interactive shell configuration
# Loaded for every interactive zsh session
# ============================================================================

# ============================================================================
# Source Home Manager generated zsh config (includes oh-my-zsh, syntax highlighting, autosuggestions)
# ============================================================================
if [[ -f "$HOME/.config/zsh/.zshrc" ]]; then
    source "$HOME/.config/zsh/.zshrc"
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
# Custom functions and aliases
# ============================================================================
lg() { lazygit "$@"; }

# Shell aliases
alias cat="/etc/profiles/per-user/thanhhaikhong/bin/bat"
alias ls="eza"
alias ll="eza -l"
alias la="eza -la"
alias tree="eza --tree"
alias cd="z"
alias vi="nvim"
alias vim="nvim"
alias diff="diff-so-fancy"

# Shell aliases
alias cat="/etc/profiles/per-user/thanhhaikhong/bin/bat"
alias ls="eza"
alias ll="eza -l"
alias la="eza -la"
alias tree="eza --tree"
alias cd="z"
alias vi="nvim"
alias vim="nvim"
alias diff="diff-so-fancy"
