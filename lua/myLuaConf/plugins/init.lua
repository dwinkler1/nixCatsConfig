local colorschemeName = nixCats 'colorscheme'
if not require('nixCatsUtils').isNixCats then
  colorschemeName = 'onedark'
end
-- Could I lazy load on colorscheme with lze?
-- sure. But I was going to call vim.cmd.colorscheme() during startup anyway
-- this is just an example, feel free to do a better job!
vim.cmd.colorscheme(colorschemeName)

local ok, notify = pcall(require, 'notify')
if ok then
  notify.setup {
    on_open = function(win)
      vim.api.nvim_win_set_config(win, { focusable = false })
    end,
  }
  vim.notify = notify
  vim.keymap.set('n', '<Esc>', function()
    notify.dismiss { silent = true }
    vim.cmd { cmd = 'nohlsearch' }
  end, { desc = 'dismiss notify popup and clear hlsearch' })
end

-- NOTE: you can check if you included the category with the thing wherever you want.
if nixCats 'general.extra' then
  -- I didnt want to bother with lazy loading this.
  -- I could put it in opt and put it in a spec anyway
  -- and then not set any handlers and it would load at startup,
  -- but why... I guess I could make it load
  -- after the other lze definitions in the next call using priority value?
  -- didnt seem necessary.

  local function get_current_directory_name()
    local full_path = vim.fn.getcwd()
    local dir_name = string.match(full_path, "[^/]+$")
    return dir_name
  end

  require('mini.sessions').setup()
  -- vim.fn.input('Title: ')
  vim.keymap.set("n", "<leader>ww",
    function() MiniSessions.write(vim.fn.input('Session name:', get_current_directory_name())) end,
    { desc = "Write Session" })

  -- mini.starter

  local my_ministarter = require('myLuaConf.plugins.ministart')
  local recent_files_bytype = function() return my_ministarter.get_recent_files_by_ft_or_ext({ 'r', 'sql', 'julia', 'python' }) end

  local starter = require('mini.starter')
  starter.setup(
    {
      evaluate_single = true,
      items = {
        starter.sections.builtin_actions(),
        starter.sections.recent_files(5, true),
        starter.sections.pick(),
        starter.sections.sessions(5, true),
        recent_files_bytype,
      },
      footer = my_ministarter.footer_text,
      content_hooks = {
        starter.gen_hook.adding_bullet(),
        starter.gen_hook.indexing('all', { 'Builtin actions', 'Recent files (current directory)', 'Recent files' }),
        starter.gen_hook.aligning('center', 'center'),
        starter.gen_hook.padding(3, 2),
      },
    }
  )

  vim.g.loaded_netrwPlugin = 1
  require('oil').setup {
    default_file_explorer = true,
    view_options = {
      show_hidden = true,
    },
    columns = {
      'icon',
      'permissions',
      'size',
      -- "mtime",
    },
    keymaps = {
      ['g?'] = 'actions.show_help',
      ['<CR>'] = 'actions.select',
      ['<C-s>'] = 'actions.select_vsplit',
      ['<C-h>'] = 'actions.select_split',
      ['<C-t>'] = 'actions.select_tab',
      ['<C-p>'] = 'actions.preview',
      ['<C-c>'] = 'actions.close',
      ['<C-l>'] = 'actions.refresh',
      ['-'] = 'actions.parent',
      ['_'] = 'actions.open_cwd',
      ['`'] = 'actions.cd',
      ['~'] = 'actions.tcd',
      ['gs'] = 'actions.change_sort',
      ['gx'] = 'actions.open_external',
      ['g.'] = 'actions.toggle_hidden',
      ['g\\'] = 'actions.toggle_trash',
    },
  }
  vim.keymap.set('n', '-', '<cmd>Oil<CR>', { noremap = true, desc = 'Open Parent Directory' })
  vim.keymap.set('n', '<leader>-', '<cmd>Oil .<CR>', { noremap = true, desc = 'Open nvim root directory' })
  require('r').setup(
    {
      -- Create a table with the options to be passed to setup()
      R_args = { "--quiet", "--no-save" },
      rconsole_width = 120,
      rconsole_height = 25,
      hook = {
        on_filetype = function()
          -- This function will be called at the FileType event
          -- of files supported by R.nvim. This is an
          -- opportunity to create mappings local to buffers.
          vim.keymap.set("n", "<Enter>", "<Plug>RDSendLine", { buffer = true })
          vim.keymap.set("v", "<Enter>", "<Plug>RSendSelection", { buffer = true })

          local wk = require("which-key")
          wk.add({
            buffer = true,
            mode = { "n", "v" },
            { "<localleader>a", group = "all" },
            { "<localleader>b", group = "between marks" },
            { "<localleader>c", group = "chunks" },
            { "<localleader>f", group = "functions" },
            { "<localleader>g", group = "goto" },
            { "<localleader>i", group = "install" },
            { "<localleader>k", group = "knit" },
            { "<localleader>p", group = "paragraph" },
            { "<localleader>q", group = "quarto" },
            { "<localleader>r", group = "r general" },
            { "<localleader>s", group = "split or send" },
            { "<localleader>t", group = "terminal" },
            { "<localleader>v", group = "view" },
          })
        end,
      },
    }
  )
  require("snacks").setup({
    bigfile = { enabled = true },
    dashboard = {
      enabled = false,
      sections = {
        { section = "header" },
        { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
        { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
        { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 }, },
    },
    picker = { enabled = true },
    explorer = { enabled = false, replace_netrw = false }
  })
  vim.keymap.set('n', "<leader>bd", function() Snacks.bufdelete() end, { desc = "Delete Buffer" })
  vim.keymap.set('n', "<leader>bo", function() Snacks.bufdelete.other() end, { desc = "Delete Other Buffer" })
  vim.keymap.set('n', "<leader>tt", function() Snacks.terminal.get() end, { desc = "Open terminal" })
  vim.keymap.set('n', "<leader>to", function() Snacks.terminal.open() end, { desc = "Open new terminal" })
  vim.keymap.set('n', "<leader>tg", function() Snacks.terminal.toggle() end, { desc = "Toggle terminal" })
  --vim.keymap.set('n', "<leader>e", function() Snacks.explorer() end, { desc = "File Explorer" })
  vim.keymap.set('n', "<leader>,", function() Snacks.picker.buffers() end, { desc = "Buffer Explorer" })
  vim.keymap.set('n', "<leader>sm", function() Snacks.picker.marks() end, { desc = "Search Marks" })
  vim.keymap.set('n', "<leader>sz", function() Snacks.picker.man() end, { desc = "Search manual pages" })
  vim.keymap.set('n', "<leader>su", function() Snacks.picker.undo() end, { desc = "Search Undo-tree" })
  vim.keymap.set('n', "<leader>sq", function() Snacks.picker.qflist() end, { desc = "Search Quickfix" })
  vim.keymap.set('n', "<leader>ge", function() Snacks.picker.git_diff() end, { desc = "Search git diff" })
  vim.keymap.set({ 'n', 'v' }, "<leader>gB", function() Snacks.gitbrowse() end, { desc = "Open remote (Browser)" })
  vim.keymap.set('n', "<leader>.", function() Snacks.scratch() end, { desc = "Toggle Scratch Buffer" })

  require('zk').setup({
    picker = 'telescope',
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
    }
  })
  vim.keymap.set('n', "<leader>zo", '<cmd>ZkNotes<CR>', { desc = "Search Zk Note" })
  vim.keymap.set('n', "<leader>zt", '<cmd>Zktags<cr>', { desc = "search zk tags" })
  vim.keymap.set("n", "<leader>zn", "<Cmd>ZkNew { title = vim.fn.input('Title: ') }<CR>")
  vim.keymap.set("n", "<leader>zj", "<Cmd>ZkNew { group = 'journal' }<CR>")
end

require('lze').load {
  { import = 'myLuaConf.plugins.telescope' },
  { import = 'myLuaConf.plugins.treesitter' },
  { import = 'myLuaConf.plugins.completion' },
  {
    'vim-slime',
    for_cat = 'general.extra',
    event = 'DeferredUIEnter',
    load = function(name)
      vim.cmd.packadd(name)
    end,
    before = function()
      vim.g.slime_target = "neovim"
      vim.g.slime_no_mappings = true
    end,
    after = function()
      vim.g.slime_cell_delimiter = "# %%"
      vim.g.slime_bracketed_paste = true
      vim.g.slime_input_pid = true
      vim.g.slime_suggest_default = true
      vim.g.slime_menu_config = true
      vim.g.slime_neovim_ignore_unlisted = false
      vim.keymap.set("v", "<localleader><localleader>", "<Plug>SlimeRegionSend", { noremap = true })
      vim.keymap.set("n", "<localleader><localleader>", "<Plug>SlimeLineSend", { noremap = true })
    end,
  },
  {
    'mini.icons',
    for_cat = 'general.extra',
    dep_of = 'mini.pick',
    after = function(plugin)
      require('mini.icons').setup()
    end,
  },
  {
    'mini.extra',
    for_cat = 'general.extra',
    dep_of = { 'mini.ai', 'mini.pick' },
    after = function(plugin)
      require('mini.extra').setup()
    end,
  },
  {
    'mini.visits',
    for_cat = 'general.extra',
    dep_of = { 'mini.pick' },
    after = function(plugin)
      require('mini.visits').setup()
    end,
  },
  {
    'mini.pick',
    for_cat = 'general.extra',
    event = 'DeferredUIEnter',
    dep_of = 'mini.starter',
    after = function(plugin)
      require('mini.pick').setup()
      vim.keymap.set('n', "<leader>e", function() MiniExtra.pickers.explorer() end, { desc = "File Explorer" })
      vim.keymap.set('n', "<leader>sls", function() MiniExtra.pickers.lsp({ scope = 'document_symbol' }) end,
        { desc = "Search LSP [s]ymbols" })
      vim.keymap.set('n', "<leader>slw", function() MiniExtra.pickers.lsp({ scope = 'workspace_symbol' }) end,
        { desc = "Search LSP [w]orkspace Symbols" })
      vim.keymap.set('n', "<leader>slr", function() MiniExtra.pickers.lsp({ scope = 'references' }) end,
        { desc = "Search LSP [r]eferences" })
      vim.keymap.set('n', "<leader>sld", function() MiniExtra.pickers.lsp({ scope = 'definition' }) end,
        { desc = "Search LSP [d]efinitions" })
    end,
  },
  {
    'mini.surround',
    for_cat = 'general.extra',
    event = 'DeferredUIEnter',
    after = function(plugin)
      require('mini.surround').setup({
        n_lines = 50,
        vim.keymap.set({ "x", "n" }, "s", "<Nop>", { noremap = true })
      })
    end,
  },
  {
    'mini.ai',
    for_cat = 'general.extra',
    event = 'DeferredUIEnter',
    after = function(plugin)
      require('mini.extra').setup()
      require('mini.ai').setup()
    end,
  },
  {
    'mini.pairs',
    for_cat = 'general.extra',
    event = 'DeferredUIEnter',
    after = function(plugin)
      require('mini.pairs').setup()
    end,
  },
  {
    'mini.jump2d',
    for_cat = 'general.extra',
    event = 'DeferredUIEnter',
    after = function(plugin)
      require('mini.jump2d').setup({
        mappings = {
          start_jumping = '<S-CR>',
        },
      })
    end,
  },
  {
    'markdown-preview.nvim',
    -- NOTE: for_cat is a custom handler that just sets enabled value for us,
    -- based on result of nixCats('cat.name') and allows us to set a different default if we wish
    -- it is defined in luaUtils template in lua/nixCatsUtils/lzUtils.lua
    -- you could replace this with enabled = nixCats('cat.name') == true
    -- if you didnt care to set a different default for when not using nix than the default you already set
    for_cat = 'general.markdown',
    cmd = { 'MarkdownPreview', 'MarkdownPreviewStop', 'MarkdownPreviewToggle' },
    ft = 'markdown',
    keys = {
      { '<leader>mp', '<cmd>MarkdownPreview <CR>',       mode = { 'n' }, noremap = true, desc = 'markdown preview' },
      { '<leader>ms', '<cmd>MarkdownPreviewStop <CR>',   mode = { 'n' }, noremap = true, desc = 'markdown preview stop' },
      { '<leader>mt', '<cmd>MarkdownPreviewToggle <CR>', mode = { 'n' }, noremap = true, desc = 'markdown preview toggle' },
    },
    before = function(plugin)
      vim.g.mkdp_auto_close = 0
    end,
  },
  {
    'undotree',
    for_cat = 'general.extra',
    cmd = { 'UndotreeToggle', 'UndotreeHide', 'UndotreeShow', 'UndotreeFocus', 'UndotreePersistUndo' },
    keys = { { '<leader>U', '<cmd>UndotreeToggle<CR>', mode = { 'n' }, desc = 'Undo Tree' } },
    before = function(_)
      vim.g.undotree_WindowLayout = 1
      vim.g.undotree_SplitWidth = 40
    end,
  },
  {
    'comment.nvim',
    for_cat = 'general.extra',
    event = 'DeferredUIEnter',
    after = function(plugin)
      require('Comment').setup()
    end,
  },
  {
    'indent-blankline.nvim',
    for_cat = 'general.extra',
    event = 'DeferredUIEnter',
    after = function(plugin)
      require('ibl').setup()
    end,
  },
  {
    'vim-startuptime',
    for_cat = 'general.extra',
    cmd = { 'StartupTime' },
    before = function(_)
      vim.g.startuptime_event_width = 0
      vim.g.startuptime_tries = 10
      vim.g.startuptime_exe_path = nixCats.packageBinPath
    end,
  },
  {
    'fidget.nvim',
    for_cat = 'general.extra',
    event = 'DeferredUIEnter',
    -- keys = "",
    after = function(plugin)
      require('fidget').setup {}
    end,
  },
  -- {
  --   "hlargs",
  --   for_cat = 'general.extra',
  --   event = "DeferredUIEnter",
  --   -- keys = "",
  --   dep_of = { "nvim-lspconfig" },
  --   after = function(plugin)
  --     require('hlargs').setup {
  --       color = '#32a88f',
  --     }
  --     vim.cmd([[hi clear @lsp.type.parameter]])
  --     vim.cmd([[hi link @lsp.type.parameter Hlargs]])
  --   end,
  -- },
  {
    'lualine.nvim',
    for_cat = 'general.always',
    -- cmd = { "" },
    event = 'DeferredUIEnter',
    -- ft = "",
    -- keys = "",
    -- colorscheme = "",
    after = function(plugin)
      require('lualine').setup {
        options = {
          icons_enabled = false,
          theme = colorschemeName,
          component_separators = '|',
          section_separators = '',
        },
        sections = {
          lualine_c = {
            {
              'filename',
              path = 1,
              status = true,
            },
          },
        },
        inactive_sections = {
          lualine_b = {
            {
              'filename',
              path = 3,
              status = true,
            },
          },
          lualine_x = { 'filetype' },
        },
        tabline = {
          lualine_a = { 'buffers' },
          -- if you use lualine-lsp-progress, I have mine here instead of fidget
          -- lualine_b = { 'lsp_progress', },
          lualine_z = { 'tabs' },
        },
      }
    end,
  },
  {
    'gitsigns.nvim',
    for_cat = 'general.always',
    event = 'DeferredUIEnter',
    -- cmd = { "" },
    -- ft = "",
    -- keys = "",
    -- colorscheme = "",
    after = function(plugin)
      require('gitsigns').setup {
        -- See `:help gitsigns.txt`
        signs = {
          add = { text = '+' },
          change = { text = '~' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map({ 'n', 'v' }, ']c', function()
            if vim.wo.diff then
              return ']c'
            end
            vim.schedule(function()
              gs.next_hunk()
            end)
            return '<Ignore>'
          end, { expr = true, desc = 'Jump to next hunk' })

          map({ 'n', 'v' }, '[c', function()
            if vim.wo.diff then
              return '[c'
            end
            vim.schedule(function()
              gs.prev_hunk()
            end)
            return '<Ignore>'
          end, { expr = true, desc = 'Jump to previous hunk' })

          -- Actions
          -- visual mode
          map('v', '<leader>hs', function()
            gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
          end, { desc = 'stage git hunk' })
          map('v', '<leader>hr', function()
            gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
          end, { desc = 'reset git hunk' })
          -- normal mode
          map('n', '<leader>gs', gs.stage_hunk, { desc = 'git stage hunk' })
          map('n', '<leader>gr', gs.reset_hunk, { desc = 'git reset hunk' })
          map('n', '<leader>gS', gs.stage_buffer, { desc = 'git Stage buffer' })
          map('n', '<leader>gu', gs.undo_stage_hunk, { desc = 'undo stage hunk' })
          map('n', '<leader>gR', gs.reset_buffer, { desc = 'git Reset buffer' })
          map('n', '<leader>gp', gs.preview_hunk, { desc = 'preview git hunk' })
          map('n', '<leader>gb', function()
            gs.blame_line { full = false }
          end, { desc = 'git blame line' })
          map('n', '<leader>gd', gs.diffthis, { desc = 'git diff against index' })
          map('n', '<leader>gD', function()
            gs.diffthis '~'
          end, { desc = 'git diff against last commit' })

          -- Toggles
          map('n', '<leader>gtb', gs.toggle_current_line_blame, { desc = 'toggle git blame line' })
          map('n', '<leader>gtd', gs.toggle_deleted, { desc = 'toggle git show deleted' })

          -- Text object
          map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'select git hunk' })
        end,
      }
      vim.cmd [[hi GitSignsAdd guifg=#04de21]]
      vim.cmd [[hi GitSignsChange guifg=#83fce6]]
      vim.cmd [[hi GitSignsDelete guifg=#fa2525]]
    end,
  },
  {
    'lazygit.nvim',
    for_cat = "general.extra",
    event = 'DeferredUIEnter',
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    },
  },

  {
    'which-key.nvim',
    for_cat = 'general.extra',
    -- cmd = { "" },
    event = 'DeferredUIEnter',
    -- ft = "",
    -- keys = "",
    -- colorscheme = "",
    after = function(plugin)
      require('which-key').setup {}
      require('which-key').add {
        { '<leader><leader>',  group = 'buffer commands' },
        { '<leader><leader>_', hidden = true },
        { '<leader>c',         group = '[c]ode' },
        { '<leader>c_',        hidden = true },
        { '<leader>d',         group = '[d]ocument' },
        { '<leader>d_',        hidden = true },
        { '<leader>g',         group = '[g]it' },
        { '<leader>g_',        hidden = true },
        { '<leader>m',         group = '[m]arkdown' },
        { '<leader>m_',        hidden = true },
        { '<leader>r',         group = '[r]ename' },
        { '<leader>r_',        hidden = true },
        { '<leader>s',         group = '[s]earch' },
        { '<leader>s_',        hidden = true },
        { '<leader>sl',        group = '[s]earch [l]sp' },
        { '<leader>t',         group = '[t]oggles' },
        { '<leader>t_',        hidden = true },
        { '<leader>w',         group = '[w]orkspace' },
        { '<leader>w_',        hidden = true },
        { '<leader>z',         group = '[z]ettelkasten' }
      }
    end,
  },
}
