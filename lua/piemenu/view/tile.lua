local CircleRange = require("piemenu.core.circle_range").CircleRange
local angle_0_to_360 = require("piemenu.core.circle_range").angle_0_to_360
local Animation = require("piemenu.view.animation").Animation
local Move = require("piemenu.view.animation").Move
local TileArea = require("piemenu.view.area").TileArea
local CircleSplitter = require("piemenu.view.circle_splitter").CircleSplitter
local CircleTriList = require("piemenu.view.circle_tri_list").CircleTriList
local windowlib = require("piemenu.lib.window")
local stringlib = require("piemenu.lib.string")
local highlightlib = require("piemenu.lib.highlight")
local vim = vim

local M = {}

local diff_angle = function(angle, angle_next)
  angle = angle_0_to_360(angle)
  angle_next = angle_0_to_360(angle_next)
  local d = angle_next - angle
  if d <= 0 then
    return d + 360
  end
  return d
end

local Tiles = {}
Tiles.__index = Tiles
M.Tiles = Tiles

local TileSpace = {}
TileSpace.__index = TileSpace
M.TileSpace = TileSpace

local Tile = {}
Tile.__index = Tile
M.Tile = Tile

function Tiles.open(defined_menus, view_setting)
  vim.validate({defined_menus = {defined_menus, "table"}, view_setting = {view_setting, "table"}})

  local tile_height = 3
  local area = TileArea.new()
  local splitter = CircleSplitter.new(view_setting.start_angle, view_setting.end_angle, function(angle)
    return TileSpace.allocate(area, angle, view_setting.radius, view_setting.tile_width, tile_height, view_setting.position)
  end)

  local tiles, moves = {}, {}
  local spaces = splitter:split(defined_menus:count())
  local tri_list = CircleTriList.new(spaces)
  for i, tri in ipairs(tri_list) do
    local prev_holder, current_holder, next_holder = unpack(tri)

    local prev_angle = diff_angle(prev_holder.angle, current_holder.angle) / 2
    local next_angle = diff_angle(current_holder.angle, next_holder.angle) / 2
    if prev_angle + next_angle > 180 then
      prev_angle = math.min(90, prev_angle)
      next_angle = math.min(90, next_angle)
    end

    local space = current_holder.inner
    local menu = defined_menus[i]
    if not menu:is_empty() then
      local tile, move = space:open_tile(menu, prev_angle, next_angle)
      table.insert(tiles, tile)
      table.insert(moves, move)
    end
  end

  Animation.new(moves, view_setting.animation.duration):start()

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

function TileSpace.empty()
  return setmetatable({}, TileSpace)
end

function TileSpace.allocate(area, angle, radius, width, height, origin_pos)
  local half_width = width / 2
  local half_height = height / 2
  local rad = math.rad(angle)
  local origin_row, origin_col = unpack(origin_pos)
  local row = radius * math.sin(rad) + origin_row - half_height
  local col = radius * math.cos(rad) * 2 + origin_col - half_width -- *2 for row height and col width ratio

  if not area:include(row, col, width, height) then
    return nil
  end

  local tbl = {
    _angle = angle,
    _row = row,
    _col = col,
    _width = width,
    _half_width = half_width,
    _height = height,
    _origin_pos = origin_pos,
  }
  return setmetatable(tbl, TileSpace)
end

function TileSpace.open_tile(self, menu, prev_angle, next_angle)
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, {
    stringlib.ellipsis(menu:to_string(), self._width - 2),
  })
  vim.bo[bufnr].bufhidden = "wipe"
  vim.bo[bufnr].modifiable = false

  local y = self._origin_pos[1]
  local x = self._origin_pos[2] - self._half_width
  local window_id = vim.api.nvim_open_win(bufnr, false, {
    width = self._width - 2, -- for border
    height = self._height - 2, -- for border
    anchor = "NW",
    relative = "editor",
    row = y,
    col = x,
    external = false,
    focusable = false,
    style = "minimal",
    zindex = 51,
    border = {{" ", "PimenuNonCurrent"}},
  })
  vim.wo[window_id].winblend = 0

  local tbl = {
    _window_id = window_id,
    _menu = menu,
    _range = CircleRange.new(self._angle - prev_angle, self._angle + next_angle),
    _origin_pos = self._origin_pos,
  }
  local tile = setmetatable(tbl, Tile)
  tile:deactivate()
  return tile, Move.new(window_id, {y, x}, {self._row + 1, self._col})
end

function Tile.include(self, position)
  return self._range:include(self._origin_pos, position)
end

function Tile.close(self)
  windowlib.close(self._window_id)
end

function Tile.activate(self)
  vim.wo[self._window_id].winhighlight = "Normal:PiemenuCurrent"
  vim.api.nvim_win_set_config(self._window_id, {border = {{" ", "PiemenuCurrentBorder"}}})
end

function Tile.deactivate(self)
  vim.wo[self._window_id].winhighlight = "Normal:PiemenuNonCurrent"
  vim.api.nvim_win_set_config(self._window_id, {border = {{" ", "PiemenuNonCurrentBorder"}}})
end

function Tile.execute_action(self)
  return self._menu:execute_action()
end

local force = false
M.hl_groups = {
  highlightlib.link("PiemenuNonCurrent", force, "NormalFloat"),
  highlightlib.link("PiemenuNonCurrentBorder", force, "NormalFloat"),
  highlightlib.define("PiemenuCurrent", force, {
    ctermfg = "Normal",
    guifg = "Normal",
    ctermbg = "Normal",
    guibg = "Normal",
    gui = "bold,undercurl",
  }),
  highlightlib.link("PiemenuCurrentBorder", force, "NormalFloat"),
}

return M
