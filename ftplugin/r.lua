vim.b.slime_cell_delimiter = vim.b.slime_cell_delimiter or "## ----"

local assign_action = function()
  if vim.bo.filetype ~= "r" then
    return
  end

  local ok, r_edit = pcall(require, "r.edit")
  if not ok then
    return
  end

  if MiniTrailspace and MiniTrailspace.trim then
    MiniTrailspace.trim()
  end
  r_edit.assign()
end

vim.api.nvim_buf_create_user_command(0, "RAssign", assign_action, { desc = "Trim trailing space and insert <-" })
