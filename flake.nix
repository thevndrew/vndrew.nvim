# Copyright (c) 2023 BirdeeHub
# Licensed under the MIT license
# This is an empty nixCats config.
# you may import this template directly into your nvim folder
# and then add plugins to categories here,
# and call the plugins with their default functions
# within your lua, rather than through the nvim package manager's method.
# Use the help, and the example repository https://github.com/BirdeeHub/nixCats-nvim
# It allows for easy adoption of nix,
# while still providing all the extra nix features immediately.
# Configure in lua, check for a few categories, set a few settings,
# output packages with combinations of those categories and settings.
# All the same options you make here will be automatically exported in a form available
# in home manager and in nixosModules, as well as from other flakes.
# each section is tagged with its relevant help section.
{
  description = "Andrew's neovim config nixCats-ified!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
    # nixCats.inputs.nixpkgs.follows = "nixpkgs";

    express_line-nvim = {
      url = "github:tjdevries/express_line.nvim";
      flake = false;
    };

    telescope-smart-history-nvim = {
      url = "github:nvim-telescope/telescope-smart-history.nvim";
      flake = false;
    };

    render-markdown-nvim = {
      url = "github:MeanderingProgrammer/render-markdown.nvim";
      flake = false;
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
    };

    nvim-dbee = {
      url = "github:kndndrj/nvim-dbee";
      flake = false;
    };

    # see :help nixCats.flake.inputs
    # If you want your plugin to be loaded by the standard overlay,
    # i.e. if it wasnt on nixpkgs, but doesn't have an extra build step.
    # Then you should name it "plugins-something"
    # If you wish to define a custom build step not handled by nixpkgs,
    # then you should name it in a different format, and deal with that in the
    # overlay defined for custom builds in the overlays directory.
    # for specific tags, branches and commits, see:
    # https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html#examples
  };

  # see :help nixCats.flake.outputs
  outputs = {
    self,
    nixpkgs,
    nixCats,
    ...
  } @ inputs: let
    inherit (nixCats) utils;
    luaPath = "${./.}";
    forEachSystem = utils.eachSystem nixpkgs.lib.platforms.all;
    # the following extra_pkg_config contains any values
    # which you want to pass to the config set of nixpkgs
    # import nixpkgs { config = extra_pkg_config; inherit system; }
    # will not apply to module imports
    # as that will have your system values
    extra_pkg_config = {
      # allowUnfree = true;
    };
    # sometimes our overlays require a ${system} to access the overlay.
    # management of this variable is one of the harder parts of using flakes.

    # so I have done it here in an interesting way to keep it out of the way.

    # First, we will define just our overlays per system.
    # later we will pass them into the builder, and the resulting pkgs set
    # will get passed to the categoryDefinitions and packageDefinitions
    # which follow this section.

    # this allows you to use ${pkgs.system} whenever you want in those sections
    # without fear.
    inherit
      (forEachSystem (system: let
        # see :help nixCats.flake.outputs.overlays
        dependencyOverlays =
          /*
          (import ./overlays inputs) ++
          */
          [
            # This overlay grabs all the inputs named in the format
            # `plugins-<pluginName>`
            # Once we add this overlay to our nixpkgs, we are able to
            # use `pkgs.neovimPlugins`, which is a set of our plugins.
            (utils.standardPluginOverlay inputs)
            # add any flake overlays here.
          ];
        # these overlays will be wrapped with ${system}
        # and we will call the same utils.eachSystem function
        # later on to access them.
      in {inherit dependencyOverlays;}))
      dependencyOverlays
      ;
    # see :help nixCats.flake.outputs.categories
    # and
    # :help nixCats.flake.outputs.categoryDefinitions.scheme
    categoryDefinitions = {
      pkgs,
      settings,
      categories,
      name,
      ...
    } @ packageDef: let
      inherit (pkgs.vimUtils) buildVimPlugin;

      # express_line-nvim = buildVimPlugin {
      #   pname = "express_line.nvim";
      #   version = "2024-05-16";
      #   src = inputs.express_line-nvim;
      #   meta.homepage = "https://github.com/tjdevries/express_line.nvim";
      # };

      telescope-smart-history-nvim = buildVimPlugin {
        pname = "telescope-smart-history.nvim";
        version = "2024-05-16";
        src = inputs.telescope-smart-history-nvim;
        meta.homepage = "https://github.com/nvim-telescope/telescope-smart-history.nvim";
      };

      render-markdown-nvim = buildVimPlugin {
        pname = "render-markdown.nvim";
        version = "2024-09-29";
        src = inputs.render-markdown-nvim;
        meta.homepage = "https://github.com/MeanderingProgrammer/render-markdown.nvim";
      };

      nvim-debee = pkgs.callPackage ./pkgs/nvim-debee {inherit inputs;};
    in {
      # to define and use a new category, simply add a new list to a set here,
      # and later, you will include categoryname = true; in the set you
      # provide when you build the package using this builder function.
      # see :help nixCats.flake.outputs.packageDefinitions for info on that section.

      # propagatedBuildInputs:
      # this section is for dependencies that should be available
      # at BUILD TIME for plugins. WILL NOT be available to PATH
      # However, they WILL be available to the shell
      # and neovim path when using nix develop
      propagatedBuildInputs = {
        general = with pkgs; [
        ];
      };

      # lspsAndRuntimeDeps:
      # this section is for dependencies that should be available
      # at RUN TIME for plugins. Will be available to PATH within neovim terminal
      # this includes LSPs
      lspsAndRuntimeDeps = with pkgs; {
        general = [
          universal-ctags
          ripgrep
          fd
          stdenv.cc.cc

          # language servers
          nodePackages."bash-language-server"
          nodePackages."dockerfile-language-server-nodejs"
          nodePackages."vscode-langservers-extracted"
          nodePackages."yaml-language-server"
          # lua-language-server
          # stylua
          nix-doc
          nixd

          # formatters
          alejandra # nix

          # telescope-smart-history dep
          # pkgs.sqlite
        ];
        kickstart-debug = [
          delve
        ];
        kickstart-lint = [
          markdownlint-cli
        ];
      };

      # This is for plugins that will load at startup without using packadd:
      startupPlugins = with pkgs.vimPlugins; {
        general = [
          vim-dadbod
          vim-dadbod-completion
          vim-dadbod-ui

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
          lazydev-nvim
          lazy-nvim
          lspkind-nvim
          lsp_lines-nvim
          # lualine-nvim
          luasnip
          mini-nvim
          nvim-cmp
          nvim-lint
          nvim-lspconfig
          nvim-web-devicons
          oil-nvim
          plenary-nvim
          render-markdown-nvim
          telescope-fzf-native-nvim
          telescope-nvim
          telescope-smart-history-nvim
          telescope-ui-select-nvim
          todo-comments-nvim
          vim-fugitive
          vim-sleuth
          which-key-nvim

          nvim-treesitter-context
          nvim-treesitter.withAllGrammars
          # This is for if you only want some of the grammars
          # (nvim-treesitter.withPlugins (
          #   plugins: with plugins; [
          #     nix
          #     lua
          #   ]
          # ))
        ];
        debee = [
          nvim-debee
          nui-nvim
        ];
        kickstart-debug = [
          nvim-dap
          nvim-dap-ui
          nvim-dap-go
          nvim-dap-virtual-text
          nvim-nio
        ];
        kickstart-indent_line = [
          indent-blankline-nvim
        ];
        kickstart-lint = [
          nvim-lint
        ];
      };

      # not loaded automatically at startup.
      # use with packadd and an autocommand in config to achieve lazy loading
      # NOTE: this template is using lazy.nvim so, which list you put them in is irrelevant.
      # startupPlugins or optionalPlugins, it doesn't matter, lazy.nvim does the loading.
      # I just put them all in startupPlugins. I could have put them all in here instead.
      optionalPlugins = {};

      # shared libraries to be added to LD_LIBRARY_PATH
      # variable available to nvim runtime
      sharedLibraries = {
        general = with pkgs; [
          # libgit2
          # lua54Packages.jsregexp
        ];
      };

      # environmentVariables:
      # this section is for environmentVariables that should be available
      # at RUN TIME for plugins. Will be available to path within neovim terminal
      environmentVariables = {
        test = {
          CATTESTVAR = "It worked!";
        };
      };

      # If you know what these are, you can provide custom ones by category here.
      # If you dont, check this link out:
      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/setup-hooks/make-wrapper.sh
      extraWrapperArgs = {
        test = [
          ''--set CATTESTVAR2 "It worked again!"''
        ];
      };

      # lists of the functions you would have passed to
      # python.withPackages or lua.withPackages

      # get the path to this python environment
      # in your lua config via
      # vim.g.python3_host_prog
      # or run from nvim terminal via :!<packagename>-python3
      extraPython3Packages = {
        test = _: [];
      };
      # populates $LUA_PATH and $LUA_CPATH
      extraLuaPackages = {
        test = [(_: [])];
      };
    };

    # And then build a package with specific categories from above here:
    # All categories you wish to include must be marked true,
    # but false may be omitted.
    # This entire set is also passed to nixCats for querying within the lua.

    # see :help nixCats.flake.outputs.packageDefinitions
    packageDefinitions = {
      # These are the names of your packages
      # you can include as many as you wish.
      nvim = {pkgs, ...}: {
        # they contain a settings set defined above
        # see :help nixCats.flake.outputs.settings
        settings = {
          wrapRc = true;
          # IMPORTANT:
          # your alias may not conflict with your other packages.
          aliases = ["vim"];
        };
        # and a set of categories that you want
        # (and other information to pass to lua)
        categories = {
          general = true;
          gitPlugins = true;
          customPlugins = true;
          test = true;

          kickstart-debug = true;
          kickstart-lint = true;
          kickstart-indent_line = true;

          # this kickstart extra didnt require any extra plugins
          # so it doesn't have a category above.
          # but we can still send the info from nix to lua that we want it!
          kickstart-gitsigns = true;

          have_nerd_font = true;

          example = {
            youCan = "add more than just booleans";
            toThisSet = [
              "and the contents of this categories set"
              "will be accessible to your lua with"
              "nixCats('path.to.value')"
              "see :help nixCats"
              "and type :NixCats to see the categories set in nvim"
            ];
          };
        };
      };

      nvim-nightly = {pkgs, ...}: {
        settings = {
          wrapRc = true;
          aliases = ["vim"];
          neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${pkgs.system}.neovim;
        };
        categories = {
          general = true;
          gitPlugins = true;
          customPlugins = true;
          test = true;

          kickstart-debug = true;
          kickstart-lint = true;
          kickstart-indent_line = true;
          kickstart-gitsigns = true;
          have_nerd_font = true;
        };
      };

      # plain non-nerd icon vim
      pvim = {pkgs, ...}: {
        settings = {
          wrapRc = true;
        };
        categories = {
          general = true;
          gitPlugins = true;
          customPlugins = true;
          test = true;

          kickstart-debug = true;
          kickstart-lint = true;
          kickstart-indent_line = true;
          kickstart-gitsigns = true;
          have_nerd_font = false;
        };
      };
    };
    # In this section, the main thing you will need to do is change the default package name
    # to the name of the packageDefinitions entry you wish to use as the default.
    defaultPackageName = "nvim";
  in
    # see :help nixCats.flake.outputs.exports
    forEachSystem (system: let
      nixCatsBuilder =
        utils.baseBuilder luaPath {
          inherit nixpkgs system dependencyOverlays extra_pkg_config;
        }
        categoryDefinitions
        packageDefinitions;
      defaultPackage = nixCatsBuilder defaultPackageName;
      # this is just for using utils such as pkgs.mkShell
      # The one used to build neovim is resolved inside the builder
      # and is passed to our categoryDefinitions and packageDefinitions
      pkgs = import nixpkgs {inherit system;};
    in {
      # these outputs will be wrapped with ${system} by utils.eachSystem

      # this will make a package out of each of the packageDefinitions defined above
      # and set the default package to the one passed in here.
      packages = utils.mkAllWithDefault defaultPackage;

      # choose your package for devShell
      # and add whatever else you want in it.
      devShells = {
        default = pkgs.mkShell {
          name = defaultPackageName;
          packages = [defaultPackage];
          inputsFrom = [];
          nativeBuildInputs = with pkgs; [lua-language-server stylua nixd just];
          shellHook = ''
            echo "vndrew.nvim" | ${pkgs.figlet}/bin/figlet | ${pkgs.boxes}/bin/boxes -d vim-box
          '';
          NIX_PATH = "nixpkgs=${inputs.nixpkgs}";
          NIX_DEBUG = 7;
        };
      };
    })
    // {
      # these outputs will be NOT wrapped with ${system}

      # this will make an overlay out of each of the packageDefinitions defined above
      # and set the default overlay to the one named here.
      overlays =
        utils.makeOverlays luaPath {
          inherit nixpkgs dependencyOverlays extra_pkg_config;
        }
        categoryDefinitions
        packageDefinitions
        defaultPackageName;

      # we also export a nixos module to allow reconfiguration from configuration.nix
      nixosModules.default = utils.mkNixosModules {
        inherit
          defaultPackageName
          dependencyOverlays
          luaPath
          categoryDefinitions
          packageDefinitions
          extra_pkg_config
          nixpkgs
          ;
      };
      # and the same for home manager
      homeModule = utils.mkHomeModules {
        inherit
          defaultPackageName
          dependencyOverlays
          luaPath
          categoryDefinitions
          packageDefinitions
          extra_pkg_config
          nixpkgs
          ;
      };
      inherit utils;
      inherit (utils) templates;
    };
}
