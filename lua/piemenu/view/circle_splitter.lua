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

function CircleSplitter.split(self, count)
  vim.validate({count = {count, "number"}})

  local angle_diff = math.max(-360, math.min(self._end_angle - self._start_angle, 360))
  local increment_angle
  if math.abs(angle_diff) ~= 360 then
    increment_angle = angle_diff / (count - 1)
  else
    increment_angle = angle_diff / count
  end

  local angle_holders = AngleHolders.new()
  local angles = vim.tbl_map(function(i)
    return self._start_angle + increment_angle * i
  end, vim.fn.range(count))
  for i = 0, self._retry_max_count do
    if #angles == 0 then
      break
    end
    angles, angle_holders = self:_try_allocate(angles, angle_holders, increment_angle / math.pow(2, i))
  end

  return angle_holders:sorted(self._end_angle > self._start_angle)
end

function CircleSplitter._try_allocate(self, angles, angle_holders, increment_angle)
  local next_angles = {}

  for _, target_angle in ipairs(angles) do
    local ok = false
    for _, angle in ipairs(self:_sorted_angles(target_angle, increment_angle)) do
      if angle_holders:exists(angle) then
        goto continue
      end

      local allocated = self._allocate(angle)
      if allocated then
        angle_holders = angle_holders:add(angle, allocated)
        ok = true
        break
      end

      ::continue::
    end
    if not ok then
      table.insert(next_angles, target_angle)
    end
  end

  return next_angles, angle_holders
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
