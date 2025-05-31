-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
return {
  {
    "nvim-treesitter",
    for_cat = 'general.treesitter',
    -- cmd = { "" },
    event = "DeferredUIEnter",
    -- ft = "",
    -- keys = "",
    -- colorscheme = "",
    load = function(name)
      vim.cmd.packadd(name)
      vim.cmd.packadd("nvim-treesitter-textobjects")
    end,
    after = function(plugin)
      -- [[ Configure Treesitter ]]
      -- See `:help nvim-treesitter`
      require('nvim-treesitter.configs').setup {
        highlight = { enable = true, },
        indent = { enable = false, },
        parser_configurations = {
          markdown = {
            filetypes = { "markdown", "quarto", "copilot-chat" },
          },
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = 'gaa',
            node_incremental = 'gaa',
            scope_incremental = 'gas',
            node_decremental = 'gAA',
          },
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ['tp'] = '@parameter.outer',
              ['tia'] = '@parameter.inner',
              ['tf'] = '@function.outer',
              ['tif'] = '@function.inner',
              ['tt'] = '@class.outer',
              ['tit'] = '@class.inner',
              ['tic'] = '@call.inner',
              ['tc'] = '@call.outer',
              ['ta'] = '@assignment.outer'
            },
          },
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              [']m'] = '@function.outer',
              [']]'] = '@class.outer',
              [']p'] = '@parameter.inner',
              [']n'] = '@call.inner',
            },
            goto_next_end = {
              [']M'] = '@function.outer',
              [']['] = '@class.outer',
              [']P'] = '@parameter.inner',
            },
            goto_previous_start = {
              ['[m'] = '@function.outer',
              ['[['] = '@class.outer',
              ['[p'] = '@parameter.inner',
              ['[n'] = '@call.inner',
            },
            goto_previous_end = {
              ['[M'] = '@function.outer',
              ['[]'] = '@class.outer',
              ['[P'] = '@parameter.inner',
            },
          },
          swap = {
            enable = true,
            init_selection = '<c-space>',
            swap_next = {
              ['<leader>x'] = '@parameter.inner',
            },
            swap_previous = {
              ['<leader>X'] = '@parameter.inner',
            },
          },
        },
      }
    end,
  },
}
