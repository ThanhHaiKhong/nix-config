{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.cliproxyapi;
  
  cliproxyapiConfig = pkgs.writeText "cliproxyapi-config.yaml" ''
    # CLIProxyAPI Configuration
    # This configuration file manages the proxy API settings

    # Server Configuration
    host: "127.0.0.1" # Bind to localhost only for security
    port: 8317 # Default port
    # TLS Configuration
    tls:
      enable: false # Enable TLS for HTTPS (set to true if you have certificates)
      cert: "" # Path to TLS certificate file
      key: "" # Path to TLS private key file
    # Management API Settings
    remote-management:
      # Switch to enable remote management. If you deploy it on a server,
      # you need to set it to true to use EasyCLI or WebUI to connect to CLIProxyAPI
      # for management.
      # If you only use the API for local management, you can keep it as false.
      allow-remote: false
      # If you want to use EasyCLI or WebUI to manage CLIProxyAPI through the API,
      # you must set a Key.
      # If it is not set, it is considered that the API management function is
      # disabled, and you cannot use EasyCLI or WebUI to connect.
      # If you do not need to use EasyCLI or WebUI for management, you can leave it
      # blank.
      secret-key: ""
      # Switch to integrate WebUI.
      # Set to false, you can open WebUI through
      # http://YOUR_SERVER_IP:8317/management.html
      disable-control-panel: false
      panel-github-repository: "https://github.com/router-for-me/Cli-Proxy-API-Management-Center"
    # Authentication Settings
    # Directory for storing authentication files, used to store authentication files
    # for Gemini CLI, Gemini Web, Qwen Code, and Codex.
    # The default setting is the .cli-proxy-api folder in your current account
    # directory, which is compatible with Windows and Linux environments.
    # The program will automatically create this folder when it starts for the first
    # time.
    # The default in Windows is C:\Users\your_username\.cli-proxy-api
    # The default in Linux is /home/your_username\.cli-proxy-api
    # If you use a non-default location in a Windows environment, you need to
    # modify it in this format "Z:\\CLIProxyAPI\\auths"
    auth-dir: "~/.local/share/cli-proxy-api"
    # The keys required for various AI clients to access CLIProxyAPI are set here.
    # Do not confuse them with the various keys below.
    # In layman's terms, the Key here is what CLIProxyAPI needs to set as a
    # server.
    # The various keys below are what CLIProxyAPI needs as a client to access the
    # server.
    # NOTE: API keys are managed separately via SOPS secrets and injected at runtime
    api-keys: []
    # Logging and Debugging
    # Whether to enable Debug information in the log, it is disabled by default.
    # You only need to turn it on when the author needs to cooperate in
    # troubleshooting.
    debug: false
    # Hidden configuration, which can record every request and response and save it
    # to the logs directory.
    # The size of each log may be as high as 10MB+. Please do not enable it if your
    # hard disk is not large enough.
    request-log: false
    # Whether to redirect the log to a log file.
    # It is enabled by default, and the log will be saved in the logs folder in the
    # program directory.
    # If it is turned off, the log will be displayed in the console.
    logging-to-file: false
    # Maximum total size of log files in MB (0 disables rotation)
    logs-max-total-size-mb: 0
    # Switch for usage statistics, enabled by default.
    # You need to use the API to view the usage, you can use EasyCLI or WebUI to
    # view it.
    usage-statistics-enabled: true
    # Performance and Operation
    commercial-mode: false # Disable high-overhead HTTP middleware features to reduce memory usage under high concurrency
    # If you want to use a proxy, you need to make the following settings, which
    # support socks5/http/https protocols.
    # Fill in according to this format "socks5://user:[email protected]:1080/"
    proxy-url: ""
    force-model-prefix: false # When true, unprefixed model requests only use credentials without a prefix
    # The number of times the program automatically retries the request when it
    # encounters error codes such as 403, 408, 500, 502, 503, 504.
    request-retry: 3
    max-retry-interval: 30 # Maximum wait time in seconds for a cooled-down credential before triggering a retry
    # Quota and Routing
    # Processing behavior after the model is restricted.
    quota-exceeded:
      # The core configuration of multi-account polling.
      # When set to true, for example, if an account triggers a 429, the program
      # will automatically switch to the next account to re-initiate the request.
      # When set to false, the program will send the 429 error message to the
      # client and end the current request.
      # That is to say, when it is set to true, as long as at least one of the
      # polling accounts is normal, the client will not report an error.
      # When it is set to false, the client needs to retry or abort the operation.
      switch-project: true
      # Gemini CLI exclusive configuration, applicable to Gemini 2.5 Pro and
      # Gemini 2.5 Flash models.
      # When the official version quota is used up, it will automatically switch to
      # the Preview model. Just keep it on.
      switch-preview-model: true
    routing:
      strategy: "round-robin" # Strategy for selecting credentials when multiple match (options: "round-robin", "fill-first")
    # WebSocket and Streaming
    # AIStudio authentication switch. When set to true, the above api-keys will be
    # used to authenticate AIStudio Build APP access.
    ws-auth: false
    nonstream-keepalive-interval: 0 # Emit blank lines every N seconds for non-streaming responses to prevent idle timeouts (0 disables)
    codex-instructions-enabled: false # Enable official Codex instructions injection for Codex API requests
    # Streaming Behavior
    streaming:
      keepalive-seconds: 15 # SSE keep-alive interval in seconds (0 or negative disables)
      bootstrap-retries: 1 # Retries before first byte is sent (0 disables)
    # Model Configuration
    # Define model aliases and exclusions
    models: []
    #  - name: "gpt-4-vision-preview"
    #    alias: "gpt-4-vision"
    #  - name: "claude-3-opus-20240229"
    #    alias: "claude-3-opus"

    # Excluded models (using wildcards)
    excluded-models: []
    # Payload manipulation settings
    payload-manipulation:
      # Default values to add to requests
      defaults: {}
      # Values to override in requests
      overrides: {}
      # Filters to apply to requests
      filters: {}
    # Provider-specific configurations
    providers:
    oauth-model-alias:
      antigravity:
        - name: rev19-uic3-1p
          alias: gemini-2.5-computer-use-preview-10-2025
        - name: gemini-3-pro-image
          alias: gemini-3-pro-image-preview
        - name: gemini-3-pro-high
          alias: gemini-3-pro-preview
        - name: gemini-3-flash
          alias: gemini-3-flash-preview
        - name: claude-sonnet-4-5
          alias: gemini-claude-sonnet-4-5
        - name: claude-sonnet-4-5-thinking
          alias: gemini-claude-sonnet-4-5-thinking
        - name: claude-opus-4-5-thinking
          alias: gemini-claude-opus-4-5-thinking
  '';
  
in
{
  options.programs.cliproxyapi = {
    enable = mkEnableOption "CLIProxyAPI";

    # Deprecated: API keys should be managed through sops-nix
    apiKeys = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of API keys for CLIProxyAPI (deprecated: use sops-nix)";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.cliproxyapi;
      defaultText = "pkgs.cliproxyapi";
      description = "The CLIProxyAPI package to use";
    };

    enableManager = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable the CLIProxyAPI manager script";
    };

    enableMonitoring = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable automated monitoring";
    };
  };

  config = mkIf cfg.enable {
    # Install the CLIProxyAPI package
    home.packages = [ cfg.package ];
    
    # Create the configuration file with reference to the secret
    # The actual API keys will be injected at runtime using a script
    home.file.".config/cliproxyapi/config.yaml".text = builtins.readFile ./../configs/cliproxyapi/config.yaml;

    # Create a script to update the config with decrypted API keys at runtime
    home.file.".config/cliproxyapi/update-config-with-keys.sh".source = ./../configs/cliproxyapi/update-config-with-keys.sh;
    home.file.".config/cliproxyapi/update-config-with-keys.sh".executable = true;
    
    # Install the management script if enabled
    home.file.".local/bin/cliproxyapi-manager".source = ./../configs/local/bin/cliproxyapi-manager.sh;
    home.file.".local/bin/cliproxyapi-manager".executable = true;

    # Install the launchd plist
    home.file.".config/cliproxyapi/launchd.plist".text = builtins.readFile ./../configs/local/Library/LaunchAgents/local.cliproxyapi.plist;

    # Install the enhanced monitoring script
    home.file.".config/cliproxyapi/enhanced-monitoring.sh".source = ./../configs/cliproxyapi/enhanced-monitoring.sh;
    home.file.".config/cliproxyapi/enhanced-monitoring.sh".executable = true;

    # Install the enhanced opencode wrapper
    home.file.".config/cliproxyapi/enhanced-opencode-wrapper.sh".source = ./../configs/cliproxyapi/enhanced-opencode-wrapper.sh;
    home.file.".config/cliproxyapi/enhanced-opencode-wrapper.sh".executable = true;

    # Install the monitoring launchd plist if monitoring is enabled
    home.file.".config/cliproxyapi/monitoring.plist".text = builtins.readFile ./../configs/local/Library/LaunchAgents/local.cliproxyapi.monitoring.plist;

    # Install the readiness script
    home.file.".local/bin/cliproxyapi-ensure-ready".source = ./../configs/cliproxyapi/ensure-ready.sh;
    home.file.".local/bin/cliproxyapi-ensure-ready".executable = true;

    # Add a shell function to ensure CLIProxyAPI is running before opencode
    programs.zsh.shellAliases = mkIf (config.programs.opencode.enable or false) {
      opencode = ''
        cliproxyapi-ensure-ready && command opencode "$@"
      '';
    };

    # Activation script to install the launchd plist
    home.activation.installCliproxyapiPlist = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # Copy the plist file to the LaunchAgents directory if it doesn't exist or needs updating
      mkdir -p "$HOME/Library/LaunchAgents"

      # Check if the file already exists and differs
      if [ ! -f "$HOME/Library/LaunchAgents/local.cliproxyapi.plist" ] || ! cmp -s "$HOME/.config/cliproxyapi/launchd.plist" "$HOME/Library/LaunchAgents/local.cliproxyapi.plist"; then
        # Remove the existing file if it exists (to handle read-only files)
        rm -f "$HOME/Library/LaunchAgents/local.cliproxyapi.plist"

        # Copy the file with proper permissions
        cp "$HOME/.config/cliproxyapi/launchd.plist" "$HOME/Library/LaunchAgents/local.cliproxyapi.plist"
        echo "Copied CLIProxyAPI launchd plist file"
      else
        echo "CLIProxyAPI launchd plist file is up to date"
      fi

      # Reload the service to ensure it picks up the latest configuration
      if /bin/launchctl list | grep -q "local.cliproxyapi"; then
        /bin/launchctl bootout "gui/$(id -u)/local.cliproxyapi" 2>/dev/null || true
        echo "Unloaded previous CLIProxyAPI launchd service"
      fi

      # Load the service
      /bin/launchctl bootstrap "gui/$(id -u)" "$HOME/Library/LaunchAgents/local.cliproxyapi.plist"
      echo "Loaded CLIProxyAPI launchd service"
    '';

    # Activation script to update the config with decrypted API keys after secrets are available
    home.activation.updateCliproxyapiConfig = lib.hm.dag.entryAfter [ "installCliproxyapiPlist" ] ''
      # Check if the SOPS decrypted secret file exists in the expected location
      if [ -f "$HOME/.local/share/cliproxyapi-api-keys/secret" ]; then
        echo "Updating CLIProxyAPI config with API keys from secrets..."
        $HOME/.config/cliproxyapi/update-config-with-keys.sh
      else
        echo "Warning: Decrypted secrets file not found at $HOME/.local/share/cliproxyapi-api-keys/secret"
        echo "Make sure sops-nix is properly configured and secrets are decrypted"
      fi
    '';

    # Activation script to install the monitoring launchd plist if enabled
    home.activation.installCliproxyapiMonitoring = mkIf cfg.enableMonitoring (lib.hm.dag.entryAfter [ "installCliproxyapiPlist" ] ''
      # Copy the monitoring plist file to the LaunchAgents directory
      mkdir -p "$HOME/Library/LaunchAgents"

      # Check if the file already exists and differs
      if [ ! -f "$HOME/Library/LaunchAgents/local.cliproxyapi.monitoring.plist" ] || ! cmp -s "$HOME/.config/cliproxyapi/monitoring.plist" "$HOME/Library/LaunchAgents/local.cliproxyapi.monitoring.plist"; then
        # Remove the existing file if it exists (to handle read-only files)
        rm -f "$HOME/Library/LaunchAgents/local.cliproxyapi.monitoring.plist"

        # Copy the file with proper permissions
        cp "$HOME/.config/cliproxyapi/monitoring.plist" "$HOME/Library/LaunchAgents/local.cliproxyapi.monitoring.plist"
        echo "Copied CLIProxyAPI monitoring launchd plist file"
      else
        echo "CLIProxyAPI monitoring launchd plist file is up to date"
      fi

      # Reload the service to ensure it picks up the latest configuration
      if /bin/launchctl list | grep -q "local.cliproxyapi.monitoring"; then
        /bin/launchctl bootout "gui/$(id -u)/local.cliproxyapi.monitoring" 2>/dev/null || true
        echo "Unloaded previous CLIProxyAPI monitoring service"
      fi

      # Load the service
      /bin/launchctl bootstrap "gui/$(id -u)" "$HOME/Library/LaunchAgents/local.cliproxyapi.monitoring.plist"
      echo "Loaded CLIProxyAPI monitoring service"
    '');
  };
}