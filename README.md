# Cheatsheet

## Helpers

|  key |  action |
| :---  | :--- | 
| (i) <C-space> | trigger auto-completion |
| (i) <C-e> | close auto-completion |
| (n) \<leader\>sk | search keymaps |
| (n) \<leader\>sh | search help |
| (n) \<leader\>U | Undo-tree |
| (n) \<leader\>su | Search Undo-tree (Snacks) |

## Surround

|  key |  action |
| :---  | :--- | 
|  sa{motion}{char} | surround with {char} |
|  sr{char1}{char2} | change surround from {char1} to {char2} |
|  sd{char} | delete surround {char} |
|  sf{char} | find surround {char} |
|  sF{char} | find surround {char} backward |

Note: 's' is set to \<Nop\> when `mini.surround` is loaded use `cl`

## Search

|  key |  action |
| :---  | :--- | 
| \<leader\>sb | search buffers |
| \<leader\>sf | search files |
| \<leader\>sg | grep files |
| \<leader\>sd | search diagnostics |
| \<leader\>sr | search resume |
| \<leader\>sw | search word under cursor / in selection |
| \<leader\>sk | search keymaps |
| \<leader\>sh | search help |
| \<leader\>sm | search marks (Snacks) |
| \<leader\>s. | search recent files |
| \<leader\>ss | search telescope |
| \<leader\>su | Search Undo-tree (Snacks) |
| \<leader\>ds | search document symbols (lsp) |
| \<leader\>ws | search workspace symbols (lsb) |

## Within Buffer Movement

|  key |  action |
|:---  | :--- | 
| \<C-d\> | scroll down (C = super on mac for me) |
| \<C-u\> | scroll up (C = super on mac for me) |
| ]d | next diagnostic (lsp) |
| [d | prev diagnostic (lsp) |
| ]c | next git change hunk |
| [c | prev git change hunk |
| gs | leap search (type first 2 chars and Symbol shown) | 
 

## Between Buffer Movement

|  key |  action |
| :---  | :--- | 
| \<leader\>bb | last buffer |
| \<leader\>b] | next buffer |
| \<leader\>b[ | prev buffer |
| \<leader\>bd | delete buffer (Snacks) |
| \<leader\>bo | delete other buffer (Snacks) |
| \<leader\>bs / <leader>, | search buffers (Telescop / Snacks) |

## Window Movement

|  key |  action |
| :---  | :--- | 
| gS | leap search (type first 2 chars and Symbol shown) | 

## Window Management


|  key |  action |
| :---  | :--- | 
| \<leader\>wh/j/k/l | move to h/j/k/l window |
| \<leader\>wd | delete window |
| \<leader\>wo | delete other window(s) |
| \<leader\>_ | Split below |
| \<leader\>\| | split right |

# Example `nixCats` Configuration

This directory contains an example of the suggested, idiomatic way to manage a neovim configuration using `nixCats`. It leverages [`lze`](https://github.com/BirdeeHub/lze) for lazy loading, although [`lz.n`](https://github.com/nvim-neorocks/lz.n) can be used instead to similar effect. It also includes a fallback mechanism using `paq` and `mason`, allowing you to load the directory without `nix` if needed.

This setup serves as a strong starting point for a `Neovim` configuration—think of it as `kickstart.nvim`, but using `nixCats` **instead of** `lazy.nvim` and `mason`, rather than in addition to them. It also follows a modular approach, spreading the configuration across multiple files rather than consolidating everything into one.

While this is not a "perfect" configuration, nor does it claim to be, it is **a well-structured, recommended way to use `nixCats`**. You are encouraged to customize it to fit your needs. `nixCats` itself is just the `nix`-based package manager, along with its associated [Lua plugin](https://nixcats.org/nixCats_plugin.html).

## Why Use This Approach?

Using `nixCats` in this way provides a **simpler, more transparent** experience compared to solutions like `lazy.nvim`, which hijack normal plugin loading.

It leverages the normal packpath methods of loading plugins both at startup and lazily, allowing you to know what is going on behind the scenes.

It avoids duplicating functionality between nix and other nvim based download managers, avoiding compatibility issues.

You can still have a config that works without nix using this method if desired without undue difficulty.

## Directory Structure

This configuration primarily uses the following directory structure:

- The `lua/` directory for core configurations.
- The `after/plugin/` directory to demonstrate compatibility.

While this structure works well, you are encouraged to further modularize your setup by utilizing any of the runtime directories checked by Neovim:

- `ftplugin/` for file-type-specific configurations.
- `plugin/` for global plugin configurations.
- Even `pack/*/{start,opt}/` work if you want to make a plugin inside your configuration.
- And so on...

If you are unfamiliar with the above, refer to the [Neovim runtime path documentation](https://neovim.io/doc/user/options.html#'rtp').

---

> "Idiomatic" here means:
>
> - This configuration does **not** use `lazy.nvim`, and does not use `mason.nvim` when nix is involved.
> - `nixCats` is responsible for downloading all plugins.
> - Plugins are only loaded if their respective category is enabled.
> - The [Lua utilities template](https://github.com/BirdeeHub/nixCats-nvim/tree/main/templates/luaUtils/lua/nixCatsUtils) is used (see [`:h nixCats.luaUtils`](https://nixcats.org/nixCats_luaUtils.html)).
> - [`lze`](https://github.com/BirdeeHub/lze) or [`lz.n`](https://github.com/nvim-neorocks/lz.n) is used for lazy loading.
