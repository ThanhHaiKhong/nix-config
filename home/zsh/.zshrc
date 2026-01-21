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

# ============================================================================
# Additional zsh configuration (from Home Manager initExtra)
# ============================================================================
# Enable vi mode
bindkey -v

# Better history search
bindkey '^R' history-incremental-search-backward

# Custom functions
function lg() { lazygit "$@"; }

# Shell aliases
alias cat="/nix/store/2q2pffrdhd49kgzr40vh217dpbccpxmi-bat-0.24.0/bin/bat"
alias ls="eza"
alias ll="eza -l"
alias la="eza -la"
alias tree="eza --tree"
alias cd="z"
alias vi="nvim"
alias vim="nvim"
alias diff="diff-so-fancy"