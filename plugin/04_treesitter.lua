local M = {}

-- Cache treesitter utils to avoid repeated requires
local ts_utils = require('nvim-treesitter.ts_utils')

-- Define comment node types as constants
local COMMENT_TYPES = {
  comment = true,
  block_comment = true,
  line_comment = true,
}

-- Helper function to check if value exists in list (optimized with early return)
local function is_in_list(list, value)
  if not list or not value then
    return false
  end

  for _, v in ipairs(list) do
    if v == value then
      return true
    end
  end
  return false
end

-- Helper function to get current node with error handling
local function get_current_node()
  local cur_win = vim.api.nvim_get_current_win()
  return ts_utils.get_node_at_cursor(cur_win, true)
end

function M.add_global_node(nodes)
  if not nodes then
    return nil
  end

  local node_type = M.get_type()
  if not node_type then
    return nodes
  end

  -- Create a copy to avoid modifying the original
  local global_nodes = vim.deepcopy(nodes)

  -- Check if node type already exists to avoid duplicates
  if not is_in_list(global_nodes, node_type) then
    table.insert(global_nodes, node_type)
  end

  return global_nodes
end

function M.remove_global_node(nodes)
  if not nodes then
    return nil
  end

  local node_type = M.get_type()
  if not node_type then
    return nodes
  end

  local global_nodes = vim.deepcopy(nodes)

  -- Remove all occurrences (iterate backwards to avoid index issues)
  for i = #global_nodes, 1, -1 do
    if global_nodes[i] == node_type then
      table.remove(global_nodes, i)
    end
  end

  return global_nodes
end

function M.set_global_nodes()
  local input = vim.fn.input("Enter root nodes: ")
  if input == "" then
    return {}
  end

  local nodes_in = {}
  -- Trim whitespace from each node name
  for node in string.gmatch(input, '([^,]+)') do
    local trimmed = vim.trim(node)
    if trimmed ~= "" then
      table.insert(nodes_in, trimmed)
    end
  end

  return nodes_in
end

function M.get_type()
  local cur_node = get_current_node()
  if not cur_node then
    print("Not a node")
    return nil
  end

  local node_type = cur_node:type()
  print("Node type: " .. node_type)
  return node_type
end

function M.detect_global_node()
  local cur_node = get_current_node()
  local root

  if not cur_node then
    print("No node detected")
    local parser = vim.treesitter.get_parser()
    if not parser then
      return nil
    end
    root = parser:parse()[1]:root()
  else
    root = cur_node:root()
  end

  if not root then
    return nil
  end

  local root_type = root:type()
  print("Root type: " .. root_type)
  return root_type
end

function M.move_to_next_non_empty_line()
  -- Search for the next non-empty line
  local line_num = vim.fn.search("[^;\\s]", "W")

  if line_num <= 0 then
    print("No non-empty line found below the current position")
    return false
  end

  -- Get the line content and find first non-whitespace character
  local line_content = vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, false)[1]
  local first_non_ws = line_content:find("%S") or 1
  vim.api.nvim_win_set_cursor(0, { line_num, first_non_ws - 1 })

  local node = get_current_node()
  if not node or not node:type() then
    print("No node found")
    return false
  end

  local global_node_type = M.detect_global_node()

  -- Skip comments and global nodes
  while node and (COMMENT_TYPES[node:type()] or node:type() == global_node_type) do
    line_num = line_num + 1
    local max_lines = vim.api.nvim_buf_line_count(0)

    if line_num > max_lines then
      print("Reached end of buffer")
      return false
    end

    -- Get the line content and find first non-whitespace character
    line_content = vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, false)[1]
    first_non_ws = line_content:find("%S") or 1
    vim.api.nvim_win_set_cursor(0, { line_num, first_non_ws - 1 })
    node = ts_utils.get_node_at_cursor()
  end

  return true
end

function M.vselect_node(node)
  if not node then
    return false
  end

  local cur_buf = vim.api.nvim_get_current_buf()
  ts_utils.update_selection(cur_buf, node, "V")
  return true
end

