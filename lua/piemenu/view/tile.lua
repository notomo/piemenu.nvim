local windowlib = require("piemenu.lib.window")

local M = {}

local Tiles = {}
Tiles.__index = Tiles
M.Tiles = Tiles

local Tile = {}
Tile.__index = Tile
M.Tile = Tile

function Tiles.open(menus, position)
  vim.validate({menus = {menus, "table"}, position = {position, "table"}})
  local origin_row, origin_col = unpack(position)

  local tiles = {}
  local radius = 12.0
  local width = 10
  local half_width = width / 2
  local height = 3
  local half_height = height / 2
  local max_col = vim.o.columns
  local max_row = vim.o.lines
  for angle = 0, 359, 45 do
    local rad = math.rad(angle)
    local row = radius * math.sin(rad) + origin_row - half_width
    local col = radius * math.cos(rad) * 2 + origin_col - half_height -- *2 for row height and col width ratio
    if row <= 0 or col <= 0 or max_row <= row + height or max_col <= col + width then
      goto continue
    end
    table.insert(tiles, Tile.open(row, col, width, height))
    ::continue::
  end

  local tbl = {_menus = menus, _tiles = tiles}
  return setmetatable(tbl, Tiles)
end

function Tiles.close(self)
  for _, tile in ipairs(self._tiles) do
    tile:close()
  end
end

function Tile.open(row, col, width, height)
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.bo[bufnr].bufhidden = "wipe"
  vim.bo[bufnr].modifiable = false

  local window_id = vim.api.nvim_open_win(bufnr, false, {
    width = width,
    height = height,
    anchor = "NW",
    relative = "editor",
    row = row,
    col = col,
    external = false,
    focusable = false,
    style = "minimal",
    zindex = 51,
  })
  vim.wo[window_id].winblend = 0

  local tbl = {_window_id = window_id}
  return setmetatable(tbl, Tile)
end

function Tile.close(self)
  windowlib.close(self._window_id)
end

return M
