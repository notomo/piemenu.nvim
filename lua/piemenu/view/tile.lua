local CircleRange = require("piemenu.core.circle_range").CircleRange
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

  local tiles = {}
  for angle = 0, 359, 45 do
    local menu = menus[#tiles + 1]
    if not menu then
      break
    end

    local tile = Tile.open(angle, position, menu)
    if tile then
      table.insert(tiles, tile)
    end
  end

  local tbl = {_tiles = tiles}
  return setmetatable(tbl, Tiles)
end

function Tiles.activate(self, position)
  for _, tile in ipairs(self._tiles) do
    tile:deactivate()
  end
  local tile = self:find(position)
  if tile then
    tile:activate()
  end
end

function Tiles.find(self, position)
  for _, tile in ipairs(self._tiles) do
    if tile:include(position) then
      return tile
    end
  end
  return nil
end

function Tiles.close(self)
  for _, tile in ipairs(self._tiles) do
    tile:close()
  end
end

function Tile.open(angle, origin_pos, menu)
  vim.validate({
    angle = {angle, "number"},
    origin_pos = {origin_pos, "table"},
    menu = {menu, "table"},
  })

  local radius = 12.0
  local width = 15
  local half_width = width / 2
  local height = 3
  local half_height = height / 2
  local max_col = vim.o.columns
  local max_row = vim.o.lines

  local rad = math.rad(angle)
  local origin_row, origin_col = unpack(origin_pos)
  local row = radius * math.sin(rad) + origin_row - half_height
  local col = radius * math.cos(rad) * 2 + origin_col - half_width -- *2 for row height and col width ratio
  if row <= 0 or col <= 0 or max_row <= row + height or max_col <= col + width then
    return nil
  end

  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, {menu:to_string()})
  vim.bo[bufnr].bufhidden = "wipe"
  vim.bo[bufnr].modifiable = false

  local window_id = vim.api.nvim_open_win(bufnr, false, {
    width = width - 2, -- for border
    height = height - 2, -- for border
    anchor = "NW",
    relative = "editor",
    row = row,
    col = col,
    external = false,
    focusable = false,
    style = "minimal",
    zindex = 51,
    border = {{" ", "PimenuNonCurrent"}},
  })
  vim.wo[window_id].winblend = 0

  local around_angle = 20
  local tbl = {
    _window_id = window_id,
    _menu = menu,
    _range = CircleRange.new(angle - around_angle, angle + around_angle),
    _origin_pos = origin_pos,
  }
  local self = setmetatable(tbl, Tile)
  self:deactivate()
  return self
end

function Tile.include(self, position)
  return self._range:include(self._origin_pos, position)
end

function Tile.close(self)
  windowlib.close(self._window_id)
end

function Tile.activate(self)
  vim.wo[self._window_id].winhighlight = "Normal:PimenuCurrent"
  vim.api.nvim_win_set_config(self._window_id, {border = {{" ", "PimenuCurrent"}}})
end

function Tile.deactivate(self)
  vim.wo[self._window_id].winhighlight = "Normal:PimenuNonCurrent"
  vim.api.nvim_win_set_config(self._window_id, {border = {{" ", "PimenuNonCurrent"}}})
end

function Tile.execute_action(self)
  self._menu:execute_action()
end

vim.cmd("highlight default link PimenuCurrent Todo")
vim.cmd("highlight default link PimenuNonCurrent NormalFloat")

return M
