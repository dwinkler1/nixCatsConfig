
vim.g.slime_python_ipython = 1

local ts_lib = Config.treesitter_helpers
local global_nodes_python = { 'module' }
ts_lib.setup_keybindings(global_nodes_python)

require("conform").setup({
  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 100,
    lsp_format = "prefer",
  },
})
