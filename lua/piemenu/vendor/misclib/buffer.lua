local M = {}

function M.delete_by_name(name)
  local bufnr = vim.fn.bufnr(("^%s$"):format(name))
  if bufnr == -1 then
    return
  end
  vim.api.nvim_buf_delete(bufnr, { force = true })
end

function M.set_lines_as_modifiable(bufnr, s, e, strict, lines)
  vim.bo[bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(bufnr, s, e, strict, lines)
  vim.bo[bufnr].modifiable = false
end

return M
