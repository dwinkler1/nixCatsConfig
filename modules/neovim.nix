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
    ./module/specs/deps.nix
    ./module/specs/plugins.nix
    ./module/specs/cats-enable.nix
    ./module/settings/core.nix
    ./module/settings/cats.nix
    ./module/settings/env.nix
    ./module/settings/hosts.nix
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


  options.cats = lib.mkOption {
    type = lib.types.attrsOf lib.types.bool;
    description = ''
      Category toggles used to enable/disable specs by name.

      Keys map directly to specs (e.g., `python` controls `specs.python`).
      Set a category to `false` to skip its dependency/plugin specs.

      Available categories:
      - customPlugins: local plugin specs
      - external: external tools and integrations
      - general: core Neovim plugins/features
      - gitPlugins: git-related plugins
      - lua: Lua tooling and LSPs
      - markdown: markdown tooling and plugins
      - nix: Nix tooling and plugins
      - python: Python tooling and plugins
      - r: R tooling and plugins
      - utils: general utilities
      - test: test-only tooling (disabled by default)
      - treesitterParsers: Treesitter parsers
    '';
    default = {
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
    };
  };

  config.settings.cats = config.cats;
  config.info.cats = config.cats;
  config.info.nixCats_config_location = config.settings.config_directory;
  config.info.nixCats_wrapRc = config.settings.wrapRc or false;

  config.info.nixCats_configDirName = "nvim";
}
