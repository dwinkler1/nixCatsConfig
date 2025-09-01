# Copyright (c) 2023 BirdeeHub
# Licensed under the MIT license
{
  description = "Daniel's NixCats";

  inputs = {
    # see :help nixCats.flake.inputs

    # Nix inputs
    # TODO: move this to stable once 25.11 is out
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
    rixpkgs.url = "https://github.com/rstats-on-nix/nixpkgs/archive/2025-08-25.tar.gz";

    # neovim plugs
    "plugins-r" = {
      url = "github:R-nvim/R.nvim";
      flake = false;
    };
    "plugins-cmp-r" = {
      url = "github:R-nvim/cmp-r";
      flake = false;
    };
    "plugins-cmp-pandoc-references" = {
      url = "github:jmbuhr/cmp-pandoc-references";
      flake = false;
    };
  };

  # see :help nixCats.flake.outputs
  outputs = {
    self,
    nixpkgs,
    nixCats,
    ...
  } @ inputs: let
    inherit (nixCats) utils;
    luaPath = ./.;
    forEachSystem = utils.eachSystem ["aarch64-darwin" "x86_64-linux" "aarch64-linux"];

    # Calls: import nixpkgs { config = extra_pkg_config; inherit system; }
    extra_pkg_config = {
      # allowUnfree = true;
    };

    #pwd = builtins.getEnv "PWD";
    # see :help nixCats.flake.outputs.overlays
    dependencyOverlays =
      /*
      (import ./overlays inputs) ++
      */
      [
        # use `pkgs.neovimPlugins`, which is a set of our plugins.
        (utils.standardPluginOverlay inputs)
        # add any other flake overlays here.

        ### R Packages
        (final: prev: {
          rpkgs = inputs.rixpkgs.legacyPackages.${prev.system};
        })
        (
          final: prev: let
            reqPkgs = with prev.rpkgs.rPackages; [
              arrow
              broom
              data_table
              devtools
              janitor
              languageserver
              quarto
              reprex
              styler
              tidyverse
              (buildRPackage {
                name = "nvimcom";
                src = inputs.plugins-r;
                sourceRoot = "source/nvimcom";
                buildInputs = with prev.rpkgs; [
                  R
                  stdenv.cc.cc
                  gnumake
                ];
                propagatedBuildInputs = [];
              })
            ];
          in {
            quarto = prev.rpkgs.quarto.override {extraRPackages = reqPkgs;};
            rWrapper = prev.rpkgs.rWrapper.override {packages = reqPkgs;};
          }
        )

        ### Python Packages
        (
          final: prev: let
            reqPkgs = pyPackages:
              with pyPackages; [
              ];
          in {
            python = prev.python3.withPackages reqPkgs;
          }
        )

        ### Unstable pkgs
        # (
        #   final: prev: let
        #     pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${prev.system};
        #   in {
        #     clickhouse-lts = pkgs-unstable.clickhouse-lts;
        #   }
        # )

        ### General fixes
        (
          final: prev: {
            codecompanion-nvim = prev.vimPlugins.codecompanion-nvim.overrideAttrs {
              checkInputs = with prev.vimPlugins; [
                blink-cmp
                mini-nvim
              ];
              dependencies = [prev.vimPlugins.plenary-nvim];
              nvimSkipModules = [
                # Requires setup call
                "codecompanion.actions.static"
                "codecompanion.actions.init"
                # Test
                "minimal"
                # Fails on darwin
                "codecompanion.providers.actions.fzf_lua"
                # Not using
                "codecompanion.providers.completion.cmp.setup"
                "codecompanion.providers.actions.telescope"
                "codecompanion.providers.actions.snacks"
              ];
            };
          }
        )
        # (utils.fixSystemizedOverlay inputs.codeium.overlays
        #   (system: inputs.codeium.overlays.${system}.default)
        # )
      ];

    # :help nixCats.flake.outputs.categories
    # :help nixCats.flake.outputs.categoryDefinitions.scheme
    # :help nixCats.flake.outputs.packageDefinitions
    categoryDefinitions = {
      pkgs,
      settings,
      categories,
      extra,
      name,
      mkPlugin,
      ...
    } @ packageDef: {
      lspsAndRuntimeDeps = {
        external = with pkgs; [
          clickhouse-lts
          devenv
          duckdb
          fd
          gawk
          gh
          git
          hunspell
          hunspellDicts.de-at
          hunspellDicts.en-us
          ispell
          jq
          just
          lazygit
          lynx
          man
          pandoc
          perl
          pigz
          poppler
          rclone
          ripgrep
          rsync
          ruby
          shfmt
          sqlfluff
          tldr
          tree-sitter
          wget
          zathura
          zoxide
          zsh
        ];
        markdown = with pkgs; [
          python313Packages.pylatexenc
          quarto
          zk
        ];
        nix = with pkgs; [
          alejandra
          nix-doc
          nixd
        ];
        lua = with pkgs; [
          lua-language-server
        ];
        python = with pkgs; [
          python
          nodejs
          basedpyright
          uv
        ];
        r = with pkgs; [
          rWrapper
          radianWrapper
          quarto
          air-formatter
        ];
      };

      # This is for plugins that will load at startup without using packadd:
      startupPlugins = {
        gitPlugins = with pkgs.neovimPlugins; [
          r
        ];
        general = with pkgs.vimPlugins; [
          lze
          lzextras
          plenary-nvim
          neogit
          {
            plugin = mini-nvim;
            name = "mini.nvim";
          }
          {
            plugin = cyberdream-nvim;
            name = "cyberdream";
          }
          {
            plugin = onedark-nvim;
            name = "onedark";
          }
          {
            plugin = tokyonight-nvim;
            name = "tokyonight";
          }
          {
            plugin = kanagawa-nvim;
            name = "kanagawa";
          }
          {
            plugin = gruvbox-nvim;
            name = "gruvbox";
          }
          {
            plugin = nord-nvim;
            name = "nord";
          }
          {
            plugin = dracula-nvim;
            name = "dracula";
          }
          {
            plugin = vscode-nvim;
            name = "vscode";
          }
          {
            plugin = nightfox-nvim;
            name = "nightfox";
          }
          {
            plugin = catppuccin-nvim;
            name = "catppuccin";
          }
        ];
        lua = with pkgs.vimPlugins; [
          luvit-meta
          {
            plugin = lazydev-nvim;
            name = "lazydev";
          }
        ];
        markdown = with pkgs.vimPlugins; [
          quarto-nvim
          render-markdown-nvim
          {
            plugin = otter-nvim;
            name = "otter";
          }
          {
            plugin = zk-nvim;
            name = "zk";
          }
        ];
        utils = with pkgs.vimPlugins; [
          blink-cmp
          nvim-lspconfig
          nvim-treesitter-context
          nvim-treesitter-textobjects
          nvim-treesitter.withAllGrammars
          {
            plugin = pkgs.codecompanion-nvim;
            name = "codecompanion";
          }
        ];
      };

      # not loaded automatically at startup.
      # use with packadd and an autocommand in config to achieve lazy loading
      optionalPlugins = {
        gitPlugins = with pkgs.neovimPlugins; [
          cmp-pandoc-references
          cmp-r
        ];
        general = with pkgs.vimPlugins; [];
        utils = with pkgs.vimPlugins; [
          blink-compat
          blink-copilot
          cmp-cmdline
          colorful-menu-nvim
          conform-nvim
          copilot-lua
          nvim-dap
          nvim-dap-ui
          nvim-dap-virtual-text
          nvim-lint
          vim-slime
        ];
        markdown = with pkgs.vimPlugins; [
        ];
      };

      # shared libraries to be added to LD_LIBRARY_PATH
      # variable available to nvim runtime
      sharedLibraries = {
        general = with pkgs; [
          # libgit2
        ];
      };

      # environmentVariables:
      # this section is for environmentVariables that should be available
      # at RUN TIME for plugins. Will be available to path within neovim terminal
      environmentVariables = {
        r = {
          R_LIBS_USER = "./.Rlibs";
        };
        python = {
          # Prevent uv from managing Python downloads
          UV_PYTHON_DOWNLOADS = "never";
          # Force uv to use nixpkgs Python interpreter
          UV_PYTHON = pkgs.python.interpreter;
        };
        test = {
          TESTVAR = "It worked!";
        };
      };

      ## lua config
      optionalLuaPreInit = {
        external = [''vim.o.shell = "${pkgs.zsh}/bin/zsh"''];
      };

      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/setup-hooks/make-wrapper.sh
      extraWrapperArgs = {
        test = [
          ''--set TESTVAR2 "It worked again!"''
        ];
      };

      extraLuaPackages = {
        general = [(lp: lp.tiktoken_core)];
      };

      # in neovim: vim.g.python3_host_prog
      # or run from nvim terminal via :!<packagename>-python3
      python3.libraries = {
        test = _: [];
      };
    };

    # This entire set is also passed to nixCats for querying within the lua.
    # see :help nixCats.flake.outputs.packageDefinitions
    packageDefinitions = {
      n = {
        pkgs,
        name,
        ...
      }: {
        # they contain a settings set defined above
        # see :help nixCats.flake.outputs.settings
        settings = {
          suffix-path = false;
          suffix-LD = false;
          wrapRc = true;
          autowrapRuntimeDeps = "prefix";
          # your alias may not conflict with your other packages.
          aliases = ["vim"];
          hosts = {
            node.enable = true;
            perl.enable = true;
            python3.enable = true;
            ruby.enable = true;
            g = {
              enable = true;
              path = {
                value = "${pkgs.neovide}/bin/neovide";
                args = [
                  "--add-flags"
                  "--neovim-bin ${name}"
                ];
              };
            };
            m = {
              enable = true;
              path = {
                value = "${pkgs.uv}/bin/uv";
                args = ["--add-flags" "run marimo edit"];
              };
            };
            jl = {
              enable = true;
              path = {
                value = "${pkgs.julia-bin}/bin/julia";
                args = [
                  "--add-flags"
                  "--project=@."
                ];
              };
            };
            r = {
              enable = true;
              path = {
                value = "${pkgs.rWrapper}/bin/R";
                args = [
                  "--add-flags"
                  "--no-save --no-restore"
                ];
              };
            };
          };
        };
        categories = {
          customPlugins = true;
          external = true;
          general = true;
          gitPlugins = true;
          lua = true;
          markdown = true;
          nix = true;
          python = true;
          r = false;
          utils = true;
          test = false;
          background = "dark";
          colorscheme = "kanagawa";
        };
      };
    };
    defaultPackageName = "n";
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
          nativeBuildInputs = with pkgs; [devenv];
          inputsFrom = [];
          shellHook = ''
          '';
        };
      };
    })
    // (let
      # we also export a nixos module to allow reconfiguration from configuration.nix
      nixosModule = utils.mkNixosModules {
        moduleNamespace = [defaultPackageName];
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
        moduleNamespace = [defaultPackageName];
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
    in {
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

      nixosModules.default = nixosModule;
      homeModules.default = homeModule;

      inherit utils nixosModule homeModule;
      inherit (utils) templates;
    });
}
