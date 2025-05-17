M = {}
local mini = require('mini.starter')
M.footer_n_seconds = (function()
  local timer = vim.loop.new_timer()
  local n_seconds = 0
  timer:start(0, 1000, vim.schedule_wrap(function()
    if vim.bo.filetype ~= 'ministarter' then
      timer:stop()
      return
    end
    n_seconds = n_seconds + 1
    mini.refresh()
  end))

  return function()
    return 'Number of seconds since opening: ' .. n_seconds
  end
end)()

M.footer_text = (function() return [[
       _      _____       _             ____  _   _                 _           
      (_)    /  __ \     | |           / / / | \ | |               (_)          
 _ __  ___  _| /  \/ __ _| |_ ___     / / /  |  \| | ___  _____   ___ _ __ ___  
| '_ \| \ \/ | |    / _` | __/ __|   / / /   | . ` |/ _ \/ _ \ \ / | | '_ ` _ \ 
| | | | |>  <| \__/| (_| | |_\__ \  / / /    | |\  |  __| (_) \ V /| | | | | | |
|_| |_|_/_/\_\\____/\__,_|\__|___/ /_/_/     \_| \_/\___|\___/ \_/ |_|_| |_| |_|
]]
end
)

-- Function to get the most recent files by file-extension OR Neovim-detected filetype
-- for mini.starter Neovim dashboard, with file path appended to name.
-- Accepts a table of target filetypes (e.g., {"lua", "python", "markdown"})
-- or a single filetype string (e.g., "lua").
function M.get_recent_files_by_ft_or_ext(target_filetypes_input)
  -- Ensure target_filetypes is a table
  local target_filetypes_list
  if type(target_filetypes_input) == "string" then
    target_filetypes_list = { target_filetypes_input }
  elseif type(target_filetypes_input) == "table" then
    target_filetypes_list = target_filetypes_input
  else
    vim.notify("get_recent_files_by_ft_or_ext: Invalid input type for filetypes", vim.log.levels.ERROR)
    return {}
  end

  if #target_filetypes_list == 0 then
    return {}
  end

  -- Create a lookup map for faster target filetype checking
  local target_ft_map = {}
  for _, ft in ipairs(target_filetypes_list) do
    target_ft_map[ft] = true
  end

  -- Get the current working directory
  local cwd = vim.fn.getcwd()

  -- Cache functions for performance
  local fnamemodify = vim.fn.fnamemodify
  local filereadable = vim.fn.filereadable
  local getftime = vim.fn.getftime
  local fnameescape = vim.fn.fnameescape

  -- Initialize table to track the most recent files for each *target* filetype
  local most_recent_for_target = {}
  for _, target_ft_key in ipairs(target_filetypes_list) do
    most_recent_for_target[target_ft_key] = { file = nil, time = 0 }
  end

  -- Get oldfiles (recently opened files)
  local oldfiles = vim.v.oldfiles
  if not oldfiles or #oldfiles == 0 then
    return {}
  end

  -- Check if vim.filetype.match is available (Neovim 0.7+)
  -- We use pcall to avoid errors on older Neovim versions or if something is misconfigured.
  local ft_match_success, ft_match_fn = pcall(function() return vim.filetype.match end)
  local can_use_nvim_ft_detect = ft_match_success and type(ft_match_fn) == "function"

  -- Keep track of fully resolved paths already processed to avoid redundant work
  local processed_full_paths = {}

  -- Loop through oldfiles
  for _, file_path_from_oldfiles in ipairs(oldfiles) do
    -- Convert to full path
    local full_path = fnamemodify(file_path_from_oldfiles, ':p')

    -- Skip if this full_path has already been processed or is not valid
    if processed_full_paths[full_path] then
      goto continue   -- Lua's goto for skipping to next iteration
    end
    processed_full_paths[full_path] = true

    -- Check if file exists, is readable, and is in current working directory
    if filereadable(full_path) == 1 and full_path:find(cwd, 1, true) then
      local file_ext = fnamemodify(full_path, ':e')
      local nvim_detected_ft = nil

      if can_use_nvim_ft_detect then
        -- Suppress errors from vim.filetype.match as it might fail for odd paths
        local success, result = pcall(ft_match_fn, { filename = full_path })
        if success and type(result) == "string" and result ~= "" then
          nvim_detected_ft = result
        end
      end

      -- For each target filetype the user is looking for...
      for target_ft_key, _ in pairs(target_ft_map) do
        local is_match = false
        -- Match if extension matches target (e.g., target "lua", file "script.lua")
        if file_ext:lower() == target_ft_key:lower() then
          is_match = true
          -- Or, if Neovim-detected filetype matches target (e.g., target "markdown", file "README" detected as markdown)
        elseif nvim_detected_ft and nvim_detected_ft == target_ft_key then
          is_match = true
        end

        if is_match then
          local mod_time = getftime(full_path)
          if mod_time > most_recent_for_target[target_ft_key].time then
            most_recent_for_target[target_ft_key].time = mod_time
            most_recent_for_target[target_ft_key].file = full_path
          end
        end
      end
    end
    ::continue::   -- Label for goto
  end

  -- Format results as mini.starter items
  local result_items = {}
  for target_ft_key, data in pairs(most_recent_for_target) do
    if data.file then
      local filename_only = fnamemodify(data.file, ':t')
      -- Ensure the item refers to the specific file path, correctly escaped
      local file_to_edit = data.file
      table.insert(result_items, {
        name = string.format('%s (%s)', filename_only, fnamemodify(file_to_edit, ':~:.')),
        action = function() vim.cmd('edit ' .. fnameescape(file_to_edit)) end,
        section = 'Recent ' .. target_ft_key:sub(1, 1):upper() .. target_ft_key:sub(2),   -- Use the requested filetype for section name
      })
    end
  end

  return result_items
end

return M
