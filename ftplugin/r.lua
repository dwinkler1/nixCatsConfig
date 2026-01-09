-- Settings
vim.bo.comments = [[:#',:####,:###,:##,:#]]

-- Keymaps
-- Note: These use <Plug> mappings provided by R.nvim
vim.keymap.set("n", "<Enter>", "<Plug>RDSendLine", { buffer = true })
vim.keymap.set("v", "<Enter>", "<Plug>RSendSelection", { buffer = true })

-- Assignment operator (--)
vim.keymap.set("i", "--", "<Cmd>lua MiniTrailspace.trim()<CR><Plug>RInsertAssign", { buffer = true, noremap = true })

-- Pipe operator (;;)
vim.keymap.set("i", ";;", "<Cmd>lua MiniTrailspace.trim()<CR><Plug>RInsertPipe<CR>", { buffer = true, noremap = true })

-- MiniClue / WhichKey hints
local r_clues = {
  { mode = "n", keys = "<localleader>a", desc = "+batch" },
  { mode = "n", keys = "<localleader>b", desc = "+between/debug" },
  { mode = "n", keys = "<localleader>c", desc = "+substitute" },
  { mode = "n", keys = "<localleader>f", desc = "+functions" },
  { mode = "n", keys = "<localleader>i", desc = "+install" },
  { mode = "n", keys = "<localleader>k", desc = "+knit" },
  { mode = "n", keys = "<localleader>p", desc = "+paragraph" },
  { mode = "n", keys = "<localleader>r", desc = "+regular" },
  { mode = "n", keys = "<localleader>s", desc = "+selection" },
  { mode = "n", keys = "<localleader>t", desc = "+dput" },
  { mode = "n", keys = "<localleader>u", desc = "+undebug" },
}

vim.b.miniclue_config = {
  clues = {
    r_clues,
  },
  triggers = {
    { mode = "n", keys = "<localleader>", desc = "+R" },
  },
}
