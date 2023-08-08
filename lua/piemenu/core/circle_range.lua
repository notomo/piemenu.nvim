local Angle = require("piemenu.core.angle")
local Angle0To360 = require("piemenu.core.angle_with_offset").Angle0To360

local CircleRange = {}
CircleRange.__index = CircleRange

function CircleRange.new(start_angle, end_angle)
  local tbl = { _s = Angle0To360.new(start_angle), _e = Angle0To360.new(end_angle) }
  return setmetatable(tbl, CircleRange)
end

function CircleRange.include(self, p1, p2)
  local x = p2[2] - p1[2]
  local y = p2[1] - p1[1]
  local rad = math.atan(y / x * 2) -- *2 for row height and col width ratio
  local raw_angle = Angle.from_radian(rad)
  if x < 0 then
    raw_angle = raw_angle + 180
  end

  local angle = Angle0To360.new(raw_angle)
  if self._s <= self._e then
    return self._s <= angle and angle <= self._e
  end
  return (0 <= angle and angle <= self._e) or (self._s <= angle and angle <= 360)
end

return CircleRange
