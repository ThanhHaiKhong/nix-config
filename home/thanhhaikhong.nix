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
      dotDir = "zsh";
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "docker" "kubectl" ];
        theme = "robbyrussell";
      };
      shellAliases = {
        cat = "${pkgs.bat}/bin/bat";
        ls = "eza";
        ll = "eza -l";
        la = "eza -la";
        tree = "eza --tree";
        cd = "z";
        vi = "nvim";
        vim = "nvim";
        diff = "diff-so-fancy";
      };
      initExtra = ''
        # Enable vi mode
        bindkey -v

        # Better history search
        bindkey '^R' history-incremental-search-backward

        # Custom prompt or other settings can go here
      '';
    };

   programs.tmux = {
     enable = true;
     plugins = with pkgs.tmuxPlugins; [
       tpm
     ];
     extraConfig = builtins.readFile ./tmux/tmux.conf;
   };

  programs.home-manager.enable = true;
  programs.nix-index.enable = true;

   programs.alacritty.enable = true;

   programs.wezterm = {
     enable = true;
     extraConfig = builtins.readFile ./wezterm/wezterm.lua;
   };

  programs.bat.enable = true;
  programs.bat.config.theme = "Nord";
  #programs.zsh.shellAliases.cat = "${pkgs.bat}/bin/bat";

  # programs.neovim = {
  #   enable = true;
  #   viAlias = true;
  #   vimAlias = true;
  #   vimdiffAlias = true;
  #   plugins = with pkgs.vimPlugins; [
  #     ## regular
  #     comment-nvim
  #     lualine-nvim
  #     nvim-web-devicons
  #     vim-tmux-navigator

  #     ## with config
  #     # {
  #     #   plugin = gruvbox-nvim;
  #     #   config = "colorscheme gruvbox";
  #     # }

  #     {
  #       plugin = catppuccin-nvim;
  #       config = "colorscheme catppuccin";
  #     }

  #     ## telescope
  #     {
  #       plugin = telescope-nvim;
  #       type = "lua";
  #       config = builtins.readFile ./nvim/plugins/telescope.lua;
  #     }
  #     telescope-fzf-native-nvim

  #   ];
  #   extraLuaConfig = ''
  #     ${builtins.readFile ./nvim/options.lua}
  #     ${builtins.readFile ./nvim/keymap.lua}
  #   '';
  # };

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