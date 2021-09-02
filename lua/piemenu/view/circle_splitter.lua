local AngleHolders = require("piemenu.view.angle_holder").AngleHolders

local M = {}

local CircleSplitter = {}
CircleSplitter.__index = CircleSplitter
M.CircleSplitter = CircleSplitter

function CircleSplitter.new(start_angle, end_angle, allocate)
  vim.validate({
    start_angle = {start_angle, "number"},
    end_angle = {end_angle, "number"},
    allocate = {allocate, "function"},
  })
  local tbl = {_start_angle = start_angle, _end_angle = end_angle, _allocate = allocate}
  return setmetatable(tbl, CircleSplitter)
end

CircleSplitter._retry_max_count = 5

function CircleSplitter.split(self, items)
  vim.validate({items = {items, "table"}})

  local angle_holders = AngleHolders.new()

  local retry_items = {}
  local item_increment_angle = self._end_angle / #items
  for i, item in ipairs(items) do
    local angle = self._start_angle + item_increment_angle * (i - 1)
    local allocated = self._allocate(angle, item)
    if allocated then
      angle_holders = angle_holders:add(angle, allocated)
    else
      table.insert(retry_items, item)
    end
  end

  for i = 1, self._retry_max_count do
    if #retry_items == 0 then
      break
    end
    local increment_angle = math.max(item_increment_angle / math.pow(2, i), 1)
    retry_items = self:_retry(retry_items, angle_holders, increment_angle)
  end

  return angle_holders:sorted()
end

function CircleSplitter._retry(self, items, angle_holders, increment_angle)
  local retry_items = {}

  for _, item in ipairs(items) do
    local ok = false
    for angle = self._start_angle, self._end_angle - 1, increment_angle do
      if angle_holders:exists(angle) then
        goto continue
      end

      local allocated = self._allocate(angle, item)
      if allocated then
        angle_holders = angle_holders:add(angle, allocated)
        ok = true
        break
      end

      ::continue::
    end
    if not ok then
      table.insert(retry_items, item)
    end
  end

  return retry_items
end

return M
