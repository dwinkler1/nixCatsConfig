local MTERM = {}

MTERM.opt_bracket = true
MTERM.opt_term = ""
function MTERM.set_bracket()
  MTERM.opt_bracket = true
end

function MTERM.unset_bracket()
  MTERM.opt_bracket = false
end

function MTERM.split_and_open_terminal()
  vim.cmd("below terminal")
  vim.cmd("resize " .. math.floor(vim.fn.winheight(0) * 0.9))
  MTERM.opt_term = vim.api.nvim_win_get_buf(vim.api.nvim_get_current_win())
  return MTERM.opt_term
end

-- Helper function to find the first open terminal buffer in the current tab
local function find_first_terminal_buf()
  local wins = vim.api.nvim_tabpage_list_wins(0)
  for _, w in ipairs(wins) do
    local curbuf = vim.api.nvim_win_get_buf(w)
    if vim.api.nvim_get_option_value("buftype", { buf = curbuf }) == "terminal" then
      return curbuf
    end
  end
  return MTERM.split_and_open_terminal()
end

local function scroll_terminal_to_bottom(term_buf)
  local term_win
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == term_buf then
      term_win = win
      break
    end
  end

  if term_win then
    -- Move the cursor to the last line of the buffer
    local line_count = vim.api.nvim_buf_line_count(term_buf)
    vim.api.nvim_win_set_cursor(term_win, { line_count, 0 })
  end
end

local function send_to_terminal(text, term)
  if text == "" then
    vim.notify("No text!", vim.log.levels.WARN)
    return
  end

  -- Find the first open terminal
  local term_buf = term

  -- Get the terminal's channel ID
  local ok, term_job_id = pcall(vim.api.nvim_buf_get_var, term_buf, "terminal_job_id")
  if not ok or not term_job_id then
    vim.notify("Creating new term.", vim.log.levels.WARN)
    local current_window = vim.api.nvim_get_current_win()
    term_buf = find_first_terminal_buf()
    if current_window ~= vim.api.nvim_get_current_win() then
      vim.api.nvim_set_current_win(current_window)
    end
  end

  ok, term_job_id = pcall(vim.api.nvim_buf_get_var, term_buf, "terminal_job_id")
  if not ok or not term_job_id then
    vim.notify("Failed to retrieve terminal job ID.", vim.log.levels.ERROR)
    return
  end

  -- Send the selected text to the terminal, appending a newline
  -- Bracket paste "\027[200~" ....  "\027[201~"
  if MTERM.opt_bracket then
    text = "\027[200~" .. text .. "\027[201~"
  end
  vim.api.nvim_chan_send(term_job_id, text .. "\r")
  -- vim.notify("Sent selection to terminal!")
  scroll_terminal_to_bottom(term_buf)
end


function MTERM.open_in_terminal(cmd)
  local c = cmd
  if not cmd then
    c = vim.fn.input("Command: ")
  end
  local current_window = vim.api.nvim_get_current_win()
  local term_id = MTERM.split_and_open_terminal()
  send_to_terminal(c, term_id)
  vim.api.nvim_set_current_win(current_window)
end

function MTERM.open_clickhouse_client()
  MTERM.open_in_terminal("clickhouse client")
end

function MTERM.open_clickhouse_local()
  MTERM.open_in_terminal("clickhouse local")
end

function MTERM.open_duckdb()
  MTERM.open_in_terminal("duckdb")
end

function MTERM.open_julia()
  MTERM.open_in_terminal("julia --project=@.")
end

return MTERM
