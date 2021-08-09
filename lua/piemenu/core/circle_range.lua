local M = {}

local CircleRange = {}
CircleRange.__index = CircleRange
M.CircleRange = CircleRange

function CircleRange.new(start_angle, end_angle)
  start_angle = (start_angle + 360) % 360
  end_angle = (end_angle + 360) % 360
  local tbl = {_s = start_angle, _e = end_angle}
  return setmetatable(tbl, CircleRange)
end

function CircleRange._include(self, angle)
  if self._e < self._s then
    return (0 <= angle and angle <= self._e) or (self._s <= angle and angle <= 360)
  end
  return self._s <= angle and angle <= self._e
end

function CircleRange.include(self, p1, p2)
  local x = p2[2] - p1[2]
  local y = p2[1] - p1[1]
  local rad = math.atan(y / x)
  local angle = rad * 180 / math.pi
  if x < 0 then
    angle = angle + 180
  end
  angle = (angle + 360) % 360
  return self:_include(angle)
end

return M
