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
    ./module/hosts.nix
  ];

  options.nvim-lib.neovimPlugins = lib.mkOption {
    readOnly = true;
    type = lib.types.attrsOf wlib.types.stringable;
    default = config.nvim-lib.pluginsFromPrefix "plugins-" inputs;
  };

  config.info.nixCats_config_location = config.settings.config_directory;
  config.info.nixCats_wrapRc = config.settings.wrapRc or false;
  config.info.nvimLuaEnv = config.settings.nvim_lua_env;
  config.info.nixCats_configDirName = "nvim";
}
