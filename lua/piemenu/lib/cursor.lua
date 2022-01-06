local M = {}

function M.global_position(window_id)
  vim.validate({ window_id = { window_id, "number", true } })
  window_id = window_id or vim.api.nvim_get_current_win()
  local win_pos = vim.api.nvim_win_get_position(window_id)
  return { win_pos[1] + vim.fn.winline() - 1, win_pos[2] + vim.fn.wincol() }
end

return M
