local add = Config.add
local later = MiniDeps.later
local now_if_args = Config.now_if_args

if not Config.isNixCats then
  local m_add = MiniDeps.add
  now_if_args(function()
    BLINK_VERSION = "v1.4.1"
    m_add({
      source = "saghen/blink.cmp",
      depends = { "rafamadriz/friendly-snippets" },
      checkout = blink_version,
    })
  end)

  later(function()
    m_add({ source = "hrsh7th/cmp-cmdline" })
    m_add({ source = "xzbdmw/colorful-menu.nvim" })
    m_add({ source = "zbirenbaum/copilot.lua" })
    m_add({ source = "CopilotC-Nvim/CopilotChat.nvim" })
    m_add({ source = "jmbuhr/cmp-pandoc-references" })
    m_add({ source = "fang2hou/blink-copilot" })
    m_add({ source = "R-nvim/cmp-r" })
    m_add({ source = "codecompanion.nvim" })
  end)
end

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
              default = "claude-sonnet-4",
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
    prompt_library = {
      ["Code Expert"] = {
        strategy = "chat",
        description = "Get some special advice from an LLM",
        opts = {
          mapping = "<LocalLeader>aa",
          modes = { "v" },
          short_name = "expert",
          auto_submit = true,
          stop_context_insertion = true,
          user_prompt = true,
        },
        prompts = {
          {
            role = "system",
            content = function(context)
              return "I want you to act as a senior "
                  .. context.filetype
                  .. " developer. I will ask you specific questions and I want you to return concise explanations and codeblock examples."
            end,
          },
          {
            role = "user",
            content = function(context)
              local text = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

              return "I have the following code:\n\n```" .. context.filetype .. "\n" .. text .. "\n```\n\n"
            end,
            opts = {
              contains_code = true,
            }
          },
        },
      },
    }
  })
  vim.cmd([[cab cc CodeCompanion]])
end)

now_if_args(function()
  add("blink.cmp")

  local fuzzy_setting = {
    sorts = {
      "exact",
      -- defaults
      "score",
      "sort_text",
    }
  }

  if not Config.isNixCats then
    fuzzy_setting.prebuilt_binary.force_version = BLINK_VERSION
  end

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
    fuzzy = fuzzy_setting,
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
