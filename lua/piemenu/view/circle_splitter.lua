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

  local count = #items
  local angle_diff = math.max(-360, math.min(self._end_angle - self._start_angle, 360))
  if math.abs(angle_diff) ~= 360 then
    count = count - 1
  end
  local item_increment_angle = angle_diff / count

  local retires = {}
  for i, item in ipairs(items) do
    local angle = self._start_angle + item_increment_angle * (i - 1)
    local allocated = self._allocate(angle, item)
    if allocated then
      angle_holders = angle_holders:add(angle, allocated)
    else
      table.insert(retires, {item, angle})
    end
  end

  for i = 1, self._retry_max_count do
    if #retires == 0 then
      break
    end
    local increment_angle = item_increment_angle / math.pow(2, i)
    retires, angle_holders = self:_retry(retires, angle_holders, increment_angle)
  end

  return angle_holders:sorted(self._end_angle > self._start_angle)
end

function CircleSplitter._retry(self, retries, angle_holders, increment_angle)
  local next_retries = {}

  for _, retry in ipairs(retries) do
    local ok = false
    local item, target_angle = unpack(retry)
    for _, angle in ipairs(self:_sorted_angles(target_angle, increment_angle)) do
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
      table.insert(next_retries, {item, target_angle})
    end
  end

  return next_retries, angle_holders
end

function CircleSplitter._sorted_angles(self, target_angle, increment_angle)
  local angles = {}
  for angle = self._start_angle, self._end_angle, increment_angle do
    table.insert(angles, angle)
  end
  table.sort(angles, function(a, b)
    return math.abs(target_angle - a) < math.abs(target_angle - b)
  end)
  return angles
end

return M
