local M = {}

local AngleWithOffset = {}
M.AngleWithOffset = AngleWithOffset

function AngleWithOffset.new(base_angle, angle)
  local min = math.floor(base_angle / 360) * 360
  local max = (math.floor(base_angle / 360) + 1) * 360
  if min <= angle and angle <= max then
    return angle
  end
  return (angle % 360) + min
end

function AngleWithOffset.shift(base_angle, angle)
  local offset
  if base_angle < 0 then
    offset = math.floor(base_angle / 360) * 360
  else
    offset = math.ceil(base_angle / 360) * 360
  end
  return angle + offset
end

local Angle0To360 = {}
M.Angle0To360 = Angle0To360

function Angle0To360.new(angle)
  return AngleWithOffset.new(0, angle)
end

local Angle0To359 = {}
M.Angle0To359 = Angle0To359

function Angle0To359.new(angle)
  return angle % 360
end

return M
