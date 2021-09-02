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

function CircleSplitter.split(self, items)
  vim.validate({items = {items, "table"}})

  local angle_holders = AngleHolders.new()

  local retry_items = {}
  local item_increment_angle = self._end_angle / #items
  for i, item in ipairs(items) do
    local angle = self._start_angle + (i - 1) * item_increment_angle
    local allocated = self._allocate(angle, item)
    if allocated then
      angle_holders = angle_holders:add(angle, allocated)
    else
      table.insert(retry_items, item)
    end
  end

  local increment_angle = math.max(item_increment_angle / 3, 1)
  for _, item in ipairs(retry_items) do
    for angle = self._start_angle, self._end_angle - 1, increment_angle do
      if angle_holders:exists(angle) then
        goto continue
      end

      local allocated = self._allocate(angle, item)
      if allocated then
        angle_holders = angle_holders:add(angle, allocated)
        break
      end

      ::continue::
    end
  end

  return angle_holders:sorted()
end

return M
