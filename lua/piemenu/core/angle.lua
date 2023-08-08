local Angle = {}

function Angle.from_radian(rad)
  return rad * 180 / math.pi
end

return Angle
