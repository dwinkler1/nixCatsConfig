{
  config,
  lib,
  ...
}:
{
  config.cats = {
    customPlugins = lib.mkDefault true;
    external = lib.mkDefault true;
    general = lib.mkDefault true;
    gitPlugins = lib.mkDefault true;
    lua = lib.mkDefault true;
    markdown = lib.mkDefault true;
    nix = lib.mkDefault true;
    python = lib.mkDefault true;
    r = lib.mkDefault true;
    utils = lib.mkDefault true;
    test = lib.mkDefault false;
    treesitterParsers = lib.mkDefault true;
  };
}
