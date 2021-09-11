local M = {}

function M.greater_than(n, value)
  vim.validate({n = {n, "number"}})
  return {
    value,
    function(x)
      return type(x) == "number" and x > n
    end,
    "greater than " .. n,
  }
end

function M.equal_or_greater_than(n, value)
  vim.validate({n = {n, "number"}})
  return {
    value,
    function(x)
      return type(x) == "number" and x >= n
    end,
    "equal or greater than " .. n,
  }
end

function M.not_negative(value)
  return {
    value,
    function(x)
      return type(x) == "number" and x >= 0
    end,
    "not negative number",
  }
end

function M.positon_or_nil(value)
  return {
    value,
    function(p)
      if not p then
        return true
      end
      return p[1] >= 1 and p[2] >= 1
    end,
    "greater than {1, 1} or nil",
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
