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

  -- TODO
  local tile = Tile.open(unpack(position))

  local tbl = {_menus = menus, _tiles = {tile}}
  return setmetatable(tbl, Tiles)
end

function Tiles.close(self)
  for _, tile in ipairs(self._tiles) do
    tile:close()
  end
end

function Tile.open(row, col)
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.bo[bufnr].bufhidden = "wipe"
  vim.bo[bufnr].modifiable = false

  local window_id = vim.api.nvim_open_win(bufnr, false, {
    width = 20,
    height = 4,
    anchor = "SW",
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
