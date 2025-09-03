local now = MiniDeps.now
local now_if_args = Config.now_if_args
local later = MiniDeps.later
local add = Config.add

if not Config.isNixCats then
  local m_add = MiniDeps.add

  now(function()
    m_add({ source = "R-nvim/R.nvim" })
  end)

  now_if_args(function()
    m_add({ source = "jmbuhr/otter.nvim" })
  end)

  later(function()
    m_add({ source = "jpalardy/vim-slime" })
  end)
end

-- terminal
later(function()
  vim.g.slime_target = "neovim"
  vim.g.slime_no_mappings = true
  add("vim-slime")
  vim.g.slime_cell_delimiter = "# %%"
  vim.g.slime_bracketed_paste = true
  vim.g.slime_input_pid = true
  vim.g.slime_suggest_default = true
  --vim.g.slime_menu_config = false
  vim.g.slime_neovim_ignore_unlisted = false
  vim.keymap.set("v", "<CR>", "<Plug>SlimeRegionSend", { noremap = true })
  vim.keymap.set("v", "<localleader><localleader>", "<Plug>SlimeRegionSend", { noremap = true })
  vim.keymap.set("n", "<localleader><localleader>", "<Plug>SlimeLineSend", { noremap = true })
end)

-- r
now(function()
  if nixCats('gitPlugins') then
    vim.g.rout_follow_colorscheme = true
    local r = require("r")
    r.setup({
      -- Create a table with the options to be passed to setup()
      R_args = { "--quiet", "--no-save" },
      auto_start = "no",
      objbr_auto_start = false,
      objbr_place = 'console,below',
      rconsole_width = 120,
      min_editor_width = 80,
      rconsole_height = 20,
      nvimpager = "split_h",
      hook = {
        on_filetype = function()
          -- This function will be called at the FileType event
          -- of files supported by R.nvim. This is an
          -- opportunity to create mappings local to buffers.

          -- Use specific comment headers

          vim.bo.comments = [[:#',:####,:###,:##,:#]]
          -- Keybindings
          vim.keymap.set("n", "<Enter>", "<Plug>RDSendLine", { buffer = true })
          vim.keymap.set("v", "<Enter>", "<Plug>RSendSelection", { buffer = true })
          vim.keymap.set(
            "i",
            "--",
            "<Cmd>lua MiniTrailspace.trim()<CR><Plug>RInsertAssign",
            { buffer = true, noremap = true }
          )
          vim.keymap.set(
            "i",
            ";;",
            "<Cmd>lua MiniTrailspace.trim()<CR><Plug>RInsertPipe<CR>",
            { buffer = true, noremap = true }
          )
          local r_clues = {
            { mode = "n", keys = "<localleader>a", desc = "+batch" },
            { mode = "n", keys = "<localleader>b", desc = "+between/debug" },
            { mode = "n", keys = "<localleader>c", desc = "+substitute" },
            { mode = "n", keys = "<localleader>f", desc = "+functions" },
            { mode = "n", keys = "<localleader>i", desc = "+install" },
            { mode = "n", keys = "<localleader>k", desc = "+knit" },
            { mode = "n", keys = "<localleader>p", desc = "+paragraph" },
            { mode = "n", keys = "<localleader>r", desc = "+regular" },
            { mode = "n", keys = "<localleader>s", desc = "+selection" },
            { mode = "n", keys = "<localleader>t", desc = "+dput" },
            { mode = "n", keys = "<localleader>u", desc = "+undebug" },
          }
          vim.b.miniclue_config = {
            clues = {
              r_clues,
            },
            triggers = {
              { mode = "n", keys = "<localleader>", desc = "+R" },
            },
          }
        end,
      },
      pdfviewer = "zathura",
    })
  end
end)


-- Quarto
now(function()
  vim.treesitter.language.register("markdown", { "quarto", "rmd" })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "quarto" },
    callback = function()
      require("otter").activate()
    end,
  })

  require("otter").setup({
    lsp = {
      diagnostic_update_events = { "BufWritePost", "InsertLeave" },
    },
    buffers = {
      set_filetype = true,
      write_to_disk = true,
    },
  })
end)

later(function()
  require("quarto").setup({
    lspFeatures = {
      enabled = true,
      languages = { "r", "python", "julia" },
      diagnostics = {
        enabled = true,
        triggers = { "BufWrite" },
      },
      completion = {
        enabled = true,
      },
    },
    codeRunner = {
      enabled = true,
      default_method = "slime",
    },
  })
end)
