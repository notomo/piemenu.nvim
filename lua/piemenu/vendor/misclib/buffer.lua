local M = {}

function M.delete_by_name(path)
  local bufnr = M.find(path)
  if not bufnr then
    return
  end
  vim.api.nvim_buf_delete(bufnr, { force = true })
end

function M.find(path)
  local pattern = "^" .. vim.fn.escape(path, "[]{}\\") .. "$"
  local bufnr = vim.fn.bufnr(pattern)
  if bufnr == -1 then
    return nil
  end
  return bufnr
end

return M
