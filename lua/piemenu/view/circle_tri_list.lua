local M = {}

local CircleTriList = {}
CircleTriList.__index = CircleTriList
M.CircleTriList = CircleTriList

function CircleTriList.new(items)
  vim.validate({items = {items, "table"}})

  local list = {}
  for i, item in ipairs(items) do
    local prev_item = items[i - 1] or items[#items]
    local next_item = items[i + 1] or items[1]
    table.insert(list, {prev_item, item, next_item})
  end
  return list
end

return M
