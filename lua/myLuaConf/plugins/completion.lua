local load_w_after = function(name)
  -- Define the function outside the keymapping for better scope management
  vim.cmd.packadd(name)
  vim.cmd.packadd(name .. '/after')
end
return {
  {
    "cmp-cmdline",
    for_cat = "general.blink",
    on_plugin = { "blink.cmp" },
    load = load_w_after,
  },
  {
    "blink.compat",
    for_cat = "general.blink",
    dep_of = { "cmp-cmdline" },
  },
  {
    "luasnip",
    for_cat = "general.blink",
    dep_of = { "blink.cmp" },
    after = function(_)
      local ls = require('luasnip')
      require('luasnip.loaders.from_vscode').lazy_load()
      ls.config.setup {}

      vim.keymap.set({ "i", "s" }, "<M-n>", function()
        if ls.choice_active() then
          ls.change_choice(1)
        end
      end)
    end,
  },
  {
    "colorful-menu.nvim",
    for_cat = "general.blink",
    on_plugin = { "blink.cmp" },
  },
  {
    "copilot.lua",
    for_cat = "general.blink",
    dep_of = { 'blink.cmp', 'CopilotChat' },
    event = "InsertEnter",
    after = function()
      require('copilot').setup({
        suggestion = { enabled = false },
        panel = { enabled = false },
        filetypes = {
          markdown = true,
          help = true,
        },

      })
    end,
  },
  {
    "CopilotChat",
    for_cat = "general.blink",
    event = "DeferredUIEnter",
    after = function()
      local chat = require('CopilotChat')
      --      local prompts = require('CopilotChat.config.prompts')
      local chatselect = require('CopilotChat.select')
      --      local cutils = require('CopilotChat.utils')
      chat.setup({
        model = 'gemini-2.5-pro',
        -- Markdown rendering
        highlight_headers = false,
        separator = '---',
        error_header = '> [!ERROR] Error',
        show_help = false, -- Show help message when opening the chat window
        window = {
          layout = "float",
          width = 0.45,
          height = 0.45,
          row = math.floor(vim.fn.winheight(0) * 0.55),
          col = math.floor(vim.fn.winwidth(0) * 0.55),
          border = "rounded",
          title = "Copilot Chat",
        },

        prompts = {
          Explain = {
            mapping = '<leader>cce',
            description = 'AI Explain',
          },
          Review = {
            mapping = '<leader>ccr',
            description = 'AI Review',
          },
          Tests = {
            mapping = '<leader>cct',
            description = 'AI Tests',
          },
          Fix = {
            mapping = '<leader>ccf',
            description = 'AI Fix',
          },
          Optimize = {
            mapping = '<leader>cco',
            description = 'AI Optimize',
          },
          Docs = {
            mapping = '<leader>ccd',
            description = 'AI Documentation',
          },
          Commit = {
            mapping = '<leader>ccg',
            description = 'AI Generate Commit',
            selection = chatselect.buffer,
          },
        }
      })

      vim.keymap.set({ 'n' }, '<leader>cca', chat.toggle, { desc = 'AI Toggle' })
      vim.keymap.set({ 'v' }, '<leader>cca', chat.open, { desc = 'AI Open' })
      vim.keymap.set({ 'n' }, '<leader>ccx', chat.reset, { desc = 'AI Reset' })
      vim.keymap.set({ 'n' }, '<leader>ccs', chat.stop, { desc = 'AI Stop' })
      vim.keymap.set({ 'n' }, '<leader>ccm', chat.select_model, { desc = 'AI Models' })
      vim.keymap.set({ 'n', 'v' }, '<leader>ccp', chat.select_prompt, { desc = 'AI Prompts' })
      vim.keymap.set({ 'n', 'v' }, '<leader>ccq', function()
        vim.ui.input({
          prompt = 'AI Question> ',
        }, function(input)
          if input and input ~= "" then
            chat.ask(input)
          end
        end)
      end, { desc = 'AI Question' })

      vim.keymap.set('v', '<leader>ccc', function()
        local input = vim.fn.input("Quick Chat: ")
        if input == nil or input == "" then
          vim.notify("CopilotChat: No input provided.", vim.log.levels.WARN)
          return
        end
        -- Reselect visual selection after input prompt
        vim.cmd('normal! gv')
        chat.ask(input, {
          selection = chatselect.visual
        })
      end, { desc = "CopilotChat - Quick chat" })

      vim.keymap.set('n', '<leader>ccc', function()
        local input = vim.fn.input("Quick Chat: ")
        if input and input ~= "" then
          chat.ask(input, {
            selection = chatselect.buffer
          })
        end
      end, { desc = "CopilotChat - Quick chat" })
      vim.keymap.set('n', '<leader>ccb', function()
        local input = vim.fn.input("Buffers Chat: ")
        if input and input ~= "" then
          chat.ask(input, {
            selection = chatselect.buffers
          })
        end
      end, { desc = "CopilotChat - Chat with all open buffers" })
    end
  },
  {
    "blink-copilot",
    dep_of = "blink.cmp",
  },
  {
    "blink.cmp",
    for_cat = "general.blink",
    event = "InsertEnter",
    after = function(_)
      require("blink.cmp").setup({
        -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
        -- See :h blink-cmp-config-keymap for configuring keymaps
        keymap = {
          preset = 'super-tab',
        },
        cmdline = {
          enabled = true,
          completion = {
            menu = {
              auto_show = true,
            },
          },
          sources = function()
            local type = vim.fn.getcmdtype()
            -- Search forward and backward
            if type == '/' or type == '?' then return { 'buffer' } end
            -- Commands
            if type == ':' or type == '@' then return { 'cmdline', 'cmp_cmdline' } end
            return {}
          end,
        },
        fuzzy = {
          sorts = {
            'exact',
            -- defaults
            'score',
            'sort_text',
          },
        },
        signature = {
          enabled = true,
          window = {
            show_documentation = true,
          },
        },
        -- completion.trigger.show_in_snippet = false
        completion = {
          menu = {
            draw = {
              treesitter = { 'lsp' },
              components = {
                label = {
                  text = function(ctx)
                    return require("colorful-menu").blink_components_text(ctx)
                  end,
                  highlight = function(ctx)
                    return require("colorful-menu").blink_components_highlight(ctx)
                  end,
                },
                kind_icon = {
                  -- (optional) use highlights from mini.icons
                  highlight = function(ctx)
                    local _, hl, _ = require('mini.icons').get('lsp', ctx.kind)
                    return hl
                  end,
                },
                kind = {
                  -- (optional) use highlights from mini.icons
                  highlight = function(ctx)
                    local _, hl, _ = require('mini.icons').get('lsp', ctx.kind)
                    return hl
                  end,
                }
              },
            },
          },
          documentation = {
            auto_show = true,
          },
          trigger = {
            show_in_snippet = false
          },
        },
        snippets = {
          preset = 'luasnip',
        },
        sources = {
          default = { 'pandoc_references', 'lsp', 'path', 'snippets', 'buffer', 'omni', 'copilot', 'codecompanion' },
          providers = {
            path = {
              score_offset = 50,
            },
            lsp = {
              score_offset = 40,
            },
            snippets = {
              score_offset = 40,
            },
            cmp_cmdline = {
              name = 'cmp_cmdline',
              module = 'blink.compat.source',
              score_offset = -100,
              opts = {
                cmp_name = 'cmdline',
              },
            },
            copilot = {
              name = "copilot",
              module = "blink-copilot",
              score_offset = 45,
              async = true,
            },
            codecompanion = {
              name = "CodeCompanion",
              module = "codecompanion.providers.completion.blink",
              score_offset = 45,
              async = true,
            },
            references = {
              name = "pandoc_references",
              module = "cmp-pandoc-references.blink",
            },
          },
        },
      })
    end,
  },
}
