inputs:
{
  config,
  wlib,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    wlib.wrapperModules.neovim
    ./module/deps.nix
    ./module/plugins.nix
    ./module/settings.nix
  ];

  options.nvim-lib.neovimPlugins = lib.mkOption {
    readOnly = true;
    type = lib.types.attrsOf wlib.types.stringable;
    default = config.nvim-lib.pluginsFromPrefix "plugins-" inputs;
  };

  options.nvim-lib.pluginsFromPrefix = lib.mkOption {
    type = lib.types.raw;
    readOnly = true;
    default =
      prefix: inputs:
      lib.pipe inputs [
        builtins.attrNames
        (builtins.filter (s: lib.hasPrefix prefix s))
        (map (
          input:
          let
            name = lib.removePrefix prefix input;
          in
          {
            inherit name;
            value = config.nvim-lib.mkPlugin name inputs.${input};
          }
        ))
        builtins.listToAttrs
      ];
  };

  config.info.nixCats_config_location = config.settings.config_directory;
  config.info.nixCats_wrapRc = config.settings.wrapRc or false;
  config.info.nixCats_configDirName = "nvim";

  config.hosts = {
    node.nvim-host.enable = true;
    perl.nvim-host.enable = true;
    python3.nvim-host.enable = true;
    ruby.nvim-host.enable = true;
    neovide.nvim-host.enable = true;
    m = {
      nvim-host.enable = false;
      nvim-host.package = "${pkgs.uv}/bin/uv";
      nvim-host.argv0 = "uv";
      nvim-host.addFlag = [
        "run"
        "marimo"
        "edit"
      ];
    };
    jl = {
      nvim-host.enable = true;
      nvim-host.package = "${pkgs.julia-bin}/bin/julia";
      nvim-host.argv0 = "julia";
      nvim-host.addFlag = [
        "--project=@."
      ];
    };
    r = {
      nvim-host.enable = true;
      nvim-host.package = "${pkgs.rWrapper}/bin/R";
      nvim-host.argv0 = "R";
      nvim-host.addFlag = [
        "--no-save"
        "--no-restore"
      ];
    };
  };
}
