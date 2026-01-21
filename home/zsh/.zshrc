# ============================================================================
# .zshrc - Interactive shell configuration
# Loaded for every interactive zsh session
# ============================================================================

# ============================================================================
# Oh My Zsh setup (managed here since Home Manager dotDir conflicts with ~ locations)
# ============================================================================
export ZSH="/nix/store/jrlg1f9j1rx82wp3gs5cly218fn83y6h-oh-my-zsh-2025-11-23/share/oh-my-zsh"
export ZSH_THEME="robbyrussell"
export plugins=(git docker kubectl)

# Source oh-my-zsh
if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
    echo "Sourcing oh-my-zsh.sh from: $ZSH" >&2
    source "$ZSH/oh-my-zsh.sh"
    echo "Oh-my-zsh sourced successfully, ZSH=$ZSH" >&2
else
    echo "oh-my-zsh.sh not found at: $ZSH/oh-my-zsh.sh" >&2
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
