
local ts_lib = require('myLuaConf.plugins.treesitter_lib')
local global_nodes = { 'source_file', 'module_definition' }

vim.keymap.set({ 'n', 'v' }, '<localleader>v', function()
    ts_lib.move_to_next_non_empty_line(); ts_lib.select_until_global(global_nodes)
  end,
  { noremap = true, silent = true, desc = "Visual select next node after WS" })

vim.keymap.set('n', '<localleader>a', function() ts_lib.send_repl(global_nodes) end,
  { noremap = true, silent = true, desc = "Send node to REPL" })

vim.keymap.set('n', '<S-CR>', function() ts_lib.send_repl(global_nodes) end,
  { noremap = true, silent = true, desc = "Send node to REPL" })

-- For debugging
vim.keymap.set('n', '<localleader>p', function() ts_lib.print_type() end,
  { noremap = true, silent = true, desc = "Print node type" })

