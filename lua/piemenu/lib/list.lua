local M = {}

function M.sum(items)
  local all = 0
  for _, item in ipairs(items) do
    all = all + item
  end
  return all
end

function M.enumurate(items, f)
  local new_items = {}
  for i, item in ipairs(items) do
    table.insert(new_items, f(i, item))
  end
  return new_items
end

return M
