local M = {}

function M.close(id)
  vim.validate({id = {id, "number"}})
  if not vim.api.nvim_win_is_valid(id) then
    return
  end
  vim.api.nvim_win_close(id, true)
end

return M
