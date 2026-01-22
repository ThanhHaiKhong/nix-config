{ config, inputs, pkgs, lib, unstablePkgs, ... }:
{
  home.stateVersion = "23.11";
  home.homeDirectory = "/Users/${config.home.username}";

  programs.gpg.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

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

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    tmux.enableShellIntegration = true;
    defaultOptions = [
      "--no-mouse"
    ];
  };

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

  programs.diff-so-fancy = {
    enable = true;
    enableGitIntegration = true;
  };

  programs.htop = {
    enable = true;
    settings.show_program_path = true;
  };

  programs.lf.enable = true;

   programs.starship = {
     enable = true;
     enableZshIntegration = false;
     settings = builtins.fromTOML (builtins.readFile ./starship/starship.toml);
   };

  programs.bash.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;

    # Enhanced completion settings
    completionInit = ''
      # Load and initialize completion system
      autoload -Uz compinit && compinit

      # Basic completion styling
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
    '';

    envExtra = builtins.readFile ./zsh/.zshenv;

    shellAliases = {
      cat = "${pkgs.bat}/bin/bat";
      ls = "eza";
      ll = "eza -l";
      la = "eza -la";
      tree = "eza --tree";
      vi = "nvim";
      vim = "nvim";
      diff = "diff-so-fancy";
    };
  };

  programs.home-manager.enable = true;
  programs.nix-index.enable = true;
  programs.wezterm = {
    enable = true;
    extraConfig = builtins.readFile ./wezterm/wezterm.lua;
  };

   programs.bat.enable = true;
   programs.bat.config.theme = "Nord";

  # programs.neovim = {
  #   enable = true;
  #   viAlias = true;
  #   vimAlias = true;
  #   vimdiffAlias = true;
  #
  #   # Minimal plugins - lazy.nvim handles the rest via lua/plugins.lua
  #   plugins = with pkgs.vimPlugins; [
  #     # Plugin manager
  #     lazy-nvim
  #
  #     # Core dependencies that lazy needs
  #     plenary-nvim
  #   ];
  #
  #   # Point to our reorganized config structure
  #   extraConfig = ''
  #     -- Load main configuration entry point
  #     vim.cmd('luafile ./init.lua')
  #   '';
  # };

  programs.zoxide.enable = true;

  # Enable zsh modules through Home Manager
  programs.zsh.syntaxHighlighting.enable = false;
  programs.zsh.autosuggestion.enable = false;

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