local Angle = {}

function Angle.from_radian(rad)
  return rad * 180 / math.pi
end

function Angle.new_with_offset(base_angle, angle)
  local min = math.floor(base_angle / 360) * 360
  local max = (math.floor(base_angle / 360) + 1) * 360
  if min <= angle and angle <= max then
    return angle
  end
  return (angle % 360) + min
end

function Angle.shift_with_offset(base_angle, angle)
  local offset
  if base_angle < 0 then
    offset = math.floor(base_angle / 360) * 360
  else
    offset = math.ceil(base_angle / 360) * 360
  end
  return angle + offset
end

function Angle.new_0_to_360(angle)
  return Angle.new_with_offset(0, angle)
end

function Angle.new_0_to_359(angle)
  return angle % 360
end

function Angle.distance(angle, angle_next)
  local d = Angle.new_0_to_360(angle_next) - Angle.new_0_to_360(angle)
  if d <= 0 then
    return d + 360
  end
  return d
end

return Angle
