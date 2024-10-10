{
  inputs,
  system,
  buildGoModule,
  vimUtils,
  ...
}: let
  pkgs = import inputs.nixpkgs {
    inherit system;
    config = {
      allowUnfree = true;
    };
  };

  bin = buildGoModule {
    name = "dbee";
    src = inputs.nvim-dbee;
    sourceRoot = "source/dbee";
    buildInputs = with pkgs; [duckdb arrow-cpp];
    vendorHash = "sha256-U/3WZJ/+Bm0ghjeNUILsnlZnjIwk3ySaX3Rd4L9Z62A=";
  };
in
  vimUtils.buildVimPlugin {
    name = "nvim-dbee";
    src = inputs.nvim-dbee;
    propagatedBuildInputs = [bin];
    passthru.dbee = bin;
  }
