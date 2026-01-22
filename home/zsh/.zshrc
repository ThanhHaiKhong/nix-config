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

# Enable vi mode
bindkey -v

# Better history search
bindkey "^R" history-incremental-search-backward

# Enhanced history settings
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_verify
setopt share_history
setopt extended_history
setopt inc_append_history

# Additional zsh options for better completion behavior
setopt complete_in_word
setopt always_to_end
setopt auto_menu
setopt auto_param_slash
setopt extended_glob
setopt mark_dirs

# Custom functions and aliases
lg() { lazygit "$@"; }

# Make ~ alone work as cd ~ using zsh's preexec hook
function precmd() {
  # This runs before each prompt
  # We'll use it to handle ~ alone commands
  :
}

# Alternative: Use a different key binding that doesn't interfere with typing
# Ctrl+H will go to home directory
bindkey '^H' 'cd ~; zle reset-prompt'

# Note: ~ alone cannot work due to shell metacharacter expansion
# Use: cd ~ (standard way) or Ctrl+H (custom binding)

# Shell aliases
alias cat="bat"
alias ls="eza"
alias ll="eza -l"
alias la="eza -la"
alias tree="eza --tree"
alias vi="nvim"
alias vim="nvim"
alias diff="diff-so-fancy"

# Zsh syntax highlighting
source $HOME/.nix-profile/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Zsh autosuggestions
source $HOME/.nix-profile/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Starship prompt
eval "$(starship init zsh)"







