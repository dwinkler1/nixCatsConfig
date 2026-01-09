# Agent Operational Guidelines: NixCats Neovim Config

This document defines the operational standards for AI agents working on this NixCats-based Neovim configuration. Adherence to these guidelines ensures reproducibility, maintainability, and stability across the Nix and Lua layers.

## 1. Build, Lint, and Test Commands

This project relies on **Nix** for dependencies and **Lua** for configuration. All environment changes must be reflected in `flake.nix`.

### Build & Environment
- **Build Package:** `nix build .#n` (Builds the default Neovim package)
- **Enter Dev Shell:** `nix develop` (Loads all tools: `lua-language-server`, `stylua`, `alejandra`)
- **Run Neovim:** `nix run .` (Runs the flake-built Neovim cleanly)

### Linting & Formatting
- **Lua Format:** `stylua .` (Standard formatter for all `.lua` files)
- **Nix Format:** `alejandra .` (Standard formatter for all `.nix` files)
- **Lua Lint:** `lua-language-server` (Running in background or via `nix run . -- --check`)
- **Nix Lint:** `nix run nixpkgs#statix check` (Check for Nix anti-patterns)

### Testing
This config uses `busted` or ad-hoc Lua scripts for testing.
- **Run Lua Tests:** `nvim -l tests/init.lua` (if available) or execute specific files: `nvim -l plugin/04_treesitter.lua`
- **Manual Verification:** Open `test.R`, `test.py`, or `test.jl` and verify REPL integration manually.

## 2. Code Style & Conventions

### Architecture: Nix vs. Lua
- **Nix (`flake.nix`):**
  - Defines **all** dependencies (LSPs, formatters, plugins, system tools).
  - **NEVER** use `Mason`, `Lazy.nvim` (auto-install), or `TSInstall` to manage packages. All packages must be declared in `flake.nix`.
  - Use `pkgs.vimPlugins` for Neovim plugins.
  - Use `categoryDefinitions` to group related tools (e.g., `python`, `r`, `gitPlugins`).
- **Lua (`plugin/*.lua`):**
  - Handles configuration **only**.
  - Use `Config.isNixCats` checks when code might run outside Nix (e.g., on a foreign machine), but prioritize Nix-first compatibility.
  - Plugins are loaded via `lze` (Lazy Extensions) or `mini.deps` mechanisms adapted for NixCats.

### Lua Style
- **Formatting:** Use 2 spaces for indentation.
- **Globals:** Avoid global variables. Attach utilities to the `_G.Config` table defined in `init.lua`.
  - *Correct:* `Config.my_util = function() ... end`
  - *Incorrect:* `function MyUtil() ... end`
- **Imports:**
  - Use `local` for all requires.
  - Group standard library requires (`vim.*`) before plugin requires.
  - Use `MiniDeps.later` or `MiniDeps.now` for loading logic.
- **Naming:**
  - `snake_case` for local variables and functions.
  - `PascalCase` for "Class-like" tables or modules (e.g., `M`).
  - Constants should be `UPPER_CASE`.

### Plugin Configuration Pattern
Wrap plugin setups in `MiniDeps.later` to ensure fast startup:
```lua
later(function()
  -- 1. Add command (if not pre-loaded by Nix)
  add("plugin-name")
  -- 2. Setup
  require("plugin").setup({ ... })
end)
```
For NixCats, `add()` is often a no-op but kept for compatibility.

### Error Handling
- Use `pcall` when requiring optional modules or accessing file system paths that might not exist.
- Use `vim.notify("Message", vim.log.levels.ERROR)` for user-facing errors.
- **Fail Gracefully:** If an LSP or tool (e.g., `R`) is missing, the config should not crash; it should degrade functionality silently or with a single warning.

### Data Science Specifics
- **REPLs:** Prioritize `vim-slime` integration.
- **Terminals:** Do not assume a specific shell; use `vim.o.shell`.
- **Paths:** Always use `vim.fn.stdpath('config')` or `vim.fn.getcwd()`. Never hardcode `~/.config/nvim`.

## 3. Workflow Rules
1. **Flake Updates:** If you add a tool in Lua (e.g., `ruff`), you **MUST** add it to `lspsAndRuntimeDeps` in `flake.nix`.
2. **Commit Safety:** Do not commit `flake.lock` unless dependencies were explicitly updated.
3. **Reproducibility:** Prefer pinned versions in `flake.nix` inputs if stability is critical, but general `nixpkgs` tracking is acceptable for this config.
