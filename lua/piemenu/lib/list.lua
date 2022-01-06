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

function M.tri_circular(items)
  vim.validate({ items = { items, "table" } })
  local list = {}
  for i, item in ipairs(items) do
    local prev_item = items[i - 1] or items[#items]
    local next_item = items[i + 1] or items[1]
    table.insert(list, { prev_item, item, next_item })
  end
  return list
end

function M.circular_shift(items, is_start)
  vim.validate({ items = { items, "table" }, is_start = { is_start, "function" } })
  local start_index = 1
  for i, item in ipairs(items) do
    if is_start(item) then
      start_index = i
      break
    end
  end

  local new_items = {}
  for i = start_index, #items do
    table.insert(new_items, items[i])
  end
  for i = 1, start_index - 1 do
    table.insert(new_items, items[i])
  end

  return new_items
end

return M
