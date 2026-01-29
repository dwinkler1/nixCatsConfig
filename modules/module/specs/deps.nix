inputs:
{
  config,
  pkgs,
  lib,
  ...
}:
let
  # R package configuration - built from rixpkgs with required R packages
  # Only evaluated when actually referenced (Nix lazy evaluation)
  rixpkgsBase = inputs.rixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  
  # Apply fran overlay to rixpkgs to make custom R packages available
  rixpkgs = rixpkgsBase // (inputs.fran.overlays.default rixpkgsBase rixpkgsBase);
  
  # Standard R packages - custom packages from fran are available in rixpkgs but not used by default
  reqRPkgs = with rixpkgs.rPackages; [
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
  
  buildRPackages = {
    rWrapper = rixpkgs.rWrapper.override { packages = reqRPkgs; };
    radianWrapper = rixpkgs.radianWrapper or (rixpkgs.radian.override { });
    air-formatter = rixpkgs.air-formatter or pkgs.emptyDirectory;
    quarto = rixpkgs.quarto.override { extraRPackages = reqRPkgs; };
  };
in
{
  options.rPackages = lib.mkOption {
    type = lib.types.attrsOf lib.types.package;
    description = "R packages built with configured dependencies. Only built when referenced.";
    default = buildRPackages;
    readOnly = true;
  };

  config.specMods =
    {
      parentSpec ? null,
      ...
    }:
    {
      options.extraPackages = lib.mkOption {
        type = lib.types.listOf lib.types.raw;
        default = [ ];
        description = "extra packages appended to PATH";
      };
      config.runtimeDeps = lib.mkDefault (parentSpec.runtimeDeps or false);
    };

  config.specs.external = {
    data = lib.mkDefault null;
    before = [ "INIT_MAIN" ];
    config = ''
      vim.o.shell = "${pkgs.zsh}/bin/zsh"
    '';
    extraPackages = with pkgs; [
      devenv
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
      man
      perl
      pigz
      poppler
      ripgrep
      ruby
      shfmt
      sqlfluff
      tree-sitter
      wget
      zathura
    ];
  };

  config.specs.markdown = {
    data = lib.mkDefault null;
    extraPackages = with pkgs; [
      python313Packages.pylatexenc
      (if config.cats.r or true then config.rPackages.quarto else rixpkgs.quarto)
      zk
    ];
  };

  config.specs.nix = {
    data = lib.mkDefault null;
    extraPackages = with pkgs; [
      alejandra
      nix-doc
      nixd
    ];
  };

  config.specs.lua = {
    data = lib.mkDefault null;
    extraPackages = with pkgs; [
      lua-language-server
    ];
  };

  config.specs.python = {
    data = lib.mkDefault null;
    extraPackages = with pkgs; [
      python
      nodejs
      ruff
      basedpyright
      uv
    ];
  };

  config.specs.r = lib.mkIf (config.cats.r or true) {
    data = lib.mkDefault null;
    extraPackages = [
      config.rPackages.rWrapper
      config.rPackages.radianWrapper
      config.rPackages.quarto
      config.rPackages.air-formatter
    ];
  };

  config.extraPackages =
    config.specCollect (acc: v: acc ++ lib.optionals (if v ? enable then v.enable else true) (v.extraPackages or [ ])) [ ];
}
