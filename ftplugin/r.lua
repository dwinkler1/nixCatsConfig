local minikeymap = require("mini.keymap")
local assign_action = function()
  if vim.bo.filetype == "r" then
    vim.api.nvim_input("<BS><BS><Cmd>lua MiniTrailspace.trim(); require('r.edit').assign()<CR>")
  end
end

