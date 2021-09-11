local CircleRange = require("piemenu.core.circle_range").CircleRange
local AngleRanges = require("piemenu.core.angle_range").AngleRanges
local AngleSplitter = require("piemenu.core.angle_splitter").AngleSplitter
local AngleDistance = require("piemenu.core.angle_distance").AngleDistance
local Animation = require("piemenu.view.animation").Animation
local Move = require("piemenu.view.animation").Move
local TileArea = require("piemenu.view.area").TileArea
local CircleTriList = require("piemenu.view.circle_tri_list").CircleTriList
local windowlib = require("piemenu.lib.window")
local stringlib = require("piemenu.lib.string")
local highlightlib = require("piemenu.lib.highlight")
local vim = vim

local M = {}

local Tiles = {}
Tiles.__index = Tiles
M.Tiles = Tiles

local Tile = {}
Tile.__index = Tile
M.Tile = Tile

function Tiles.open(defined_menus, view_setting)
  vim.validate({defined_menus = {defined_menus, "table"}, view_setting = {view_setting, "table"}})

  local start_angle = view_setting.start_angle
  local end_angle = view_setting.end_angle

  local radius = view_setting.radius
  local tile_height = 3
  local tile_width = view_setting.tile_width
  local origin_pos = view_setting.position
  local area = TileArea.new()
  local overflow_angle_ranges = area:calculate_overflow(radius, origin_pos, tile_width, tile_height)

  local menus
  if #overflow_angle_ranges:list() > 0 then
    menus = defined_menus:exclude_empty()
  else
    menus = defined_menus
  end

  local tiles, moves = {}, {}
  local angle_ranges = AngleRanges.new_one(start_angle, end_angle):exclude(overflow_angle_ranges):join()
  local angles = AngleSplitter.new(start_angle, end_angle, angle_ranges, menus:count()):split()
  if #angles == 0 then
    return nil, ("could not open: radius=%s"):format(radius)
  end

  for i, e in ipairs(CircleTriList.new(angles)) do
    local prev_angle, current_angle, next_angle = unpack(e)

    prev_angle = AngleDistance.new(prev_angle, current_angle) / 2
    next_angle = AngleDistance.new(current_angle, next_angle) / 2
    if prev_angle + next_angle > 180 then
      prev_angle = math.min(90, prev_angle)
      next_angle = math.min(90, next_angle)
    end

    local menu = menus[i]
    if not menu:is_empty() then
      local tile, move = Tile.open(menu, current_angle, prev_angle, next_angle, radius, tile_width, tile_height, origin_pos)
      table.insert(tiles, tile)
      table.insert(moves, move)
    end
  end

  Animation.new(moves, view_setting.animation.duration):start()

  local tbl = {_tiles = tiles}
  return setmetatable(tbl, Tiles), nil
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

function Tile.open(menu, angle, prev_angle, next_angle, radius, width, height, origin_pos)
  local half_width = width / 2
  local half_height = height / 2
  local rad = math.rad(angle)
  local origin_row, origin_col = unpack(origin_pos)
  local row = radius * math.sin(rad) + origin_row - half_height
  local col = radius * math.cos(rad) * 2 + origin_col - half_width -- *2 for row height and col width ratio

  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, {stringlib.ellipsis(menu:to_string(), width - 2)})
  vim.bo[bufnr].bufhidden = "wipe"
  vim.bo[bufnr].modifiable = false

  local y = origin_pos[1]
  local x = origin_pos[2] - half_width
  local window_id = vim.api.nvim_open_win(bufnr, false, {
    width = width - 2, -- for border
    height = height - 2, -- for border
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
    _range = CircleRange.new(angle - prev_angle, angle + next_angle),
    _origin_pos = origin_pos,
  }
  local tile = setmetatable(tbl, Tile)
  tile:deactivate()
  return tile, Move.new(window_id, {y, x}, {row + 1, col})
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
