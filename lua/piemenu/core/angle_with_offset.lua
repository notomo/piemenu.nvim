local M = {}

local AngleWithOffset = {}
M.AngleWithOffset = AngleWithOffset

function AngleWithOffset.new(base_angle, angle)
  local offset = math.floor(base_angle / 360) * 360
  return (angle % 360) + offset
end

local Angle0To360 = {}
M.Angle0To360 = Angle0To360

function Angle0To360.new(angle)
  return AngleWithOffset.new(0, angle)
end

return M
