[![Flake build](https://github.com/dwinkler1/nixCatsConfig/actions/workflows/check.yml/badge.svg)](https://github.com/dwinkler1/nixCatsConfig/actions/workflows/check.yml)

## How to extend this config

This repo is designed to be reused downstream via `nix-wrapper-modules`.

1. Import the wrapper module from `modules/neovim.nix`.
2. Use the overlay helpers in `overlays/default.nix` to compose your own overlays.
3. Override or add specs by name (e.g., `specs.python`, `specs.r`).

Minimal downstream approach:
- Use the exported wrapper module: `wrapperModules.default`
- Compose overlays: `overlays.default` or individual `rOverlay`, `pythonOverlay`, `pluginsOverlay`
- Add extra packages via spec overrides (e.g., extend `specs.python.extraPackages`)

### Minimal downstream flake example (with spec override)

```/dev/null/flake.nix#L1-52
{
  description = "Downstream Neovim config using nix-wrapper-modules";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    upstream.url = "path:../13.04_nixCats";
  };

  outputs = { self, nixpkgs, upstream, ... }:
    let
      system = "aarch64-darwin";
      overlayDefs = import upstream/overlays inputs;

      # Override specs by extending the upstream module
      module = { config, pkgs, lib, ... }: {
        imports = [ upstream.wrapperModules.default ];

        # Example: add extra Python tooling
        specs.python.extraPackages = (config.specs.python.extraPackages or [ ]) ++ [
          pkgs.python313Packages.ipython
        ];
      };

      wrapper = upstream.wrappers.default;
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ overlayDefs.default ];
      };
    in {
      packages.${system}.default = wrapper.wrap { inherit pkgs; };

      nixosModules.default = module;
      homeModules.default = module;
    };
}
```

### Downstream example using wrappers.lib.evalModule

```/dev/null/flake.nix#L1-58
{
  description = "Downstream Neovim config using evalModule";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    wrappers.url = "github:BirdeeHub/nix-wrapper-modules";
    upstream.url = "path:../13.04_nixCats";
  };

  outputs = { self, nixpkgs, wrappers, upstream, ... }:
    let
      system = "aarch64-darwin";
      overlayDefs = import upstream/overlays inputs;

      module = nixpkgs.lib.modules.importApply upstream/modules/neovim.nix inputs;
      wrapper = wrappers.lib.evalModule module;

      pkgs = import nixpkgs {
        inherit system;
        overlays = [ overlayDefs.default ];
      };
    in {
      packages.${system}.default = wrapper.config.wrap { inherit pkgs; };
    };
}
```

### Downstream example with cats and settings overrides

```/dev/null/flake.nix#L1-68
{
  description = "Downstream Neovim config with cats/settings overrides";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    upstream.url = "path:../13.04_nixCats";
  };

  outputs = { self, nixpkgs, upstream, ... }:
    let
      system = "aarch64-darwin";
      overlayDefs = import upstream/overlays inputs;

      module = { config, pkgs, lib, ... }: {
        imports = [ upstream.wrapperModules.default ];

        # Disable categories you don't want
        cats = {
          r = false;
          test = false;
        };

        # Override settings (example: colorscheme/background)
        settings.colorscheme = "kanagawa";
        settings.background = "dark";
      };

      wrapper = upstream.wrappers.default;
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ overlayDefs.default ];
      };
    in {
      packages.${system}.default = wrapper.wrap { inherit pkgs; };
      nixosModules.default = module;
      homeModules.default = module;
    };
}
```

### EvalModule example with cats/settings overrides

```/dev/null/flake.nix#L1-74
{
  description = "Downstream Neovim config using evalModule with overrides";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    wrappers.url = "github:BirdeeHub/nix-wrapper-modules";
    upstream.url = "path:../13.04_nixCats";
  };

  outputs = { self, nixpkgs, wrappers, upstream, ... }:
    let
      system = "aarch64-darwin";
      overlayDefs = import upstream/overlays inputs;

      baseModule = nixpkgs.lib.modules.importApply upstream/modules/neovim.nix inputs;
      module = { config, pkgs, lib, ... }: {
        imports = [ baseModule ];

        cats = {
          r = false;
          test = false;
        };

        settings.colorscheme = "kanagawa";
        settings.background = "dark";
      };

      wrapper = wrappers.lib.evalModule module;

      pkgs = import nixpkgs {
        inherit system;
        overlays = [ overlayDefs.default ];
      };
    in {
      packages.${system}.default = wrapper.config.wrap { inherit pkgs; };
    };
}
```

### Home Manager usage example

```/dev/null/home.nix#L1-26
{ pkgs, inputs, ... }:
let
  overlayDefs = import inputs.upstream/overlays inputs;
  nvimPkg = inputs.upstream.wrappers.default.wrap { inherit pkgs; };
in
{
  nixpkgs.overlays = [ overlayDefs.default ];

  home.packages = [ nvimPkg ];

  # Or import the provided Home Manager module:
  # imports = [ inputs.upstream.homeModules.default ];
}
```

## Category semantics (cats)

Categories are the top-level toggles that enable or disable specs by name.
They map directly to `config.specs.<name>.enable`.

Available categories and intent:
- `customPlugins`: local plugin specs
- `external`: external tools and integrations
- `general`: core Neovim plugins/features
- `gitPlugins`: git-related plugins
- `lua`: Lua tooling and LSPs
- `markdown`: markdown tooling and plugins
- `nix`: Nix tooling and plugins
- `python`: Python tooling and plugins
- `r`: R tooling and plugins
- `utils`: general utilities
- `test`: test-only tooling (disabled by default)
- `treesitterParsers`: Treesitter parsers

## Migration plan: nix-wrapper-modules

Use this plan to move the current `flake.nix` config onto the new
`nix-wrapper-modules` Neovim module template:
https://github.com/BirdeeHub/nix-wrapper-modules/blob/main/templates/neovim/module.nix

1. **Add the wrapper module input**
   - Add `nix-wrapper-modules` (or `wrapper-lib`) to `inputs` in `flake.nix`.
   - Keep existing inputs (`nixCats`, `nixpkgs`, plugins, overlays) during the
     migration so the plugin sources and overlays stay available.
2. **Create a Neovim module file (new)**
   - Add a new module file (e.g., `modules/neovim.nix`) and start by
     copying the template file from the wrapper module repo.
   - Set `config.settings.config_directory = ./.;` so the module points to this
     repo’s `init.lua`/`plugin/` setup.
3. **Move plugin and package groups into specs**
   - Map `categoryDefinitions.startupPlugins.*` and
     `categoryDefinitions.optionalPlugins.*` into `config.specs.<name>.data`
     blocks (the template shows list specs and single plugin specs).
   - Convert `lspsAndRuntimeDeps.*` into `extraPackages` fields on the matching
     specs (e.g., `specs.python.extraPackages = [...]`).
   - Carry over custom overlays (R/Python overrides) in the module by
     referencing the same `pkgs` and overlay inputs in `flake.nix`.
4. **Move settings + environment variables**
   - Translate `packageDefinitions.<name>.settings` into `config.settings`
     (e.g., `wrapRc`, `autowrapRuntimeDeps`, `aliases`, host configs).
   - Move `categoryDefinitions.environmentVariables` into
     `config.settings.environmentVariables`.
   - Translate `categoryDefinitions.extraWrapperArgs` into the makeWrapper
     options (`config.addFlag`, `config.appendFlag`, `config.prefixVar`,
     `config.suffixVar`) defined in
     https://github.com/BirdeeHub/nix-wrapper-modules/blob/main/modules/makeWrapper/module.nix.
5. **Recreate category toggles**
   - Replace `packageDefinitions.<name>.categories` with `config.specs.<name>.enable`
     toggles or add a `config.settings.cats` map and use it to enable/disable
     specs (the template’s `config.settings.cats` option shows the pattern).
6. **Wire outputs to the wrapper module**
   - In `flake.nix` outputs, replace `nixCats.utils.baseBuilder` with the
     wrapper module’s `wlib` builder (see the template flake at
     https://github.com/BirdeeHub/nix-wrapper-modules/blob/main/templates/neovim/flake.nix
     for `packages`, `devShells`, and `checks` usage).
   - Expose `nixosModules.default` and `homeModules.default` from the new module
     (mirroring the existing exports).
7. **Validate the migration**
   - Run `nix build .#n`, `nix run .`, and the check workflow equivalents.
   - Confirm `vim` alias, host wrappers, and plugin load ordering match the
     current behavior.
