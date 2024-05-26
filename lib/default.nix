{inputs}: let
  inherit (inputs.nixpkgs) legacyPackages;
in rec {
  mkVimPlugin = {system}: let
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

  mkNeovimPlugins = {system}: let
    inherit (pkgs) vimPlugins;
    inherit (pkgs.vimUtils) buildVimPlugin;
    pkgs = legacyPackages.${system};
    vndrew-nvim = mkVimPlugin {inherit system;};

    express_line-nvim = buildVimPlugin {
      pname = "express_line.nvim";
      version = "2024-05-16";
      src = inputs.express_line-nvim;
      meta.homepage = "https://github.com/tjdevries/express_line.nvim";
    };

    telescope-smart-history-nvim = buildVimPlugin {
      pname = "telescope-smart-history.nvim";
      version = "2024-05-16";
      src = inputs.telescope-smart-history-nvim;
      meta.homepage = "https://github.com/nvim-telescope/telescope-smart-history.nvim";
    };
  in
    with vimPlugins; [
      telescope-smart-history-nvim
      express_line-nvim

      cmp-buffer
      cmp_luasnip
      cmp-nvim-lsp
      cmp-path
      colorbuddy-nvim
      comment-nvim
      conform-nvim
      fidget-nvim
      friendly-snippets
      gitsigns-nvim
      harpoon2
      indent-blankline-nvim
      lspkind-nvim
      lualine-nvim
      luasnip
      mini-nvim
      neodev-nvim
      nui-nvim
      nvim-cmp
      nvim-dap
      nvim-dap-go
      nvim-dap-ui
      nvim-dap-virtual-text
      nvim-dbee
      nvim-lint
      nvim-lspconfig
      nvim-nio
      nvim-treesitter-context
      nvim-treesitter.withAllGrammars
      nvim-web-devicons # figure out how to enable nerd
      oil-nvim
      plenary-nvim
      SchemaStore-nvim
      {
        plugin = sqlite-lua;
        config = "let g:sqlite_clib_path = '${pkgs.sqlite.out}/lib/libsqlite3.so'";
      }
      telescope-fzf-native-nvim
      telescope-nvim
      telescope-ui-select-nvim
      todo-comments-nvim
      trouble-nvim
      vim-dadbod
      vim-dadbod-completion
      vim-dadbod-ui
      vim-fugitive
      vim-just
      vim-sleuth
      which-key-nvim

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
    nodePackages."bash-language-server"
    nodePackages."dockerfile-language-server-nodejs"
    nodePackages."vscode-langservers-extracted"
    nodePackages."yaml-language-server"
    #nodePackages."diagnostic-languageserver"
    #nodePackages."pyright"
    pkgs.lua-language-server
    pkgs.nil
    #pkgs.gopls

    # formatters
    pkgs.alejandra
    pkgs.stylua
    #pkgs.gofumpt
    #pkgs.golines
    #python3Packages.black

    # telescope-smart-history dep
    pkgs.sqlite
  ];

  mkExtraLuaPackages = {system}: let
    inherit (pkgs) lua54Packages;
    pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in [
    # luasnip dep
    lua54Packages.jsregexp
  ];

  mkExtraConfig = ''
    lua << EOF
      require('vndrew').init()
    EOF
  '';

  mkNeovim = {system}: let
    inherit (pkgs) neovim;
    extraPackages = mkExtraPackages {inherit system;};
    pkgs = legacyPackages.${system};
    start = mkNeovimPlugins {inherit system;};
  in
    neovim.override {
      configure = {
        customRC = mkExtraConfig;
        packages.main = {inherit start;};
      };
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
