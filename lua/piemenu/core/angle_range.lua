local AngleWithOffset = require("piemenu.core.angle_with_offset").AngleWithOffset

local M = {}

local AngleRange = {}
AngleRange.__index = AngleRange
M.AngleRange = AngleRange

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
    return {}
  end
  if self._large < s or e < self._small then
    return {self}
  end
  if self._small < s and self._large <= e then
    return {AngleRange.new(self._small, s - 1):sorted(self._is_ascending)}
  end
  if s <= self._small and e < self._large then
    return {AngleRange.new(e + 1, self._large):sorted(self._is_ascending)}
  end
  if self._small < s and e < self._large then
    local a = AngleRange.new(self._small, s - 1)
    local b = AngleRange.new(e + 1, self._large)
    if self._is_ascending then
      return {a, b}
    end
    return {b:sorted(false), a:sorted(false)}
  end
  return {}
end

return M
