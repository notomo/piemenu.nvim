local cursorlib = require("piemenu.lib.cursor")
local validatelib = require("piemenu.lib.validate")

local M = {}

local Setting = {}
Setting.__index = Setting
M.Setting = Setting

Setting.nil_value = ""

Setting.default = {
  start_angle = 0,
  end_angle = 360,
  radius = 12.0,
  tile_width = 15,
  animation = {duration = 100},
  menus = Setting.nil_value,
  position = Setting.nil_value,
}

function Setting.new(raw_setting)
  vim.validate({raw_setting = {raw_setting, "table"}})
  local default = vim.deepcopy(Setting.default)
  for k, v in pairs(Setting.default) do
    if v == Setting.nil_value then
      default[k] = nil
    end
  end

  local data = vim.tbl_deep_extend("force", default, raw_setting)
  validatelib.greater_than_zero({radius = data.radius, tile_width = data.tile_width})
  vim.validate({
    start_angle = {data.start_angle, "number"},
    end_angle = {data.end_angle, "number"},
    animation = {data.animation, "table"},
    menus = {data.menus, "table", true},
    position = {data.position, "table", true},
  })

  local tbl = {_data = data}
  return setmetatable(tbl, Setting)
end

function Setting.all(self)
  return vim.deepcopy(self._data)
end

function Setting.merge(self, raw_setting)
  return Setting.new(vim.tbl_deep_extend("force", self:all(), raw_setting))
end

function Setting.for_view(self)
  return {
    start_angle = self._data.start_angle,
    end_angle = self._data.end_angle,
    radius = self._data.radius,
    tile_width = self._data.tile_width,
    animation = self._data.animation,
    position = self._data.position or cursorlib.global_position(),
  }
end

return M
