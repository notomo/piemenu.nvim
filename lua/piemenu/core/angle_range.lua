local Angle = require("piemenu.core.angle")

local M = {}

local AngleRanges = {}
M.AngleRanges = AngleRanges

local AngleRange = {}
AngleRange.__index = AngleRange
M.AngleRange = AngleRange

function AngleRanges.new(raw_angle_ranges)
  local tbl = { _angle_ranges = raw_angle_ranges }
  return setmetatable(tbl, AngleRanges)
end

function AngleRanges.new_one(s, e)
  return AngleRanges.new({ AngleRange.new(s, e) })
end

function AngleRanges.from_raw(raw)
  return AngleRanges.new(vim.tbl_map(function(r)
    return AngleRange.new(unpack(r))
  end, raw))
end

function AngleRanges.__index(self, k)
  if type(k) == "number" then
    return self._angle_ranges[k]
  end
  return AngleRanges[k]
end

function AngleRanges.raw(self)
  return vim.tbl_map(function(angle_range)
    return { angle_range:raw() }
  end, self._angle_ranges)
end

function AngleRanges.list(self)
  return vim.tbl_map(function(angle_range)
    return angle_range
  end, self._angle_ranges)
end

function AngleRanges.join(self)
  if #self._angle_ranges <= 1 then
    return self
  end

  local new_angle_ranges = {}
  local first_start_angle = self._angle_ranges[1]:raw()
  local last_start_angle, last_end_angle = self._angle_ranges[#self._angle_ranges]:raw()
  if Angle.new_0_to_359(first_start_angle) ~= Angle.new_0_to_359(last_end_angle) then
    return self
  end

  for _, angle_range in ipairs(self._angle_ranges) do
    local s, e = angle_range:raw()
    table.insert(new_angle_ranges, {
      Angle.shift_with_offset(last_start_angle - s, s),
      Angle.shift_with_offset(last_start_angle - e, e),
    })
  end
  table.remove(new_angle_ranges, #new_angle_ranges)
  new_angle_ranges[1][1] = last_start_angle

  return AngleRanges.new(vim.tbl_map(function(angles)
    return AngleRange.new(unpack(angles))
  end, new_angle_ranges))
end

function AngleRanges.distances(self)
  return vim.tbl_map(function(angle_range)
    return angle_range:distance()
  end, self._angle_ranges)
end

function AngleRanges.exclude(self, angle_ranges)
  local excluded = self
  for _, raw_range in ipairs(angle_ranges:raw()) do
    local s, e = unpack(raw_range)
    local raw_ranges = {}
    for _, angle_range in ipairs(excluded:list()) do
      vim.list_extend(raw_ranges, angle_range:exclude(s, e):join():list())
    end
    excluded = AngleRanges.new(raw_ranges):join()
  end
  return excluded
end

function AngleRange.new(s, e)
  local is_ascending = s < e
  local small, large
  if is_ascending then
    small, large = s, e
  else
    small, large = e, s
  end
  local tbl = { _s = s, _e = e, _small = small, _large = large, _is_ascending = is_ascending }
  return setmetatable(tbl, AngleRange)
end

function AngleRange.new_0_to_360(s, e)
  local new_s = Angle.new_0_to_360(s)
  return AngleRange.new(new_s, new_s + e - s)
end

function AngleRange.sorted_ascending(self)
  return AngleRange.new(self._small, self._large)
end

function AngleRange.sorted(self, is_ascending)
  if is_ascending then
    return AngleRange.new(self._small, self._large)
  end
  return AngleRange.new(self._large, self._small)
end

function AngleRange.raw(self)
  return self._s, self._e
end

function AngleRange.exclude(self, s, e)
  s, e = Angle.new_with_offset(self._small, s), Angle.new_with_offset(self._small, e)
  s, e = AngleRange.new(s, e):sorted_ascending():raw()

  -- contain
  if s <= self._small and self._large <= e then
    return AngleRanges.new({})
  end

  -- outside
  if self._large < s or e < self._small then
    return AngleRanges.new({ self })
  end

  -- include right edge
  if self._small < s and self._large <= e then
    return AngleRanges.new({ AngleRange.new(self._small, s - 1):sorted(self._is_ascending) })
  end

  -- include left edge
  if s <= self._small and e < self._large then
    return AngleRanges.new({ AngleRange.new(e + 1, self._large):sorted(self._is_ascending) })
  end

  -- contained
  if self._small < s and e < self._large then
    local a = AngleRange.new(self._small, s - 1)
    local b = AngleRange.new(e + 1, self._large)
    if self._is_ascending then
      return AngleRanges.new({ a, b })
    end
    return AngleRanges.new({ b:sorted(false), a:sorted(false) })
  end

  return AngleRanges.new({})
end

function AngleRange.distance(self)
  return Angle.distance(self._small, self._large)
end

function AngleRange.contain(self, angle)
  angle = Angle.new_with_offset(self._small, angle)
  return self._small <= angle and angle <= self._large
end

return M
