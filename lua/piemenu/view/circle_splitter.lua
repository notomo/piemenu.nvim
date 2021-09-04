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

  local count = #items
  local angle_diff = math.max(-360, math.min(self._end_angle - self._start_angle, 360))
  if math.abs(angle_diff) ~= 360 then
    count = count - 1
  end
  local item_increment_angle = angle_diff / count

  local remains = {}
  for i, item in ipairs(items) do
    local target_angle = self._start_angle + item_increment_angle * (i - 1)
    table.insert(remains, {item, target_angle})
  end

  local angle_holders = AngleHolders.new()
  for i = 0, self._retry_max_count do
    if #remains == 0 then
      break
    end
    local increment_angle = item_increment_angle / math.pow(2, i)
    remains, angle_holders = self:_retry(remains, angle_holders, increment_angle)
  end

  return angle_holders:sorted(self._end_angle > self._start_angle)
end

function CircleSplitter._retry(self, remains, angle_holders, increment_angle)
  local next_retries = {}

  for _, remain in ipairs(remains) do
    local ok = false
    local item, target_angle = unpack(remain)
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
    return self._distance(target_angle, a) < self._distance(target_angle, b)
  end)
  return angles
end

function CircleSplitter._distance(angle_a, angle_b)
  local a_rad = math.rad(angle_a)
  local a_x = math.cos(a_rad)
  local a_y = math.sin(a_rad)

  local b_rad = math.rad(angle_b)
  local b_x = math.cos(b_rad)
  local b_y = math.sin(b_rad)
  return math.sqrt(math.pow(a_x - b_x, 2) + math.pow(a_y - b_y, 2))
end

return M