function M.select_until_global(global_nodes)
  local root_node = M.detect_global_node()
  if not root_node and global_nodes then
    root_node = global_nodes[1]
  end

  -- Use empty table if no global nodes provided
  global_nodes = global_nodes or {}

  local node = ts_utils.get_node_at_cursor()
  if not node then
    print("No syntax node found at cursor position")
    return nil
  end

  local node_type = node:type()

  if node_type == root_node then
    print("Cursor is on the root " .. root_node .. " node or in an empty area.")
    return nil
  end

  -- Check if current node is a global
  if is_in_list(global_nodes, node_type) then
    if M.vselect_node(node) then
      return node
    end
  end

  -- Traverse up the tree until we find a global node or reach the root
  local parent = node:parent()
  local parent_type = parent:type() or ""
  if parent and is_in_list(global_nodes, parent_type) then
    if M.vselect_node(node) then
      return node
    end
  end
  while parent and not is_in_list(global_nodes, parent:type()) do
    node = parent
    parent = node:parent()
  end

  if M.vselect_node(node) then
    return node
  end

  return nil
end

--- Sends the current visual selection to slime
--- Requires the slime plugin to be installed and configured
--- @return nil
function M.slime_send_region()
  -- Check if slime plugin is available
  if not vim.fn.exists('*slime#send_op') then
    vim.notify("slime plugin not available", vim.log.levels.ERROR)
    return
  end

  local slime_command = ":<C-u>call slime#send_op(visualmode(), 1)<CR>"
  local termcodes = vim.api.nvim_replace_termcodes(slime_command, true, true, true)

  vim.api.nvim_feedkeys(termcodes, "x", true)
end

function M.send_repl(global_nodes)
  local cur_node = get_current_node()

  if not cur_node then
    M.move_to_next_non_empty_line()
  else
    local cur_type = cur_node:type()
    if COMMENT_TYPES[cur_type] or is_in_list(global_nodes, cur_type) then
      M.move_to_next_non_empty_line()
    end
  end

  local sel_node = M.select_until_global(global_nodes)
  if not sel_node then
    print("No node selected for REPL")
    return
  end

  -- Send the selected text to the terminal using vim-slime
  M.slime_send_region()

  -- Move cursor and continue
  ts_utils.goto_node(sel_node, true)
  M.move_to_next_non_empty_line()
end

function M.setup_keybindings(global_nodes)
  local current_global_nodes = global_nodes

  vim.keymap.set({ 'n' }, '<localleader>r', function()
      current_global_nodes = M.set_global_nodes()
    end,
    { noremap = true, silent = true, desc = "set global_nodes", buffer = true })

  vim.keymap.set({ 'n', 'v' }, '<localleader>v', function()
      M.move_to_next_non_empty_line(); M.select_until_global(current_global_nodes)
    end,
    { noremap = true, silent = true, desc = "Visual select next node after WS", buffer = true })

  vim.keymap.set('n', '<localleader>a', function() M.send_repl(current_global_nodes) end,
    { noremap = true, silent = true, desc = "Send node to REPL", buffer = true })

  vim.keymap.set({ 'n', 'i' }, '<S-CR>', function() M.send_repl(current_global_nodes) end,
    { noremap = true, silent = true, desc = "Send node to REPL", buffer = true })

  vim.keymap.set('n', '<CR>', function() M.send_repl(current_global_nodes) end,
    { noremap = true, silent = true, desc = "Send node to REPL", buffer = true })

  vim.keymap.set('n', '<localleader>n',
    function() current_global_nodes = M.add_global_node(current_global_nodes) end,
    { noremap = true, silent = true, desc = "Add node under cursor to globals", buffer = true })

  vim.keymap.set('n', '<localleader>x',
    function() current_global_nodes = M.remove_global_node(current_global_nodes) end,
    { noremap = true, silent = true, desc = "Remove node under cursor from globals", buffer = true })

  vim.keymap.set('n', '<localleader>o', function()
    pout = table.concat(global_nodes, ', ') .. ""
    print(pout)
  end, { noremap = true, silent = true, desc = "Print globals", buffer = true })

  vim.keymap.set('n', '<localleader>p', function() M.get_type() end,
    { noremap = true, silent = true, desc = "Print node type", buffer = true })
end

Config.treesitter_helpers = M

return M
