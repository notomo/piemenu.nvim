local EmptyMenu = require("piemenu.core.menu").EmptyMenu
local CircleRange = require("piemenu.core.circle_range").CircleRange
local Move = require("piemenu.view.animation").Move
local windowlib = require("piemenu.lib.window")
local stringlib = require("piemenu.lib.string")
local highlightlib = require("piemenu.lib.highlight")

local M = {}

local Tiles = {}
Tiles.__index = Tiles
M.Tiles = Tiles

local Tile = {}
Tile.__index = Tile
M.Tile = Tile

function Tiles.open(defined_menus, view_setting)
  vim.validate({defined_menus = {defined_menus, "table"}, view_setting = {view_setting, "table"}})

  local position = view_setting.position
  local start_angle = view_setting.start_angle
  local end_angle = view_setting.end_angle
  local radius = view_setting.radius
  local tile_width = view_setting.tile_width
  local animation = view_setting.animation

  local menu_increment_angle = end_angle / defined_menus:count()
  local space_increment_angle = math.max(menu_increment_angle / 3, 1)
  local around_angle = space_increment_angle * 0.5

  local open = function(angle, menu)
    return Tile.open(angle, radius, tile_width, position, menu, around_angle, animation)
  end

  local menus = {}
  local index = 0
  for angle = start_angle, end_angle - 1, space_increment_angle do
    local next_menu_angle = menu_increment_angle * index
    if angle < next_menu_angle then
      table.insert(menus, EmptyMenu.new())
      goto continue
    end

    index = index + 1
    table.insert(menus, defined_menus[index])

    ::continue::
  end

  local tiles = {}
  local spacer_angles = {}
  local i = 1
  for angle = start_angle, end_angle - 1, space_increment_angle do
    local menu = menus[i]
    if not menu then
      break
    end
    if menu:is_empty() then
      i = i + 1
      table.insert(spacer_angles, angle)
      goto continue
    end

    local tile = open(angle, menu)
    if not tile then
      tile = Tiles._fallback_to_spacer(open, menu, spacer_angles)
    end
    if tile then
      table.insert(tiles, tile)
      i = i + 1
    end
    ::continue::
  end

  local tbl = {_tiles = tiles}
  return setmetatable(tbl, Tiles)
end

function Tiles._fallback_to_spacer(open, menu, angles)
  for i, angle in ipairs(angles) do
    local tile = open(angle, menu)
    if tile then
      table.remove(angles, i)
      return tile
    end
  end
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

function Tile.open(angle, radius, width, origin_pos, menu, around_angle, animation)
  vim.validate({
    angle = {angle, "number"},
    radius = {radius, "number"},
    width = {width, "number"},
    origin_pos = {origin_pos, "table"},
    menu = {menu, "table"},
    animation = {animation, "table"},
  })

  local half_width = width / 2
  local height = 3
  local half_height = height / 2
  local max_col = vim.o.columns
  local max_row = vim.o.lines

  local rad = math.rad(angle)
  local origin_row, origin_col = unpack(origin_pos)
  local row = radius * math.sin(rad) + origin_row - half_height
  local col = radius * math.cos(rad) * 2 + origin_col - half_width -- *2 for row height and col width ratio
  if row <= -1 or col <= -1 or max_row <= row + height or max_col <= col + width then
    return nil
  end

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

  Move.start({y, x}, {row + 1, col}, animation.duration, function(new_x, new_y)
    if not vim.api.nvim_win_is_valid(window_id) then
      return false
    end
    vim.api.nvim_win_set_config(window_id, {row = new_y, col = new_x, relative = "editor"})
    return true
  end)

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
