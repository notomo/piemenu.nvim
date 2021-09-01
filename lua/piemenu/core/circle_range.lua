local M = {}

local angle_0_to_360 = function(raw_angle)
  vim.validate({raw_angle = {raw_angle, "number"}})
  return (raw_angle + 360) % 360
end
M.angle_0_to_360 = angle_0_to_360

local CircleRange = {}
CircleRange.__index = CircleRange
M.CircleRange = CircleRange

function CircleRange.new(start_angle, end_angle)
  local tbl = {_s = angle_0_to_360(start_angle), _e = angle_0_to_360(end_angle)}
  return setmetatable(tbl, CircleRange)
end

function CircleRange.include(self, p1, p2)
  local x = p2[2] - p1[2]
  local y = p2[1] - p1[1]
  local rad = math.atan(y / x * 2) -- *2 for row height and col width ratio
  local raw_angle = rad * 180 / math.pi
  if x < 0 then
    raw_angle = raw_angle + 180
  end

  local angle = angle_0_to_360(raw_angle)
  if self._s <= self._e then
    return self._s <= angle and angle <= self._e
  end
  return (0 <= angle and angle <= self._e) or (self._s <= angle and angle <= 360)
end

return M
