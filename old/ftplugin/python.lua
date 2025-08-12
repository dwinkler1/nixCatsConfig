vim.g.slime_python_ipython = 1

local ts_lib = require('myLuaConf.plugins.treesitter_lib')
local global_nodes_python = { 'module' }

vim.keymap.set({ 'n' }, '<localleader>r', function()
    global_nodes_python = ts_lib.set_global_nodes()
  end,
  { noremap = true, silent = true, desc = "set global_nodes", buffer = true })

vim.keymap.set({ 'n', 'v' }, '<localleader>v', function()
    ts_lib.move_to_next_non_empty_line(); ts_lib.select_until_global(global_nodes_python)
  end,
  { noremap = true, silent = true, desc = "Visual select next node after WS", buffer = true })

vim.keymap.set('n', '<localleader>a', function() ts_lib.send_repl(global_nodes_python) end,
  { noremap = true, silent = true, desc = "Send node to REPL", buffer = true })

vim.keymap.set('n', '<S-CR>', function() ts_lib.send_repl(global_nodes_python) end,
  { noremap = true, silent = true, desc = "Send node to REPL", buffer = true })

vim.keymap.set('n', '<localleader>n', function() global_nodes_python = ts_lib.add_global_node(global_nodes_python) end,
  { noremap = true, silent = true, desc = "Add node under cursor to globals", buffer = true })

vim.keymap.set('n', '<localleader>x', function() global_nodes_python = ts_lib.remove_global_node(global_nodes_python) end,
  { noremap = true, silent = true, desc = "Remove node under cursor from globals", buffer = true })

vim.keymap.set('n', '<localleader>o', function()
  local pout = ""
  for _, v in ipairs(global_nodes_python) do
    pout = v .. ", " .. pout
  end
  print(pout)
end, { noremap = true, silent = true, desc = "Print globals", buffer = true })

-- For debugging
vim.keymap.set('n', '<localleader>p', function() ts_lib.get_type() end,
  { noremap = true, silent = true, desc = "Print node type", buffer = true })
