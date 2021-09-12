local Angle = require("piemenu.core.angle").Angle
local AngleRange = require("piemenu.core.angle_range").AngleRange
local AngleRanges = require("piemenu.core.angle_range").AngleRanges

local M = {}

local TileArea = {}
TileArea.__index = TileArea
M.TileArea = TileArea

function TileArea.new(start_angle, end_angle)
  local tbl = {
    _min_row = -1,
    _min_col = -1,
    _max_col = vim.o.columns,
    _max_row = vim.o.lines - vim.o.cmdheight - 1,
    _angle_range = AngleRange.new(start_angle, end_angle),
  }
  return setmetatable(tbl, TileArea)
end

function TileArea.calculate_overflow(self, radius, origin_pos, width, height)
  local raw_angle_ranges = {}
  local directions = {
    {0, self._max_col - origin_pos[2], radius * 2 + width / 2, 15}, -- radius * 2 for row height and col width ratio
    {90, self._max_row - origin_pos[1], radius + height / 2, 0},
    {180, self._min_col - origin_pos[2], radius * 2 + width / 2, 15},
    {270, self._min_row - origin_pos[1], radius + height / 2, 5}, -- HACK: 5?
  }
  for _, e in ipairs(directions) do
    local base_angle, distance, r, ext_angle = unpack(e)
    if not self._angle_range:contain(base_angle) then
      goto continue
    end

    local rad = math.acos(math.abs(distance) / r)
    if rad == rad then -- not nan
      local angle = Angle.from_radian(rad) + ext_angle
      table.insert(raw_angle_ranges, AngleRange.new_0_to_360(base_angle - angle, base_angle))
      table.insert(raw_angle_ranges, AngleRange.new_0_to_360(base_angle, base_angle + angle))
    end

    ::continue::
  end
  return AngleRanges.new(raw_angle_ranges)
end

return M
