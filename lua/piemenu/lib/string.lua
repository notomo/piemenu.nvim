local M = {}

local ellipsis_str = ".."
function M.ellipsis(str, width)
  local str_width = vim.fn.strdisplaywidth(str)
  if str_width <= width then
    return str
  end

  local result = ""
  local ellipsis_len = #ellipsis_str
  for _, c in ipairs(vim.fn.split(str, "\\zs")) do
    result = result .. c
    if vim.fn.strdisplaywidth(result) + ellipsis_len >= width then
      return result .. ellipsis_str
    end
  end
  error("unreachable")
end

return M
