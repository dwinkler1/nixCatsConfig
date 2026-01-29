{
  config,
  pkgs,
  lib,
  ...
}:
{
  config.settings.config_directory = ./.;
  config.settings.colorscheme = "kanagawa";
  config.settings.background = "dark";
  config.settings.wrapRc = true;
  config.settings.autowrapRuntimeDeps = "prefix";
  config.settings.aliases = [ "vim" ];
  config.settings.cats = {
    customPlugins = true;
    external = true;
    general = true;
    gitPlugins = true;
    lua = true;
    markdown = true;
    nix = true;
    python = true;
    r = true;
    utils = true;
    test = false;
    treesitterParsers = true;
    background = "dark";
    colorscheme = "kanagawa";
  };

  config.env = {
    R_LIBS_USER = "./.Rlibs";
    UV_PYTHON_DOWNLOADS = "never";
    UV_PYTHON = pkgs.python.interpreter;
    TESTVAR = "It worked!";
  };
  config.envDefault = {
    TESTVAR2 = "It worked again!";
  };


  config.settings.environmentVariables = {
    r = {
      R_LIBS_USER = "./.Rlibs";
    };
    python = {
      UV_PYTHON_DOWNLOADS = "never";
      UV_PYTHON = pkgs.python.interpreter;
    };
    test = {
      TESTVAR = "It worked!";
    };
  };
}
