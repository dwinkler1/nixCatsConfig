require('nixCatsUtils').setup {
  non_nix_value = true,
}
_G.Config = {}

Config.isNixCats = require('nixCatsUtils').isNixCats

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

