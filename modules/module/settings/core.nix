{
  config,
  lib,
  ...
}:
{
  config.settings.config_directory = ../../..;
  config.settings.colorscheme = "kanagawa";
  config.settings.background = "dark";
  config.settings.wrapRc = true;
  config.settings.nvim_lua_env = lp:
    lib.optionals (config.cats.general or false) [ lp.tiktoken_core ];
  config.binName = "n";
  config.settings.block_normal_config = true;
  config.settings.dont_link = false;
  config.settings.aliases = [ "vim" ];
}
