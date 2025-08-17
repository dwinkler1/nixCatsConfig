-- Global Functions
Config.new_scratch_buffer = function() vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(true, true)) end

-- Toggle quickfix window
Config.toggle_quickfix = function()
  local cur_tabnr = vim.fn.tabpagenr()
  for _, wininfo in ipairs(vim.fn.getwininfo()) do
    if wininfo.quickfix == 1 and wininfo.tabnr == cur_tabnr then return vim.cmd('cclose') end
  end
  vim.cmd('copen')
end

Config.log = {}

Config.log_print = function()
  if log_buf_id == nil or not vim.api.nvim_buf_is_valid(log_buf_id) then
    log_buf_id = vim.api.nvim_create_buf(true, true)
  end
  vim.api.nvim_win_set_buf(0, log_buf_id)
  vim.api.nvim_buf_set_lines(log_buf_id, 0, -1, false, vim.split(vim.inspect(Config.log), '\n'))
end

Config.log_clear = function()
  Config.log = {}
  start_hrtime = vim.loop.hrtime()
  vim.cmd('echo "Cleared log"')
end

-- Execute current line with `lua`
Config.execute_lua_line = function()
  local line = 'lua ' .. vim.api.nvim_get_current_line()
  vim.api.nvim_command(line)
  print(line)
  vim.api.nvim_input('<Down>')
end

-- Try opening current file's dir with fallback to cwd
Config.try_opendir = function()
  local buff = vim.api.nvim_buf_get_name(0)
  local ok, err = pcall(MiniFiles.open, buff)
  vim.notify(err)
  if not ok then MiniFiles.open() end
end

-- For mini.start
Config.edit = function(path, win_id)
  if type(path) ~= 'string' then return end
  local b = vim.api.nvim_win_get_buf(win_id or 0)
  local try_mimic_buf_reuse = (vim.fn.bufname(b) == '' and vim.bo[b].buftype ~= 'quickfix' and not vim.bo[b].modified)
      and (#vim.fn.win_findbuf(b) == 1 and vim.deep_equal(vim.fn.getbufline(b, 1, '$'), { '' }))
  local buf_id = vim.fn.bufadd(vim.fn.fnamemodify(path, ':.'))
  -- Showing in window also loads. Use `pcall` to not error with swap messages.
  pcall(vim.api.nvim_win_set_buf, win_id or 0, buf_id)
  vim.bo[buf_id].buflisted = true
  if try_mimic_buf_reuse then pcall(vim.api.nvim_buf_delete, b, { unload = false }) end
  return buf_id
end

-- Load library
local packdir = nixCats.vimPackDir or MiniDeps.config.path.package

-- See https://github.com/echasnovski/mini.deps/blob/2953b2089591a49a70e0a88194dbb47fb0e4635c/lua/mini/deps.lua#L518C5-L518C39
Config.source_path = function(path)
  pcall(function() vim.cmd('source ' .. vim.fn.fnameescape(path)) end)
end

Config.add = (function(pkg)
  vim.cmd.packadd(pkg)
  local should_load_after_dir = vim.v.vim_did_enter == 1 and vim.o.loadplugins
  if not should_load_after_dir then return end
  local after_paths = vim.fn.glob(
    packdir .. '/pack/myNeovimPackages/opt/' .. pkg .. '/after/plugin/**/*.{vim,lua}',
    false,
    true
  )
  vim.iter(after_paths):map(function(p)
    Config.source_path(p)
  end)
end)

Config.now_if_args = vim.fn.argc(-1) > 0 and MiniDeps.now or MiniDeps.later
