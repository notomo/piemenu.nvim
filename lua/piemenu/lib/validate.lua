local M = {}

function M.greater_than_zero(value)
  return {
    value,
    function(x)
      return x > 0
    end,
    "greater than 0",
  }
end

function M.positon_or_nil(value)
  return {
    value,
    function(p)
      if not p then
        return true
      end
      return p[1] >= 1 and p[2] >= 0
    end,
    "greater than {1, 0} or nil",
  }
end

function M.validate(tbl)
  local errs = {}
  for key, value in pairs(tbl) do
    local ok, result = pcall(vim.validate, {[key] = value})
    if not ok then
      local msg = vim.split(result, "\n")[1]
      if type(value[1]) == "table" then
        msg = ("%s: %s"):format(msg, vim.inspect(value[1]))
      end
      table.insert(errs, msg)
    end
  end
  if #errs ~= 0 then
    return table.concat(errs, "\n")
  end
end

return M
