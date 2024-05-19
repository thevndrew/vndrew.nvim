{
  description = "Neovim configuration for vndrew as a plugin";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      #inputs.nixpkgs.follows = "nixpkgs";
    };

    express_line-nvim = {
      url = "github:tjdevries/express_line.nvim";
      flake = false;
    };

    telescope-smart-history-nvim = {
      url = "github:nvim-telescope/telescope-smart-history.nvim";
      flake = false;
    };
  };

  outputs = inputs @ {
    self,
    flake-parts,
    nixpkgs,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      flake = {
        lib = import ./lib {inherit inputs;};
      };

      systems = [
        "x86_64-linux"
      ];

      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: let
        inherit (pkgs) alejandra just mkShell;
      in {
        apps = {
          nvim = {
            program = "${config.packages.neovim}/bin/nvim";
            type = "app";
          };
        };

        devShells = {
          default = mkShell {
            buildInputs = [just];
          };
        };

        formatter = alejandra;

        packages = {
          default = self.lib.mkVimPlugin {inherit system;};
          neovim = self.lib.mkNeovim {inherit system;};
        };
      };
    };
}
