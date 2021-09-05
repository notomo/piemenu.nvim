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

function TileArea.include_circle(self, radius, origin_pos, width, height)
  local origin_x = origin_pos[2]
  local origin_y = origin_pos[1]
  for _, pos in ipairs({
    {origin_y, origin_x + radius},
    {origin_y + radius, origin_x},
    {origin_y, origin_x - radius},
    {origin_y - radius, origin_x},
  }) do
    local row, col = unpack(pos)
    local ok = self:include(row, col, width, height)
    if not ok then
      return false
    end
  end
  return true
end

return M
