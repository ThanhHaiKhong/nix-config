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
    autosuggestion.enable = true;
    autosuggestion.highlight = "fg=#ff00ff,bg=cyan,bold,underline";
    oh-my-zsh.enable = true;
    syntaxHighlighting.enable = true;
    syntaxHighlighting.highlighters = [ "main" "brackets" "pattern" "root" ];
    syntaxHighlighting.patterns = {
      directory = "fg=blue,bold";
      symlink = "fg=cyan,underline";
      executable = "fg=green,bold";
    };
    syntaxHighlighting.styles = {
      command = "fg=yellow,bold";
      alias = "fg=magenta,bold";
      builtin = "fg=red,bold";
    };
  };

  # Cross-shell prompt with custom config
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = builtins.fromTOML (builtins.readFile ./configs/starship/starship.toml);
  };

  # Terminal emulator with Lua config
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    extraConfig = builtins.readFile ./configs/wezterm/wezterm.lua;
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
  };

  # Neovim configuration files
  home.file.".config/bin" = {
    source = pkgs.runCommand "swift-bin-scripts" {} ''
      mkdir -p $out
      ${lib.concatMapStringsSep "\n" (script: ''
        cp -r ${pkgs.writeShellScriptBin (builtins.baseNameOf script) (builtins.readFile script)}/bin/* $out/
      '') (map (name: ./configs/local/bin/swift + "/${name}") (builtins.attrNames (builtins.readDir ./configs/local/bin/swift)))}
    '';
  };
  home.sessionPath = [ "$HOME/.config/bin" ];
  xdg.configFile."nvim" = {
    source = ./configs/nvim;
    recursive = true;
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

  # MCPs
  programs.mcp = {
    enable = true;
    servers = {
      everything = {
        command = "npx";
        args = [
          "-y"
          "@modelcontextprotocol/server-everything"
        ];
      };
    };
  };

   # Opencode
   programs.opencode = {
     enable = true;
     package = pkgs.opencode;
     enableMcpIntegration = true;
     settings = {
       agent = {
         build = {
           permission = {
             task = {
               "*" = "allow";
               "swift-build" = "allow";
               "swift-format" = "allow";
               "swift-lint" = "allow";
               "swift-classify-changes" = "allow";
               "web-search-researcher" = "allow";
               "thoughts-locator" = "allow";
               "thoughts-analyzer" = "allow";
               "codebase-pattern-finder" = "allow";
               "codebase-locator" = "allow";
               "codebase-analyzer" = "allow";
             };
           };
         };
         plan = {
           permission = {
             task = {
               "*" = "allow";
               "swift-build" = "allow";
               "swift-format" = "allow";
               "swift-lint" = "allow";
               "swift-classify-changes" = "allow";
               "web-search-researcher" = "allow";
               "thoughts-locator" = "allow";
               "thoughts-analyzer" = "allow";
               "codebase-pattern-finder" = "allow";
               "codebase-locator" = "allow";
               "codebase-analyzer" = "allow";
             };
           };
         };
       };
     };
     rules = ./AGENTS.md;
     agents = {
codebase-analyzer = ./configs/opencode/agents/codebase-analyzer.md;
        codebase-locator = ./configs/opencode/agents/codebase-locator.md;
        codebase-pattern-finder = ./configs/opencode/agents/codebase-pattern-finder.md;
        thoughts-analyzer = ./configs/opencode/agents/thoughts-analyzer.md;
        thoughts-locator = ./configs/opencode/agents/thoughts-locator.md;
        "web-search-researcher" = ./configs/opencode/agents/web-search-researcher.md;
     };
     commands = {
       swift-build = ./configs/opencode/commands/swift-build.md;
       swift-classify-changes = ./configs/opencode/commands/swift-classify-changes.md;
       swift-format = ./configs/opencode/commands/swift-format.md;
       swift-lint = ./configs/opencode/commands/swift-lint.md;
     };
   };
}