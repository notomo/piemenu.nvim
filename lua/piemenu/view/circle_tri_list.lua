local M = {}

local CircleTriList = {}
CircleTriList.__index = CircleTriList
M.CircleTriList = CircleTriList

function CircleTriList.new(items)
  vim.validate({items = {items, "table"}})

  local tri_list = {}
  for i, item in ipairs(items) do
    local prev_item = items[i - 1]
    if not prev_item then
      prev_item = items[#items]
    end

    local next_item = items[i + 1]
    if not next_item then
      next_item = items[1]
    end

    table.insert(tri_list, {prev_item, item, next_item})
  end
  return tri_list
end

return M

