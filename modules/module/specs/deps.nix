inputs:
{
  config,
  pkgs,
  lib,
  ...
}:
{
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
      quarto
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

  config.specs.python = lib.mkIf (config.cats.python or true) {
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
    extraPackages = with pkgs; [
      rWrapper
      radianWrapper
      quarto
      air-formatter
    ];
  };

  config.specs.julia = lib.mkIf (config.cats.julia or true) {
    data = lib.mkDefault null;
    extraPackages = with pkgs; [
      # Julia with base packages
      julia-bin
      # Add additional Julia packages like this:
      # (julia-bin.withPackages [
      #   "DataFrames"
      #   "Plots"
      #   "CSV"
      # ])
    ];
  };

  config.specs.clickhouse = lib.mkIf (config.cats.clickhouse or true) {
    data = lib.mkDefault null;
    extraPackages = with pkgs; [
      clickhouse
    ];
  };

  config.extraPackages =
    config.specCollect (acc: v: acc ++ lib.optionals (if v ? enable then v.enable else true) (v.extraPackages or [ ])) [ ];
}
