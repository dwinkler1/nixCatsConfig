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
      supportedSystems = [
        "aarch64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      module = nixpkgs.lib.modules.importApply ./modules/neovim.nix inputs;
      packageOverlays = [
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
    in
    {
      overlays = {
        default = final: prev: { neovim = self.packages.${final.system}.default; };
        neovim = self.overlays.default;
      };
      wrapperModules = {
        default = module;
        neovim = self.wrapperModules.default;
      };
      wrappers = forAllSystems (
        system:
        let
          pkgsWithOverlays = import nixpkgs {
            inherit system;
            overlays = packageOverlays;
          };
          wrapper = wrappers.lib.evalModule [ module { pkgs = pkgsWithOverlays; } ];
        in
        {
          default = wrapper.config;
          neovim = self.wrappers.${system}.default;
        }
      );
      packages = forAllSystems (
        system:
        let
          pkgsWithOverlays = import nixpkgs {
            inherit system;
            overlays = packageOverlays;
          };
          wrapper = wrappers.lib.evalModule [ module { pkgs = pkgsWithOverlays; } ];
        in
        {
          default = wrapper.config.wrap { pkgs = pkgsWithOverlays; };
          neovim = self.packages.${system}.default;
        }
      );
      formatter = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        pkgs.nixfmt-tree
      );
      devShells = forAllSystems (
        system:
        let
          pkgsWithOverlays = import nixpkgs {
            inherit system;
            overlays = packageOverlays;
          };
        in
        {
          default = pkgsWithOverlays.mkShell {
            name = "n";
            packages = [ self.packages.${system}.default ];
            nativeBuildInputs = with pkgsWithOverlays; [ devenv ];
            inputsFrom = [];
            shellHook = "";
          };
        }
      );
      checks = forAllSystems (
        system:
        let
          pkgsWithOverlays = import nixpkgs {
            inherit system;
            overlays = packageOverlays;
          };
          defaultPackage = self.packages.${system}.default;
        in
        {
          default = defaultPackage;
          package-build = pkgsWithOverlays.runCommand "check-n" {} ''
            BINARY_PATH="${defaultPackage}/bin/n"

            if [ ! -x "$BINARY_PATH" ]; then
              echo "Error: Binary n not found or not executable"
              exit 1
            fi

            "$BINARY_PATH" --version > version_output.txt 2>&1 || true

            echo "Package validation successful" > $out
            echo "Binary location: $BINARY_PATH" >> $out
            if [ -s version_output.txt ]; then
              echo "Version output:" >> $out
              cat version_output.txt >> $out
            fi
          '';
        }
      );
    };
}
