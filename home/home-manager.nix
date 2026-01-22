{ config, inputs, pkgs, lib, unstablePkgs, ... }:
{
  # Home Manager version for compatibility
  home.stateVersion = "25.11";
  home.enableNixpkgsReleaseCheck = false;

  home.sessionVariables.SHELL = "${pkgs.zsh}/bin/zsh";
  
  # User's home directory path
  home.homeDirectory = "/Users/${config.home.username}";
  
  # Enable Home Manager itself
  programs.home-manager.enable = true;

  # Nix package indexer for fast searching
  programs.nix-index.enable = true;
  
  # GPG for encryption and signing
  programs.gpg.enable = true;

  # Environment switcher for projects
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Modern ls replacement with icons and git integration
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    icons = "auto";
    git = true;
    extraOptions = [
      "--group-directories-first"
      "--header"
      "--color=auto"
    ];
  };

  # Fuzzy finder for files and commands
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    tmux.enableShellIntegration = true;
    defaultOptions = [
      "--no-mouse"
    ];
  };

  # Git version control with LFS and custom settings
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user = {
        email = "khongthanhhai@gmail.com";
        name = "Thanh Hai Khong";
      };
      init = {
        defaultBranch = "main";
      };
      merge = {
        conflictStyle = "diff3";
        tool = "meld";
      };
      pull = {
        rebase = true;
      };
    };
  };

  # Enhanced git diff output
  programs.diff-so-fancy = {
    enable = true;
    enableGitIntegration = true;
  };

  # Interactive process viewer
  programs.htop = {
    enable = true;
    settings.show_program_path = true;
  };

  # Terminal file manager
  programs.lf.enable = true;

  # Bash shell support
  programs.bash.enable = true;

  # Zsh shell with completion, environment, and aliases
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      ll = "ls -la";
      switch = "home-manager switch --flake ~/.config/nix";
      update = "sudo nixos-rebuild switch";
    };
  };

  # Cross-shell prompt with custom config
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = builtins.fromTOML (builtins.readFile ./starship/starship.toml);
  };

  # Terminal emulator with Lua config
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    extraConfig = builtins.readFile ./wezterm/wezterm.lua;
  };

  # Cat with syntax highlighting and Nord theme
  programs.bat.enable = true;
  programs.bat.config.theme = "Nord";

  # Neovim text editor with plugins and custom config
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    plugins = with pkgs.vimPlugins; [
      lazy-nvim 
      plenary-nvim
    ];
    extraConfig = ''
      luafile ${config.home.homeDirectory}/nvim/init.lua
    '';
  };

  # Smarter directory navigation
  programs.zoxide.enable = true;

  # SSH client configuration
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        forwardAgent = false;
        addKeysToAgent = "no";
        compression = false;
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
        extraOptions = {
          StrictHostKeyChecking = "ask";
        };
      };
      "github.com" = {
        hostname = "ssh.github.com";
        port = 443;
      };
    };
  };
}