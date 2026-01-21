# ============================================================================
# .zshrc - Interactive shell configuration
# Loaded for every interactive zsh session
# ============================================================================

# ============================================================================
# Oh My Zsh setup
# ============================================================================
export ZSH="/nix/store/jrlg1f9j1rx82wp3gs5cly218fn83y6h-oh-my-zsh-2025-11-23/share/oh-my-zsh"
export ZSH_THEME="robbyrussell"
export plugins=(git docker kubectl)

# Source oh-my-zsh
if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
    source "$ZSH/oh-my-zsh.sh"
fi

# ============================================================================
# Zsh Syntax Highlighting
# ============================================================================
# Load zsh-syntax-highlighting from Nix store
echo "Loading zsh-syntax-highlighting..." >&2
if [[ -f "/nix/store/2q2pffrdhd49kgzr40vh217dpbccpxmi-zsh-syntax-highlighting-0.8.0/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source "/nix/store/2q2pffrdhd49kgzr40vh217dpbccpxmi-zsh-syntax-highlighting-0.8.0/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" && echo "zsh-syntax-highlighting loaded successfully" >&2 || echo "zsh-syntax-highlighting failed to load" >&2
else
    echo "zsh-syntax-highlighting.zsh not found" >&2
fi

# ============================================================================
# Zsh Autosuggestions
# ============================================================================
# Load zsh-autosuggestions from user profile
echo "Loading zsh-autosuggestions..." >&2
if [[ -f "/etc/profiles/per-user/thanhhaikhong/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "/etc/profiles/per-user/thanhhaikhong/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" && echo "zsh-autosuggestions loaded successfully" >&2 || echo "zsh-autosuggestions failed to load" >&2
else
    echo "zsh-autosuggestions.zsh not found" >&2
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
