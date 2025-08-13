local now_if_args = Config.now_if_args
local add = Config.add

now_if_args(function()
  -- Enable LSP only on Neovim>=0.11 as it introduced `vim.lsp.config`
  if vim.fn.has("nvim-0.11") == 0 then
    return
  end

  -- All language servers are expected to be installed with 'mason.vnim'
  vim.lsp.enable({
    "clangd",
    --    "nushell",
    "pyright",
    "rust_analyzer",
    "r_language_server",
    --    "marksman",
    "lua_ls",
    "julials",
  })

  local lspconfig = require("lspconfig")
  --  local capabilities = require("blink.cmp").get_lsp_capabilities({}, true)
  local lsp_flags = {
    allow_incremental_sync = true,
    -- debounce_text_changes = 150,
  }
  vim.lsp.config('*', {
    -- capabilities = capabilities,
    flags = lsp_flags
  })
  vim.lsp.config('r_language_server', {
    filetypes = { 'r', 'rmd', 'rmarkdown' },
    settings = {
      ['r_language_server'] = {
        lsp = {
          rich_documentation = true,
          enable = true,
        },
      },
    }
  })
  vim.lsp.config('julials', {
    settings = {
      julia = {
        format = {
          indent = 2,
        },
        lsp = {
          autoStart = true,
          provideFormatter = true,
        },
      },
    },
  })

  vim.lsp.config('marksman', {
    filetypes = { "markdown", "markdown_inline", "codecompanion" },
  })
  vim.lsp.config('lua_ls', {
    settings = {
      Lua = {
        completion = {
          callSnippet = "Replace",
        },
        runtime = {
          version = "LuaJIT",
          -- plugin = lua_plugin_paths, -- handled by lazydev
        },
        diagnostics = {
          disable = { "trailing-space" },
        },
        workspace = {
          -- library = lua_library_files, -- handled by lazydev
          checkThirdParty = false,
        },
        doc = {
          privateName = { "^_" },
        },
        telemetry = {
          enable = false,
        },
      },
    },
  })
end)
