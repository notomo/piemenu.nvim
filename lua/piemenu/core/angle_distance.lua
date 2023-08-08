local Angle0To360 = require("piemenu.core.angle_with_offset").Angle0To360

local AngleDistance = {}

function AngleDistance.new(angle, angle_next)
  local d = Angle0To360.new(angle_next) - Angle0To360.new(angle)
  if d <= 0 then
    return d + 360
  end
  return d
end

return AngleDistance
