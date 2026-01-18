# ============================================================================
# VSCode Shell Integration - Using Automatic Injection
# Ref: https://code.visualstudio.com/docs/terminal/shell-integration
# terminal.integrated.shellIntegration.enabled = true (in settings)
# ============================================================================

# ============================================================================
# Essential PATH setup (for VSCode to find commands immediately)
# ============================================================================
# User local binaries (custom scripts and tools)
export PATH="$HOME/.local/bin:$PATH"

# Homebrew
export PATH="/opt/homebrew/bin:$PATH"
export HOMEBREW_AUTO_UPDATE_SECS=86400  # Auto-update every 24 hours

# Java
export JAVA_HOME="/opt/homebrew/opt/openjdk/libexec/openjdk.jdk/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"

# Swift
export PATH="/opt/homebrew/opt/swift/bin:$PATH"

# Essential environment variables
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

# ============================================================================
# VSCode Shell Integration: Load everything immediately for proper hook setup
# ============================================================================
if [[ "$TERM_PROGRAM" == "vscode" ]]; then
    # In VSCode: Load everything immediately to ensure proper shell integration
    source "$HOME/.zshrc_heavy"
else
    # Non-VSCode: Can use normal loading
    source "$HOME/.zshrc_heavy"
fi

# Starship prompt (must be AFTER oh-my-zsh to override its theme)
eval "$(starship init zsh)"

# ============================================================================
# Pyenv setup (MUST be last to take precedence over all other Python installs)
# ============================================================================
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# ============================================================================
# Final aliases (after all other configurations)
# ============================================================================
function lg() { lazygit "$@"; }

# Added by Antigravity
export PATH="/Users/thanhhaikhong/.antigravity/antigravity/bin:$PATH"
