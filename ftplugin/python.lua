
vim.g.slime_python_ipython = 1
vim.b.slime_cell_delimiter = vim.b.slime_cell_delimiter or "# %%"

local ts_lib = Config.treesitter_helpers
local global_nodes_python = { 'module' }
ts_lib.setup_keybindings(global_nodes_python)

local conform_format_group = vim.api.nvim_create_augroup("PythonConformFormat", { clear = false })
vim.api.nvim_clear_autocmds({ group = conform_format_group, buffer = 0 })
vim.api.nvim_create_autocmd("BufWritePre", {
  group = conform_format_group,
  buffer = 0,
  callback = function()
    require("conform").format({
      timeout_ms = 100,
      lsp_format = "prefer",
    })
  end,
})
