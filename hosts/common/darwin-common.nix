{ inputs, outputs, config, lib, hostname, system, username, pkgs, unstablePkgs, ... }:
let
  inherit (inputs) nixpkgs nixpkgs-unstable;
in
{
  users.users.${username}.home = "/Users/${username}";

  nix = {
    enable = false;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;
      auto-optimise-store = true;
      builders-use-substitutes = true;
      accept-flake-config = true;
      sandbox = false;
    };
    channel.enable = false;
  };
  system.stateVersion = 5;

  # Set primary user for system-wide activation
  system.primaryUser = username;
  
  # Fix HOME ownership - add user to staff group  
  users.groups.staff.members = [ username ];
  
  # GitHub CLI auto-auth: add GITHUB_TOKEN to ~/.config/sops/age/keys.txt and secrets/secrets.yaml

  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = lib.mkDefault "${system}";
  };

   # Essential CLI tools installed via Nix
  environment.systemPackages = with pkgs; [
    # Development & DevOps Tools
    age
    comma
    just
    nodejs
    ollama
    pass
    sops
    nix
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.fira-mono
    nerd-fonts.hack
    nerd-fonts.jetbrains-mono
  ];

  # pins to stable as unstable updates very often
  nix.registry = {
    n.to = {
      type = "path";
      path = inputs.nixpkgs;
    };
    u.to = {
      type = "path";
      path = inputs.nixpkgs-unstable;
    };
  };

  programs.nix-index.enable = true;
    
  # Fix builtins.toFile context warning
  nix.extraOptions = [
    "--no-warn-dirty"
    "--quiet"
  ];

  # SOPS for secrets
  sops.defaultSopsFile = ../secrets/secrets.yaml;
  sops.age.keyFile = "/Users/${username}/.config/sops/age/keys.txt";

  # GUI Applications installed via Homebrew
  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "none";
      autoUpdate = true;
      upgrade = true;
    };
    global.autoUpdate = true;

    brews = [
      "bitwarden-cli"
      "neovim"
      "gh"
      "xcode-build-server"
      "qwen-code"
    ];
    taps = [
      #"FelixKratz/formulae" #sketchybar
    ];
    casks = [
      # Browsers & Communication
      "chatgpt-atlas" # Atlas browser
      "telegram-desktop"

      # Development & Terminal
      "visual-studio-code"

      # Utilities & Tools
      "aldente"

      # Fonts
      "font-fira-code-nerd-font"
      "font-hack-nerd-font"
      "font-jetbrains-mono-nerd-font"
      "font-meslo-lg-nerd-font"

      # Hardware & Peripherals
      "displaylink"
      "logi-options-plus"
    ];
    masApps = {
      "Xcode" = 497799835;
      "Tailscale" = 1475387142;
    };
};

  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;

  # macOS configuration
  system.defaults = {
    NSGlobalDomain.AppleShowAllExtensions = false;
    NSGlobalDomain.AppleShowScrollBars = "Always";
    NSGlobalDomain.NSUseAnimatedFocusRing = false;
    NSGlobalDomain.NSNavPanelExpandedStateForSaveMode = true;
    NSGlobalDomain.NSNavPanelExpandedStateForSaveMode2 = true;
    NSGlobalDomain.PMPrintingExpandedStateForPrint = true;
    NSGlobalDomain.PMPrintingExpandedStateForPrint2 = true;
    NSGlobalDomain.NSDocumentSaveNewDocumentsToCloud = false;
    NSGlobalDomain.ApplePressAndHoldEnabled = false;
    NSGlobalDomain.InitialKeyRepeat = 25;
    NSGlobalDomain.KeyRepeat = 2;
    NSGlobalDomain."com.apple.mouse.tapBehavior" = 1;
    NSGlobalDomain.NSWindowShouldDragOnGesture = true;
    NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
    LaunchServices.LSQuarantine = false; # disables "Are you sure?" for new apps
    loginwindow.GuestEnabled = false;
    finder.FXPreferredViewStyle = "Nlsv";
  };

system.defaults.CustomUserPreferences = {
  "com.apple.finder" = {
        ShowExternalHardDrivesOnDesktop = true;
        ShowHardDrivesOnDesktop = false;
        ShowMountedServersOnDesktop = false;
        ShowRemovableMediaOnDesktop = true;
        _FXSortFoldersFirst = true;
        # When performing a search, search the current folder by default
        FXDefaultSearchScope = "SCcf";
        DisableAllAnimations = true;
        NewWindowTarget = "PfDe";
        NewWindowTargetPath = "file://$\{HOME\}/Desktop/";
        AppleShowAllExtensions = false;
        FXEnableExtensionChangeWarning = false;
        ShowStatusBar = true;
        ShowPathbar = true;
        WarnOnEmptyTrash = false;
      };
      "com.apple.desktopservices" = {
        # Avoid creating .DS_Store files on network or USB volumes
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
      "com.apple.HIToolbox" = {
        # Completely disable Caps Lock functionality
        AppleFnUsageType = 1; # Enable Fn key functionality
        AppleKeyboardUIMode = 3;
        # Disable Caps Lock toggle entirely
        AppleSymbolicHotKeys = {
          "60" = {
            enabled = false; # Disable Caps Lock toggle hotkey
          };
        };
        # Override modifier key behavior to prevent Caps Lock from functioning
        AppleModifierKeyRemapping = {
          "1452-630-0" = {
            # Map Caps Lock (key code 57/0x39) to nothing (disable it)
            HIDKeyboardModifierMappingSrc = 30064771129; # Caps Lock
            HIDKeyboardModifierMappingDst = 30064771299; # No Action
          };
        };
      };
      "com.apple.dock" = {
        autohide = false;
        launchanim = false;
        static-only = false;
        show-recents = false;
        show-process-indicators = true;
        orientation = "left";
        tilesize = 48;
        minimize-to-application = true;
        mineffect = "scale";
        enable-window-tool = false;
      };
      "com.apple.ActivityMonitor" = {
        OpenMainWindow = true;
        IconType = 5;
        SortColumn = "CPUUsage";
        SortDirection = 0;
      };
      "com.apple.Safari" = {
        # Privacy: don’t send search queries to Apple
        UniversalSearchEnabled = false;
        SuppressSearchSuggestions = true;
      };
      "com.apple.AdLib" = {
        allowApplePersonalizedAdvertising = false;
      };
      "com.apple.SoftwareUpdate" = {
        AutomaticCheckEnabled = true;
        # Check for software updates daily, not just once per week
        ScheduleFrequency = 1;
        # Download newly available updates in background
        AutomaticDownload = 1;
        # Install System data files & security updates
        CriticalUpdateInstall = 1;
      };
      "com.apple.TimeMachine".DoNotOfferNewDisksForBackup = true;
      "com.apple.ImageCapture".disableHotPlug = true;
      "com.apple.commerce".AutoUpdate = true;
  };
}