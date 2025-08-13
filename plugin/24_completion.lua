local add = Config.add
local later = MiniDeps.later
local now_if_args = Config.now_if_args

later(function()
  add("cmp-cmdline")
end)

later(function()
  add("blink.compat")
end)

later(function()
  add("colorful-menu.nvim")
end)

later(function()
  add("copilot.lua")
  require("copilot").setup({
    suggestion = { enabled = false },
    panel = { enabled = false },
    filetypes = {
      markdown = true,
      help = true,
    },
    server_opts_overrides = {
      settings = {
        telemetry = {
          telemetryLevel = 'off',
        },
      },
    },
  })
end)

later(function()
  add("CopilotChat.nvim")

  local chat = require("CopilotChat")
  --      local prompts = require('CopilotChat.config.prompts')
  local chatselect = require("CopilotChat.select")
  --      local cutils = require('CopilotChat.utils')
  chat.setup({
    model = "claude-sonnet-4",
    -- Markdown rendering
    highlight_headers = false,
    separator = "---",
    error_header = "> [!ERROR] Error",
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
        mapping = "<leader>aE",
        description = "AI Explain",
      },
      Review = {
        mapping = "<leader>aR",
        description = "AI Review",
      },
      Tests = {
        mapping = "<leader>aT",
        description = "AI Tests",
      },
      Fix = {
        mapping = "<leader>aF",
        description = "AI Fix",
      },
      Optimize = {
        mapping = "<leader>aO",
        description = "AI Optimize",
      },
      Docs = {
        mapping = "<leader>aD",
        description = "AI Documentation",
      },
      Commit = {
        mapping = "<leader>aC",
        description = "AI Generate Commit",
        selection = chatselect.buffer,
      },
    },
  })

  vim.keymap.set({ "n" }, "<leader>at", chat.toggle, { desc = "AI Toggle" })
  vim.keymap.set({ "v" }, "<leader>ae", chat.open, { desc = "AI Open" })
  vim.keymap.set({ "n" }, "<leader>ar", chat.reset, { desc = "AI Reset" })
  vim.keymap.set({ "n" }, "<leader>ad", chat.stop, { desc = "AI Stop" })
  vim.keymap.set({ "n" }, "<leader>am", chat.select_model, { desc = "AI Models" })
  vim.keymap.set({ "n", "v" }, "<leader>ap", chat.select_prompt, { desc = "AI Prompts" })
  vim.keymap.set({ "n", "v" }, "<leader>aa", function()
    vim.ui.input({
      prompt = "AI Question> ",
    }, function(input)
      if input and input ~= "" then
        chat.ask(input)
      end
    end)
  end, { desc = "AI Question" })

  vim.keymap.set("v", "<leader>av", function()
    local input = vim.fn.input("Quick Chat: ")
    if input == nil or input == "" then
      vim.notify("CopilotChat: No input provided.", vim.log.levels.WARN)
      return
    end
    -- Reselect visual selection after input prompt
    vim.cmd("normal! gv")
    chat.ask(input, {
      selection = chatselect.visual,
    })
  end, { desc = "Visual selection context" })

  vim.keymap.set("n", "<leader>ab", function()
    local input = vim.fn.input("Buffer Chat: ")
    if input and input ~= "" then
      chat.ask(input, {
        selection = chatselect.buffer,
      })
    end
  end, { desc = "Buffer context" })
  vim.keymap.set("n", "<leader>aB", function()
    local input = vim.fn.input("Buffers Chat: ")
    if input and input ~= "" then
      chat.ask(input, {
        selection = chatselect.buffers,
      })
    end
  end, { desc = "All Buffers context" })
end)

later(function()
  add("cmp-pandoc-references")
end)

later(function()
  add("blink-copilot")
  require("blink-copilot").setup({
    max_completions = 1,
  })
end)

later(function()
  add("cmp-r")
end)


later(function()
add("codecompanion.nvim")
  require("codecompanion").setup({ -- NOTE: you can check if you included the category with the thing wherever you want.
    adapters = {
      copilot = function()
        return require("codecompanion.adapters").extend("copilot", {
          schema = {
            model = {
              default = "gemini-2.5-pro",
            },
          },
        })
      end,
    },
    display = {
      chat = {
        show_settings = true, -- Show settings in the chat window
        window = {
          layout = "vertical",
          position = "right", -- Open the chat window in the lower right corner
          width = 0.33,       -- Width of the chat window (1/3 of screen)
        },
      },
    },
  })
  vim.cmd([[cab cc CodeCompanion]])
end)

now_if_args(function()
  add("blink.cmp")
  require("blink.cmp").setup({
    -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
    -- See :h blink-cmp-config-keymap for configuring keymaps
    keymap = {
      preset = "default",
      ["<C-space>"] = { "show", "select_next" },
      ["<C-l>"] = { "accept" },
    },
    cmdline = {
      enabled = true,
      keymap = {
        preset = "inherit",
        ["<Tab>"] = { "show", "select_next" },
        ["<S-Tab>"] = { "show", "select_prev" },
        ["<C-l>"] = { "accept" },
        --["<Tab>"] = { "show_and_insert", "select_next" },
      },
      completion = {
        menu = {
          auto_show = true,
        },
        list = {
          selection = {
            preselect = false,
            auto_insert = true,
          },
        },
      },
      sources = function()
        local type = vim.fn.getcmdtype()
        -- Search forward and backward
        if type == "/" or type == "?" then
          return { "buffer" }
        end
        -- Commands
        if type == ":" or type == "@" then
          return { "cmdline", "cmp_cmdline" }
        end
        return {}
      end,
    },
    fuzzy = {
      sorts = {
        "exact",
        -- defaults
        "score",
        "sort_text",
      }
    },
    signature = {
      enabled = true,
      window = {
        show_documentation = true,
      },
    },
    completion = {
      menu = {
        draw = {
          treesitter = { "lsp" },
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
                local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                return hl
              end,
            },
            kind = {
              -- (optional) use highlights from mini.icons
              highlight = function(ctx)
                local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                return hl
              end,
            },
          },
        },
      },
      list = {
        selection = {
          preselect = false,
          auto_insert = true,
        },
      },
      documentation = {
        auto_show = true,
      },
      trigger = {
        show_in_snippet = false,
      },
    },
    snippets = {
      preset = "mini_snippets",
    },
    sources = {
      default = { "references", "lsp", "path", "snippets", "buffer", "omni", "copilot", "codecompanion", "cmp_r" },
      providers = {
        path = {
          score_offset = 50,
        },
        lsp = {
          score_offset = 40,
        },
        snippets = {
          score_offset = 0,
        },
        cmp_cmdline = {
          name = "cmp_cmdline",
          module = "blink.compat.source",
          enabled = false,
          score_offset = 10,
          opts = {
            cmp_name = "cmdline",
          },
        },
        cmp_r = {
          name = "cmp_r",
          module = "blink.compat.source",
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
          score_offset = 50,
        },
      },
    },
  })
end)
