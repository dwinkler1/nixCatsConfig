[![Flake build](https://github.com/dwinkler1/nixCatsConfig/actions/workflows/check.yml/badge.svg)](https://github.com/dwinkler1/nixCatsConfig/actions/workflows/check.yml)

## Migration plan: nix-wrapper-modules

Use this plan to move the current `flake.nix` config onto the new
`nix-wrapper-modules` Neovim module template:
https://github.com/BirdeeHub/nix-wrapper-modules/blob/main/templates/neovim/module.nix

1. **Add the wrapper module input**
   - Add `nix-wrapper-modules` (or `wrapper-lib`) to `inputs` in `flake.nix`.
   - Keep existing inputs (`nixCats`, `nixpkgs`, plugins, overlays) during the
     migration so the plugin sources and overlays stay available.
2. **Create a Neovim module file (new)**
   - Add a new module file (for example `modules/neovim.nix`) and start by
     copying the template file from the wrapper module repo.
   - Set `config.settings.config_directory = ./.;` so the module points to this
     repo’s `init.lua`/`plugin/` setup.
3. **Move plugin and package groups into specs**
   - Map `categoryDefinitions.startupPlugins.*` and
     `categoryDefinitions.optionalPlugins.*` into `config.specs.<name>.data`
     blocks (the template shows list specs and single plugin specs).
   - Convert `lspsAndRuntimeDeps.*` into `extraPackages` fields on the matching
     specs (for example `specs.python.extraPackages = [...]`).
   - Carry over custom overlays (R/Python overrides) in the module by
     referencing the same `pkgs` and overlay inputs in `flake.nix`.
4. **Move settings + environment variables**
   - Translate `packageDefinitions.<name>.settings` into `config.settings`
     (e.g., `wrapRc`, `autowrapRuntimeDeps`, `aliases`, host configs).
   - Move `categoryDefinitions.environmentVariables` into
     `config.settings.environmentVariables`.
   - Translate `categoryDefinitions.extraWrapperArgs` into
     `config.settings.extraWrapperArgs` (or the wrapper module equivalent).
5. **Recreate category toggles**
   - Replace `packageDefinitions.<name>.categories` with `config.specs.<name>.enable`
     toggles or add a `config.settings.cats` map and use it to enable/disable
     specs (the template’s `settings.cats` option shows the pattern).
6. **Wire outputs to the wrapper module**
   - In `flake.nix` outputs, replace `nixCats.utils.baseBuilder` with the
     wrapper module’s `wlib` builder (see wrapper docs for `packages`,
     `devShells`, and `checks` usage).
   - Expose `nixosModules.default` and `homeModules.default` from the new module
     (mirroring the existing exports).
7. **Validate the migration**
   - Run `nix build .#n`, `nix run .`, and the check workflow equivalents.
   - Confirm `vim` alias, host wrappers, and plugin load ordering match the
     current behavior.
