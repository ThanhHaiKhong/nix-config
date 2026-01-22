{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:lnl7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core = { url = "github:homebrew/homebrew-core"; flake = false; };
    homebrew-cask = { url = "github:homebrew/homebrew-cask"; flake = false; };
    homebrew-bundle = { url = "github:homebrew/homebrew-bundle"; flake = false; };

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-darwin";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { ... }@inputs:
    with inputs;
    let
      inherit (self) outputs;

      stateVersion = "24.05";
      libx = import ./lib { inherit inputs outputs stateVersion; };

    in {
      darwinConfigurations = {
        # personal
        macbook-pro = libx.mkDarwin { hostname = "macbook-pro"; };

        # work
        mac-mini = libx.mkDarwin { hostname = "mac-mini"; };
      };

      # NixOS configurations (currently disabled)
      # nixosConfigurations = {
      #   morphnix = import ./hosts/nixos/morphnix;
      #   nvllama = import ./hosts/nixos/nvllama;
      # };

    };
}
