local ts_lib = Config.treesitter_helpers

local global_nodes_julia = { 'source_file', 'module_definition' }
ts_lib.setup_keybindings(global_nodes_julia)
