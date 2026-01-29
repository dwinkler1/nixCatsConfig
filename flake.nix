# Copyright (c) 2023 BirdeeHub
# Licensed under the MIT license
{
  description = "Daniel's NixCats";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    wrappers.url = "github:BirdeeHub/nix-wrapper-modules";
    wrappers.inputs.nixpkgs.follows = "nixpkgs";
    rixpkgs.url = "https://github.com/rstats-on-nix/nixpkgs/archive/2026-01-19.tar.gz";

    ## Extra R packages
    fran = {
      url = "github:dwinkler1/fran";
      inputs = {
        nixpkgs.follows = "rixpkgs";
      };
    };

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

  outputs =
    {
      self,
      nixpkgs,
      wrappers,
      ...
    }@inputs:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.platforms.all;
      module = nixpkgs.lib.modules.importApply ./modules/neovim.nix inputs;
      wrapper = wrappers.lib.evalModule module;
    in
    {
      overlays = {
        default = final: prev: { neovim = wrapper.config.wrap { pkgs = final; }; };
        neovim = self.overlays.default;
      };
      wrapperModules = {
        default = module;
        neovim = self.wrapperModules.default;
      };
      wrappers = {
        default = wrapper.config;
        neovim = self.wrappers.default;
      };
      packages = forAllSystems (
        system:
        let
          module_pkgs = import nixpkgs {
            inherit system;
            overlays = [
              (final: prev: {
                rpkgs = inputs.rixpkgs.legacyPackages.${prev.stdenv.hostPlatform.system};
              })
              inputs.fran.overlays.default
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
                  ];
                in {
                  quarto = prev.rpkgs.quarto.override {extraRPackages = reqPkgs;};
                  rWrapper = prev.rpkgs.rWrapper.override {packages = reqPkgs;};
                }
              )
              (
                final: prev: let
                  reqPkgs = pyPackages:
                    with pyPackages; [
                      numpy
                    ];
                in {
                  python = prev.python3.withPackages reqPkgs;
                }
              )
              (
                final: prev: {
                  codecompanion-nvim = prev.vimPlugins.codecompanion-nvim.overrideAttrs {
                    checkInputs = with prev.vimPlugins; [
                      blink-cmp
                      mini-nvim
                    ];
                    dependencies = [prev.vimPlugins.plenary-nvim];
                    nvimSkipModules = [
                      "codecompanion.actions.static"
                      "codecompanion.actions.init"
                      "minimal"
                      "codecompanion.providers.actions.fzf_lua"
                      "codecompanion.providers.completion.cmp.setup"
                      "codecompanion.providers.actions.telescope"
                      "codecompanion.providers.actions.snacks"
                    ];
                  };
                  zk-nvim = prev.vimPlugins.zk-nvim.overrideAttrs {
                    nvimSkipModules = [
                      "zk.pickers.fzf_lua"
                    ];
                  };
                }
              )
            ];
          };
        in
        {
          default = wrapper.config.wrap { pkgs = module_pkgs; };
          neovim = self.packages.${system}.default;
        }
      );
    };
}
