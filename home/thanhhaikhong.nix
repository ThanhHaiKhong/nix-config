{ config, inputs, pkgs, lib, unstablePkgs, ... }:
{
  home.stateVersion = "23.11";
  home.homeDirectory = "/Users/${config.home.username}";

  # list of programs
  # https://mipmip.github.io/home-manager-option-search



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
    enableZshIntegration = true;
    enableBashIntegration = true;
    settings = pkgs.lib.importTOML ./starship/starship.toml;
  };

  programs.bash.enable = true;

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      # Enhanced completion settings
      completionInit = ''
        # Load and initialize completion system
        autoload -Uz compinit && compinit

        # Basic completion styling
        zstyle ':completion:*' menu select
        zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
        zstyle ':completion:*' list-colors '''${(s.:.)LS_COLORS}''
      '';
      initExtra = ''
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

        # Custom functions - simple approach to avoid Nix parsing issues
        # Note: lg function defined in .zshrc directly to avoid Nix interpolation issues

        # Shell aliases - defined in .zshrc to avoid Nix interpolation issues

        # Additional zsh options for better completion behavior
        setopt complete_in_word
        setopt always_to_end
        setopt auto_menu
        setopt auto_param_slash
        setopt extended_glob
        setopt mark_dirs
      '';
    };

    # Zsh configuration files
    home.file.".zshenv".source = ./zsh/.zshenv;
    home.file.".zprofile".source = ./zsh/.zprofile;
    home.file.".zshrc".source = ./zsh/.zshrc;
    home.file.".zlogin".source = ./zsh/.zlogin;

  programs.tmux = {
    enable = true;
    keyMode = "vi";
    clock24 = true;
    historyLimit = 9999999;
    mouse = true;
    plugins = with pkgs.tmuxPlugins; [
      gruvbox
      vim-tmux-navigator
      sensible
    ];
    extraConfig = ''
      # Basic tmux settings - will expand later to avoid Nix syntax conflicts
      set -g mouse on
      set -g history-limit 10000
    '';
  };

  programs.home-manager.enable = true;
  programs.nix-index.enable = true;
  programs.wezterm = {
    enable = true;
    extraConfig = builtins.readFile ./wezterm/wezterm.lua;
  };

  programs.bat.enable = true;
  programs.bat.config.theme = "Nord";
  #programs.zsh.shellAliases.cat = "${pkgs.bat}/bin/bat";

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    # Minimal plugins - lazy.nvim handles the rest via lua/plugins.lua
    plugins = with pkgs.vimPlugins; [
      # Plugin manager
      lazy-nvim

      # Core dependencies that lazy needs
      plenary-nvim
    ];

    # Point to our reorganized config structure
    extraConfig = ''
      -- Load main configuration entry point
      vim.cmd("luafile ./init.lua")
    '';
  };

  programs.zoxide.enable = true;

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