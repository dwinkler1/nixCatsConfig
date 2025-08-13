local now = MiniDeps.now
local later = MiniDeps.later
local now_if_args = Config.now_if_args
local add = Config.add

-- Mini.nvim
now(function()
  local palette = require('mini.hues').make_palette({
    background = '#fefcf5',
    foreground = '#657b83',
    accent = 'bg',
    saturation = 'high',
    n_hues = 8
  })
  palette.fg_mid2 = "#586e75"
  palette.fg_mid = "#073642"
  palette.bg_edge = "#fdf6e3"
  palette.accent_bg = "#eee8d5"
  require('mini.hues').apply_palette(palette)
end)

now(function()
  require("mini.basics").setup({
    options = {
      basic = true,
      extra_ui = true
    },
    mappings = {
      -- jk linewise, gy/gp system clipboard, gV select last change/yank
      basic = true,
      -- <C-hjkl> move between windows, <C-arrow> resize
      windows = true,
      move_with_alt = true,
      option_toggle_prefix = "<leader>u"
    },
    autocommands = {
      basic = true,
      relnum_in_visual_mode = true
    },
  })
end)

now(function()
  require("mini.icons").setup({
    use_file_extension = function(ext, _)
      local suf3, suf4 = ext:sub(-3), ext:sub(-4)
      return suf3 ~= "scm" and suf3 ~= "txt" and suf3 ~= "yml" and suf4 ~= "json" and suf4 ~= "yaml"
    end,
  })
  later(MiniIcons.mock_nvim_web_devicons)
  later(MiniIcons.tweak_lsp_kind)
end)

now(function()
  local predicate = function(notif)
    if not (notif.data.source == "lsp_progress" and notif.data.client_name == "lua_ls") then
      return true
    end
    -- Filter out some LSP progress notifications from 'lua_ls'
    return notif.msg:find("Diagnosing") == nil and notif.msg:find("semantic tokens") == nil
  end
  local custom_sort = function(notif_arr)
    return MiniNotify.default_sort(vim.tbl_filter(predicate, notif_arr))
  end

  require("mini.notify").setup({ content = { sort = custom_sort } })
  vim.notify = MiniNotify.make_notify()
end)


now(function()
  require("mini.sessions").setup()
end)

now(function()
  local starter = require("mini.starter")
  starter.setup({
    evaluate_single = true,
    items = {
      starter.sections.recent_files(5, true),
      function()
        local section = Config.startup.get_recent_files_by_ft_or_ext({
          "r",
          "sql",
          "julia",
          "python",
          "lua",
        })
        return section
      end,
      starter.sections.pick(),
      starter.sections.sessions(5, true),
      starter.sections.builtin_actions(),
      starter.sections.recent_files(3, false),
    },
    footer = Config.startup.footer_text,
    content_hooks = {
      starter.gen_hook.adding_bullet(),
      starter.gen_hook.indexing(
        "all",
        { "Builtin actions", "Recent files (current directory)", "Recent files", }
      ),
      starter.gen_hook.aligning("center", "center"),
      starter.gen_hook.padding(3, 2),
    },
  })
end)

now(function()
  require("mini.statusline").setup()
end)

now(function()
  require("mini.tabline").setup()
end)


now(function()
  local miniclue = require("mini.clue")
  --stylua: ignore
  miniclue.setup({
    window = {
      config = {
        width = 'auto'
      },
      delay = 100,
    },
    clues = {
      Config.leader_group_clues,
      miniclue.gen_clues.builtin_completion(),
      miniclue.gen_clues.g(),
      miniclue.gen_clues.marks(),
      miniclue.gen_clues.registers(),
      miniclue.gen_clues.windows({ submode_resize = true, submode_move = true }),
      miniclue.gen_clues.z(),
    },
    triggers = {
      { mode = 'n', keys = '<Leader>' },      -- Leader triggers
      { mode = 'n', keys = '<LocalLeader>' }, -- LocalLeader triggers
      { mode = 'x', keys = '<Leader>' },
      { mode = 'n', keys = [[\]] },           -- mini.basics
      { mode = 'n', keys = '[' },             -- mini.bracketed
      { mode = 'n', keys = ']' },
      { mode = 'x', keys = '[' },
      { mode = 'x', keys = ']' },
      { mode = 'i', keys = '<C-x>' }, -- Built-in completion
      { mode = 'n', keys = 'g' },     -- `g` key
      { mode = 'x', keys = 'g' },
      { mode = 'n', keys = "'" },     -- Marks
      { mode = 'n', keys = '`' },
      { mode = 'x', keys = "'" },
      { mode = 'x', keys = '`' },
      { mode = 'n', keys = '"' }, -- Registers
      { mode = 'x', keys = '"' },
      { mode = 'i', keys = '<C-r>' },
      { mode = 'c', keys = '<C-r>' },
      { mode = 'n', keys = '<C-w>' }, -- Window commands
      { mode = 'n', keys = 'z' },     -- `z` key
      { mode = 'x', keys = 'z' },
    },
  })
end)

-- Treesitter
now_if_args(function()
  require("nvim-treesitter.configs").setup({
    auto_install = false,
    highlight = { enable = true },
    indent = { enable = false },
    parser_configurations = {
      markdown = {
        filetypes = { "markdown", "copilot-chat" },
      },
    },
  })
end)

-- zk
now_if_args(function()
  require("zk").setup({
    picker = "minipick",
    lsp = {
      -- `config` is passed to `vim.lsp.start_client(config)`
      config = {
        cmd = { "zk", "lsp" },
        name = "zk",
        -- on_attach = ...
        -- etc, see `:h vim.lsp.start_client()`
      },

      -- automatically attach buffers in a zk notebook that match the given filetypes
      auto_attach = {
        enabled = true,
        filetypes = { "markdown" },
      },

    },
  })
end)
