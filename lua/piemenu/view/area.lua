local Angle = require("piemenu.core.angle").Angle

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

function TileArea.calc_overflow_angle_ranges(self, radius, origin_pos, width, height)
  local angle_ranges = {}
  local directions = {
    {0, self._max_col - origin_pos[2], width / 2 + radius}, -- +radius for row height and col width ratio
    {90, self._max_row - origin_pos[1], height / 2},
    {180, self._min_col - origin_pos[2], width / 2 + radius},
    {270, self._min_row - origin_pos[1], height / 2},
  }
  for _, dir in ipairs(directions) do
    local base_angle, distance, extend_radius = unpack(dir)
    local rad = math.acos(math.abs(distance) / (radius + extend_radius))
    if rad == rad then -- not nan
      local angle = Angle.from_radian(rad)
      table.insert(angle_ranges, {base_angle - angle, base_angle + angle})
    end
  end
  return angle_ranges
end

return M
