# ============================================================================
# .zshrc - Interactive shell configuration
# Loaded for every interactive zsh session
# ============================================================================

# ============================================================================
# Oh My Zsh setup
# ============================================================================
export ZSH="/nix/store/jrlg1f9j1rx82wp3gs5cly218fn83y6h-oh-my-zsh-2025-11-23/share/oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git docker kubectl)
source $ZSH/oh-my-zsh.sh

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
# .zshrc - Interactive shell configuration
# Loaded for every interactive zsh session
# ============================================================================

# ============================================================================
# Oh My Zsh setup (manual configuration since dotDir is not set)
# ============================================================================
export ZSH="/nix/store/jrlg1f9j1rx82wp3gs5cly218fn83y6h-oh-my-zsh-2025-11-23/share/oh-my-zsh"
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
# Starship prompt (must be AFTER oh-my-zsh to override its theme)
# ============================================================================
eval "$(starship init zsh)"

# ============================================================================
# Custom functions and aliases
# ============================================================================
function lg() { lazygit "$@"; }