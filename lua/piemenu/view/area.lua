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

return M
