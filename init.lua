_G.Config = {}
Config.isNixCats = vim.g.nix_info_plugin_name ~= nil

local ok, nix_info = pcall(require, vim.g.nix_info_plugin_name or "")
if ok then
  _G.nixCats = nix_info
  package.preload['nixCats.cats'] = function()
    return setmetatable(nix_info.settings.cats or {}, getmetatable(nix_info))
  end
else
  require('nixCatsUtils').setup {
    non_nix_value = true,
  }
  Config.isNixCats = require('nixCatsUtils').isNixCats
end

require('lze').register_handlers(require('nixCatsUtils.lzUtils').for_cat)

if not Config.isNixCats then
  local path_package = vim.fn.stdpath('data') .. '/site/'
  local mini_path = path_package .. 'pack/deps/start/mini.nvim'
  if not vim.uv.fs_stat(mini_path) then
    vim.cmd('echo "Installing `mini.nvim`" | redraw')
    local clone_cmd = {
      'git', 'clone', '--filter=blob:none',
      'https://github.com/echasnovski/mini.nvim', mini_path
    }
    vim.fn.system(clone_cmd)
    vim.cmd('packadd mini.nvim | helptags ALL')
    vim.cmd('echo "Installed `mini.nvim`" | redraw')
  end

  -- Set up 'mini.deps' (customize to your liking)
  require('mini.deps').setup({ path = { package = path_package } })
end

require('mini.deps').setup()
