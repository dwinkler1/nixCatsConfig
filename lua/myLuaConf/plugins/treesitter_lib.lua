local MTREE = {}

function MTREE.add_global_node(nodes)
  local global_nodes = nodes
  table.insert(global_nodes, MTREE.get_type())
  return global_nodes
end

function MTREE.remove_global_node(nodes)
  local global_nodes = nodes
  for i, v in ipairs(global_nodes) do
    if v == MTREE.get_type() then
      table.remove(global_nodes, i)
    end
  end
  return global_nodes
end

function MTREE.set_global_nodes()
  local nodes_in = {}
  for n in string.gmatch(vim.fn.input("Enter root nodes: "), '([^,]+)') do
    table.insert(nodes_in, n)
  end
  return nodes_in
end

function MTREE.get_type()
  local ts_utils = require 'nvim-treesitter.ts_utils'
  local cur_win = vim.api.nvim_get_current_win()
  local cur_node = ts_utils.get_node_at_cursor(cur_win, true)
  if not cur_node then
    print("Not a node")
    return
  end
  print("Node type: " .. cur_node:type())
  return cur_node:type()
end

function MTREE.detect_global_node()
  local ts_utils = require 'nvim-treesitter.ts_utils'
  local cur_win = vim.api.nvim_get_current_win()
  local cur_node = ts_utils.get_node_at_cursor(cur_win, true)
  if not cur_node then
    print("No node detected")
    local root = vim.treesitter.get_parser():parse()[1]:root()
    print("Root type " .. root:type())
    return root:type()
  end
  local root = cur_node:root()
  print("Root type " .. root:type())
  return root:type()
end

function MTREE.move_to_next_non_empty_line()
  local ts_utils = require 'nvim-treesitter.ts_utils'
  -- Search for the next non-empty line
  local line_num = vim.fn.search("[^;]\\S", "W")

  -- If a non-empty line is found, move the cursor to it
  if line_num > 0 then
    vim.api.nvim_win_set_cursor(0, { line_num, 0 })
  else
    print("No non-empty line found below the current position")
    return
  end
  local cur_win = vim.api.nvim_get_current_win()
  local node = ts_utils.get_node_at_cursor(cur_win, true)

  if not node then
    print("No node found")
    return
  end

  while node:type() == 'comment' or node:type() == 'block_comment' or node:type() == 'line_comment' or node:type() == MTREE.detect_global_node() do
    vim.api.nvim_win_set_cursor(0, { line_num + 1, 0 })
    MTREE.move_to_next_non_empty_line()
    node = ts_utils.get_node_at_cursor()
  end
end

function MTREE.vselect_node(node)
  local ts_utils = require 'nvim-treesitter.ts_utils'
  local cur_buf = vim.api.nvim_get_current_buf()
  ts_utils.update_selection(cur_buf, node, "V")
end

local function is_in_list(list, value)
  for _, v in ipairs(list) do
    if v == value then
      return true
    end
  end
  return false
end


function MTREE.select_until_global(global_nodes)
  local ts_utils = require 'nvim-treesitter.ts_utils'
  local root_node = MTREE.detect_global_node()
  if not global_nodes then
    print("No global nodes provided")
    global_nodes = { }-- { root_node }
  end

  local node = ts_utils.get_node_at_cursor()
  if not node then
    print("No syntax node found at cursor position (named_descendant_for_range returned nil)")
    return
  end

  if node:type() == root_node then
    print("Cursor is on the root " .. root_node .. " node or in an empty area.")
    return
  end
  local parent = node:parent()
  while parent and not is_in_list(global_nodes, parent:type()) do
    node = parent
    parent = node:parent()
  end

  MTREE.vselect_node(node)
  -- Return the node for possible further use
  return node
end

function MTREE.slime_send_region()
  local keys = ":<C-u>call slime#send_op(visualmode(), 1)<CR>"
  local mode = "x"
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, true, true), mode, true)
  return
end

function MTREE.send_repl(global_nodes)
  local ts_utils = require 'nvim-treesitter.ts_utils'
  local cur_win = vim.api.nvim_get_current_win()
  local cur_node = ts_utils.get_node_at_cursor(cur_win, true)
  if not cur_node then
    MTREE.move_to_next_non_empty_line()
  else
    local cur_type = cur_node:type()
    if cur_type == 'comment' or cur_type == 'block_comment' or cur_type == 'line_comment' or is_in_list(global_nodes, cur_type) then
      MTREE.move_to_next_non_empty_line()
    end
  end

  local sel_node = MTREE.select_until_global(global_nodes)
  -- Send the selected text to the terminal using vim-slime
  MTREE.slime_send_region()
  ts_utils.goto_node(sel_node, true)
  MTREE.move_to_next_non_empty_line()
end

return MTREE
