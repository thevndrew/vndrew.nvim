{ inputs }:
let
  inherit (inputs.nixpkgs) legacyPackages;
in rec {

  mkVimPlugin = {system}:
  let
    inherit (pkgs) vimUtils;
    inherit (vimUtils) buildVimPlugin;
    pkgs = legacyPackages.${system};
  in
    buildVimPlugin {
      name = "vndrew";
      postInstall = ''
        rm -rf $out/.envrc
        rm -rf $out/.gitignore
        rm -rf $out/LICENSE
        rm -rf $out/README.md
        rm -rf $out/flake.lock
        rm -rf $out/flake.nix
        rm -rf $out/justfile
        rm -rf $out/lib
      '';
      src = ../.;
    };

  mkNeovimPlugins = {system}:
  let
    inherit (pkgs) vimPlugins;
    pkgs = legacyPackages.${system};
    vndrew-nvim = mkVimPlugin {inherit system;};
  in [
    # languages
    vimPlugins.nvim-lspconfig
    vimPlugins.nvim-treesitter.withAllGrammars
    vimPlugins.vim-just

    # telescope
    vimPlugins.plenary-nvim
    vimPlugins.telescope-nvim

    vimPlugins.cmp_luasnip
    vimPlugins.cmp-nvim-lsp
    vimPlugins.cmp-path
    vimPlugins.colorbuddy-nvim
    vimPlugins.comment-nvim
    vimPlugins.conform-nvim
    vimPlugins.fidget-nvim
    vimPlugins.friendly-snippets
    vimPlugins.gitsigns-nvim
    vimPlugins.indent-blankline-nvim
    vimPlugins.lualine-nvim
    vimPlugins.luasnip
    vimPlugins.mini-nvim
    vimPlugins.neodev-nvim
    vimPlugins.nvim-cmp
    vimPlugins.nvim-dap
    vimPlugins.nvim-dap-go
    vimPlugins.nvim-dap-ui
    vimPlugins.nvim-lint
    vimPlugins.nvim-nio
    vimPlugins.nvim-web-devicons # figure out how to enable nerd
    vimPlugins.telescope-fzf-native-nvim
    vimPlugins.telescope-ui-select-nvim
    vimPlugins.todo-comments-nvim
    vimPlugins.trouble-nvim
    vimPlugins.vim-sleuth
    vimPlugins.which-key-nvim
    vimPlugins.nui-nvim

    # configuration
    vndrew-nvim
  ];

  mkExtraPackages = {system}: let
    inherit (pkgs) nodePackages ocamlPackages python3Packages;
    pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in [
    # language servers
    #nodePackages."bash-language-server"
    #nodePackages."diagnostic-languageserver"
    #nodePackages."dockerfile-language-server-nodejs"
    #nodePackages."pyright"
    #nodePackages."vscode-langservers-extracted"
    #nodePackages."yaml-language-server"
    #pkgs.gopls
    pkgs.lua-language-server

    pkgs.luajitPackages.jsregexp

    # formatters
    pkgs.alejandra
    pkgs.stylua
    #pkgs.gofumpt
    #pkgs.golines
    #python3Packages.black
  ];

  mkExtraConfig = ''
    lua << EOF
      require 'vndrew'.init()
    EOF
  '';

  mkNeovim = {system}: let
    inherit (pkgs) lib neovim;
    extraPackages = mkExtraPackages {inherit system;};
    pkgs = legacyPackages.${system};
    start = mkNeovimPlugins {inherit system;};
  in
    neovim.override {
      configure = {
        customRC = mkExtraConfig;
        packages.main = {inherit start;};
      };
      extraMakeWrapperArgs = ''--suffix PATH : "${lib.makeBinPath extraPackages}"'';
      withNodeJs = true;
      withPython3 = true;
      withRuby = true;
    };

  mkHomeManager = {system}: let
    extraConfig = mkExtraConfig;
    extraPackages = mkExtraPackages {inherit system;};
    plugins = mkNeovimPlugins {inherit system;};
  in {
    inherit extraConfig extraPackages plugins;
    defaultEditor = true;
    enable = true;
    withNodeJs = true;
    withPython3 = true;
    withRuby = true;
  };
}
