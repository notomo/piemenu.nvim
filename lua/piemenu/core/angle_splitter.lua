local listlib = require("piemenu.lib.list")
local Angle = require("piemenu.core.angle")

local AngleSplitter = {}
AngleSplitter.__index = AngleSplitter

function AngleSplitter.new(start_angle, end_angle, angle_ranges, all_count)
  local tbl = {
    _start_angle = start_angle,
    _end_angle = end_angle,
    _angle_ranges = angle_ranges,
    _all_count = all_count,
  }
  return setmetatable(tbl, AngleSplitter)
end

function AngleSplitter.split(self)
  local angles = {}
  local distances = self._angle_ranges:distances()
  for i, count in ipairs(self:_counts(distances)) do
    local start_angle, end_angle = self._angle_ranges[i]:raw()
    vim.list_extend(angles, self:_split(start_angle, end_angle, count))
  end

  angles = vim.tbl_map(function(angle)
    return Angle.new_0_to_359(angle)
  end, angles)

  local is_start
  local start_angle = Angle.new_0_to_359(self._start_angle)
  if self._start_angle < self._end_angle then
    table.sort(angles, function(a, b)
      return a < b
    end)
    is_start = function(angle)
      return start_angle <= angle
    end
  else
    table.sort(angles, function(a, b)
      return a > b
    end)
    is_start = function(angle)
      return angle <= start_angle
    end
  end

  return listlib.circular_shift(angles, is_start)
end

function AngleSplitter._split(_, start_angle, end_angle, count)
  local angle_distance = math.max(-360, math.min(end_angle - start_angle, 360))
  local increment_angle
  if math.abs(angle_distance) ~= 360 and count > 1 then
    increment_angle = angle_distance / (count - 1)
  else
    increment_angle = angle_distance / count
  end
  if increment_angle > 180 then
    -- ex. if count == 2, distance == 330, space is insufficient between angle_a and angle_b.
    increment_angle = angle_distance / count
  end
  return vim.tbl_map(function(i)
    return start_angle + increment_angle * i
  end, vim.fn.range(count))
end

function AngleSplitter._counts(self, angles)
  local angle_sum = listlib.sum(angles)
  local count_rates = vim.tbl_map(function(angle)
    return self._all_count * angle / angle_sum
  end, angles)

  local counts = vim.tbl_map(function(rate)
    return math.floor(rate)
  end, count_rates)

  local remain_count = self._all_count - listlib.sum(counts)
  if remain_count == 0 then
    return counts
  end

  local remains = vim
    .iter(count_rates)
    :enumerate()
    :map(function(i, rate)
      return {
        index = i,
        value = rate - math.floor(rate),
      }
    end)
    :totable()
  table.sort(remains, function(a, b)
    return a.value > b.value
  end)
  for _, remain in ipairs(remains) do
    counts[remain.index] = counts[remain.index] + 1
    remain_count = remain_count - 1
    if remain_count == 0 then
      break
    end
  end

  return counts
end

return AngleSplitter
