local AngleWithOffset = require("piemenu.core.angle_with_offset").AngleWithOffset
local Angle0To360 = require("piemenu.core.angle_with_offset").Angle0To360

local M = {}

local AngleRanges = {}
AngleRanges.__index = AngleRanges
M.AngleRanges = AngleRanges

local AngleRange = {}
AngleRange.__index = AngleRange
M.AngleRange = AngleRange

function AngleRanges.new(raw_angle_ranges)
  local tbl = {_angle_ranges = raw_angle_ranges}
  return setmetatable(tbl, AngleRanges)
end

function AngleRanges.raw(self)
  return vim.tbl_map(function(angle_range)
    return {angle_range:raw()}
  end, self._angle_ranges)
end

function AngleRanges.join(self)
  if #self._angle_ranges <= 1 then
    return self
  end

  local new_angle_ranges = {}
  local first_angle = self._angle_ranges[1]:raw()
  local last_start_angle, last_angle = self._angle_ranges[#self._angle_ranges]:raw()
  if Angle0To360.new(first_angle) == Angle0To360.new(last_angle) then
    for _, angle_range in ipairs(self._angle_ranges) do
      local s, e = angle_range:raw()
      table.insert(new_angle_ranges, {
        AngleWithOffset.new(last_angle, s),
        AngleWithOffset.new(last_angle, e),
      })
    end
    table.remove(new_angle_ranges, #new_angle_ranges)
    new_angle_ranges[1][1] = last_start_angle
  end

  return AngleRanges.new(vim.tbl_map(function(angles)
    return AngleRange.new(unpack(angles))
  end, new_angle_ranges))
end

function AngleRange.new(s, e)
  local is_ascending = s < e
  local small, large
  if is_ascending then
    small, large = s, e
  else
    small, large = e, s
  end
  local tbl = {_s = s, _e = e, _small = small, _large = large, _is_ascending = is_ascending}
  return setmetatable(tbl, AngleRange)
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

function AngleRange.contain(self, angle)
  angle = AngleWithOffset.new(self._s, angle)
  return self._small <= angle and angle <= self._large
end

function AngleRange.exclude(self, s, e)
  s, e = AngleWithOffset.new(self._small, s), AngleWithOffset.new(self._small, e)
  s, e = AngleRange.new(s, e):sorted_ascending():raw()
  if s <= self._small and self._large <= e then
    return AngleRanges.new({})
  end
  if self._large < s or e < self._small then
    return AngleRanges.new({self})
  end
  if self._small < s and self._large <= e then
    return AngleRanges.new({AngleRange.new(self._small, s - 1):sorted(self._is_ascending)})
  end
  if s <= self._small and e < self._large then
    return AngleRanges.new({AngleRange.new(e + 1, self._large):sorted(self._is_ascending)})
  end
  if self._small < s and e < self._large then
    local a = AngleRange.new(self._small, s - 1)
    local b = AngleRange.new(e + 1, self._large)
    if self._is_ascending then
      return AngleRanges.new({a, b})
    end
    return AngleRanges.new({b:sorted(false), a:sorted(false)})
  end
  return AngleRanges.new({})
end

return M
