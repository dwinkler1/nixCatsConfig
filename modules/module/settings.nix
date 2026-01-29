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

  config.hosts = {
    node.nvim-host.enable = true;
    perl.nvim-host.enable = true;
    python3.nvim-host.enable = true;
    ruby.nvim-host.enable = true;
    neovide.nvim-host.enable = true;
    m = {
      nvim-host.enable = false;
      nvim-host.package = pkgs.uv;
      nvim-host.exePath = "bin/uv";
      nvim-host.argv0 = "uv";
      nvim-host.addFlag = [
        "run"
        "marimo"
        "edit"
      ];
    };
    jl = {
      nvim-host.enable = true;
      nvim-host.package = pkgs.julia-bin;
      nvim-host.exePath = "bin/julia";
      nvim-host.argv0 = "julia";
      nvim-host.addFlag = [
        "--project=@."
      ];
    };
    r = {
      nvim-host.enable = true;
      nvim-host.package = pkgs.rWrapper;
      nvim-host.exePath = "bin/R";
      nvim-host.argv0 = "R";
      nvim-host.addFlag = [
        "--no-save"
        "--no-restore"
      ];
    };
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
