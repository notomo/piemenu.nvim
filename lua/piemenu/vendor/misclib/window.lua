local M = {}

function M.safe_close(window_id)
  if not vim.api.nvim_win_is_valid(window_id) then
    return false
  end
  vim.api.nvim_win_close(window_id, true)
  return true
end

function M.safe_enter(window_id)
  if not vim.api.nvim_win_is_valid(window_id) then
    return false
  end
  vim.api.nvim_set_current_win(window_id)
  return true
end

function M.jump(window_id, row, column)
  if not M.safe_enter(window_id) then
    return false
  end
  vim.cmd.normal({ args = { "m'" }, bang = true })
  vim.api.nvim_win_set_cursor(window_id, { row, column })
  return true
end

function M.is_floating(window_id)
  return vim.api.nvim_win_get_config(window_id).relative ~= ""
end

return M
