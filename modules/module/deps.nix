{
  config,
  pkgs,
  lib,
  ...
}:
let
  mk_path_prefix =
    name: paths: lib.optional (paths != [ ]) {
      name = name;
      data = [
        "PATH"
        ":"
        "${lib.makeBinPath paths}"
      ];
    };
in
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

  config.extraPackages = config.specCollect (acc: v: acc ++ (v.extraPackages or [ ])) [ ];

  config.prefixVar = lib.flatten [
    (mk_path_prefix "EXTERNAL_DEPS" (with pkgs; [
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
    ]))
    (mk_path_prefix "MARKDOWN_DEPS" (with pkgs; [
      python313Packages.pylatexenc
      quarto
      zk
    ]))
    (mk_path_prefix "NIX_DEPS" (with pkgs; [
      alejandra
      nix-doc
      nixd
    ]))
    (mk_path_prefix "LUA_DEPS" (with pkgs; [
      lua-language-server
    ]))
    (mk_path_prefix "PYTHON_DEPS" (with pkgs; [
      python
      nodejs
      ruff
      basedpyright
      uv
    ]))
    (mk_path_prefix "R_DEPS" (with pkgs; [
      rWrapper
      radianWrapper
      quarto
      air-formatter
    ]))
  ];
}
