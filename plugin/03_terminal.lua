local M = {}

-- Configuration
M.opt_bracket = true
M.opt_term = nil

-- Bracket paste control
function M.toggle_bracket()
  M.opt_bracket = not M.opt_bracket
  return M.opt_bracket
end

function M.set_bracket(enabled)
  M.opt_bracket = enabled ~= false
end

-- Terminal management
function M.split_and_open_terminal()
  vim.cmd("below terminal")
  vim.cmd("resize " .. math.floor(vim.fn.winheight(0) * 0.9))
  M.opt_term = vim.api.nvim_win_get_buf(vim.api.nvim_get_current_win())
  return M.opt_term
end

-- Helper function to find window by buffer
local function find_window_by_buffer(target_buf)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == target_buf then
      return win
    end
  end
  return nil
end

-- Helper function to check if buffer is terminal
local function is_terminal_buffer(buf)
  local ok, buftype = pcall(vim.api.nvim_get_option_value, "buftype", { buf = buf })
  return ok and buftype == "terminal"
end

-- Find the first open terminal buffer in the current tab
local function find_first_terminal_buf()
  local wins = vim.api.nvim_tabpage_list_wins(0)
  for _, win in ipairs(wins) do
    local buf = vim.api.nvim_win_get_buf(win)
    if is_terminal_buffer(buf) then
      return buf
    end
  end
  return M.split_and_open_terminal()
end

local function scroll_terminal_to_bottom(term_buf)
  local term_win = find_window_by_buffer(term_buf)
  if term_win then
    local line_count = vim.api.nvim_buf_line_count(term_buf)
    vim.api.nvim_win_set_cursor(term_win, { line_count, 0 })
  end
end

-- Get terminal job ID with proper error handling
local function get_terminal_job_id(term_buf)
  local ok, job_id = pcall(vim.api.nvim_buf_get_var, term_buf, "terminal_job_id")
  return ok and job_id or nil
end

local function send_to_terminal(text, term_buf)
  local current_window = vim.api.nvim_get_current_win()
  local target_buf = term_buf

  -- Ensure we have a valid terminal buffer
  local job_id = get_terminal_job_id(target_buf)
  if not job_id then
    vim.notify("Creating new terminal", vim.log.levels.INFO)
    target_buf = find_first_terminal_buf()
    job_id = get_terminal_job_id(target_buf)

    if not job_id then
      vim.notify("Failed to retrieve terminal job ID", vim.log.levels.ERROR)
      return false
    end
  end

  if not text or text == "" then
    return false
  end

  -- Prepare text with optional bracket paste
  local formatted_text = text
  if M.opt_bracket then
    local ESC = string.char(27)
    formatted_text = ESC .. "[200~" .. text .. ESC .. "[201~"
  end

  -- Send to terminal
  vim.api.nvim_chan_send(job_id, formatted_text .. "\r")
  scroll_terminal_to_bottom(target_buf)

  -- Restore original window if changed
  if current_window ~= vim.api.nvim_get_current_win() then
    vim.api.nvim_set_current_win(current_window)
  end

  return true
end

-- Public functions
function M.open_in_terminal(cmd)
  local command = cmd or ""
  local current_window = vim.api.nvim_get_current_win()
  local term_id = M.split_and_open_terminal()
  send_to_terminal(command, term_id)
  vim.api.nvim_set_current_win(current_window)
end

-- Predefined terminal commands
local terminal_commands = {
  clickhouse_client = "clickhouse client -m",
  clickhouse_local = "clickhouse local -m",
  duckdb = "duckdb",
  julia = "julia --project=@.",
  python = "uv run python",
  shell = "echo 'Hello " .. vim.env.USER .. "!'",
}

for name, command in pairs(terminal_commands) do
  M["open_" .. name] = function()
    M.open_in_terminal(command)
  end
end

-- Make send_to_terminal available for external use
M.send_to_terminal = send_to_terminal

Config.terminal = M
