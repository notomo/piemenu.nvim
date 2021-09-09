local Angle = require("piemenu.core.angle").Angle
local AngleRange = require("piemenu.core.angle_range").AngleRange
local AngleRanges = require("piemenu.core.angle_range").AngleRanges

local M = {}

local TileArea = {}
TileArea.__index = TileArea
M.TileArea = TileArea

function TileArea.new()
  local tbl = {_min_row = -1, _min_col = -1, _max_col = vim.o.columns, _max_row = vim.o.lines}
  return setmetatable(tbl, TileArea)
end

function TileArea.include(self, row, col, width, height)
  if row <= self._min_row or self._max_row <= row + height then
    return false
  end
  return self._min_col <= col and col + width < self._max_col
end

function TileArea.calculate_overflow(self, radius, origin_pos, width, height)
  local raw_angle_ranges = {}
  local directions = {
    {90, self._max_row - origin_pos[1], height / 2},
    {180, self._min_col - origin_pos[2], width / 2 + radius},
    {270, self._min_row - origin_pos[1], height / 2},
    {360, self._max_col - origin_pos[2], width / 2 + radius}, -- +radius for row height and col width ratio
  }
  for _, e in ipairs(directions) do
    local base_angle, distance, extend_radius = unpack(e)
    local rad = math.acos(math.abs(distance) / (radius + extend_radius))
    if rad == rad then -- not nan
      local angle = Angle.from_radian(rad)
      table.insert(raw_angle_ranges, AngleRange.new_0_to_360(base_angle - angle, base_angle))
      table.insert(raw_angle_ranges, AngleRange.new_0_to_360(base_angle, base_angle + angle))
    end
  end
  return AngleRanges.new(raw_angle_ranges)
end

return M
