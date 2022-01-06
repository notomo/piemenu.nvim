local AngleRanges = require("piemenu.core.angle_range").AngleRanges
local AngleSplitter = require("piemenu.core.angle_splitter").AngleSplitter
local AngleDistance = require("piemenu.core.angle_distance").AngleDistance
local Animation = require("piemenu.view.animation").Animation
local TileArea = require("piemenu.view.area").TileArea
local Tile = require("piemenu.view.tile").Tile
local listlib = require("piemenu.lib.list")

local M = {}

local CircleTiles = {}
CircleTiles.__index = CircleTiles
M.CircleTiles = CircleTiles

function CircleTiles.open(defined_menus, view_setting)
  vim.validate({ defined_menus = { defined_menus, "table" }, view_setting = { view_setting, "table" } })

  local start_angle = view_setting.start_angle
  local end_angle = view_setting.end_angle

  local radius = view_setting.radius
  local tile_height = 3
  local tile_width = view_setting.tile_width
  local origin_pos = view_setting.position
  local overflow_angle_ranges = TileArea.new(start_angle, end_angle):calculate_overflow(
    radius,
    origin_pos,
    tile_width,
    tile_height
  )

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

  for i, e in ipairs(listlib.tri_circular(angles)) do
    local prev_angle, current_angle, next_angle = unpack(e)

    prev_angle = AngleDistance.new(prev_angle, current_angle) / 2
    next_angle = AngleDistance.new(current_angle, next_angle) / 2
    if prev_angle + next_angle > 180 then
      prev_angle = math.min(90, prev_angle)
      next_angle = math.min(90, next_angle)
    end

    local menu = menus[i]
    if not menu:is_empty() then
      local tile, move = Tile.open(
        menu,
        current_angle,
        prev_angle,
        next_angle,
        radius,
        tile_width,
        tile_height,
        origin_pos
      )
      table.insert(tiles, tile)
      table.insert(moves, move)
    end
  end

  Animation.new(moves, view_setting.animation.duration):start()

  local tbl = { _tiles = tiles }
  return setmetatable(tbl, CircleTiles), nil
end

function CircleTiles.activate(self, position)
  for _, tile in ipairs(self._tiles) do
    tile:deactivate()
  end
  local tile = self:find(position)
  if tile then
    tile:activate()
  end
end

function CircleTiles.find(self, position)
  for _, tile in ipairs(self._tiles) do
    if tile:include(position) then
      return tile
    end
  end
  return nil
end

function CircleTiles.close(self)
  for _, tile in ipairs(self._tiles) do
    tile:close()
  end
end

return M
