local cursorlib = require("piemenu.lib.cursor")
local validatelib = require("piemenu.lib.validate")

local M = {}

local Option = {}
Option.__index = Option
M.Option = Option

Option.nil_value = ""

Option.default = {
  start_angle = 0,
  increment_angle = 45,
  radius = 12.0,
  tile_width = 15,
  animation = {duration = 100},
  menus = Option.nil_value,
  position = Option.nil_value,
}

function Option.new(raw_opts)
  vim.validate({raw_opts = {raw_opts, "table"}})
  local default = vim.deepcopy(Option.default)
  for k, v in pairs(Option.default) do
    if v == Option.nil_value then
      default[k] = nil
    end
  end

  local data = vim.tbl_deep_extend("force", default, raw_opts)
  validatelib.greater_than_zero({
    increment_angle = data.increment_angle,
    radius = data.radius,
    tile_width = data.tile_width,
  })
  vim.validate({
    start_angle = {data.start_angle, "number"},
    animation = {data.animation, "table"},
    menus = {data.menus, "table", true},
    position = {data.position, "table", true},
  })

  local tbl = {_data = data}
  return setmetatable(tbl, Option)
end

function Option.all(self)
  return vim.deepcopy(self._data)
end

function Option.merge(self, raw_opts)
  return Option.new(vim.tbl_deep_extend("force", self:all(), raw_opts))
end

function Option.for_view(self)
  return {
    start_angle = self._data.start_angle,
    increment_angle = self._data.increment_angle,
    radius = self._data.radius,
    tile_width = self._data.tile_width,
    animation = self._data.animation,
    position = self._data.position or cursorlib.global_position(),
  }
end

return M
