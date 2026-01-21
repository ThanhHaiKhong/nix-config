# ============================================================================
# .zshenv - Environment variables for ALL shells
# Loaded for every zsh shell (login, interactive, scripts)
# ============================================================================

# User local binaries (custom scripts and tools)
export PATH="$HOME/.local/bin:$PATH"

# Opencode
export PATH="$HOME/.opencode/bin:$PATH"

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
# Pyenv setup (environment variables only - init commands go in .zshrc)
# ============================================================================
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"