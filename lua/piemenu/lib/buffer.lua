local M = {}

function M.delete_by_name(name)
  local bufnr = vim.fn.bufnr(("^%s$"):format(name))
  if bufnr ~= -1 then
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end
end

return M
