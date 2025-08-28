
vim.g.slime_python_ipython = 1

local ts_lib = Config.treesitter_helpers
local global_nodes_python = { 'module' }
ts_lib.setup_keybindings(global_nodes_python)
