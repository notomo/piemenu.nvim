local cursorlib = require("piemenu.lib.cursor")
local validatelib = require("piemenu.lib.validate")

local Setting = {}
Setting.__index = Setting

Setting.nil_value = {}

local AnimationSetting = {}
AnimationSetting.default = { duration = 100 }

Setting.default = {
  start_angle = 0,
  end_angle = 360,
  radius = 12.0,
  tile_width = 15,
  animation = AnimationSetting.default,
  menus = Setting.nil_value,
  position = Setting.nil_value,
}

function Setting.new(raw_setting)
  vim.validate({ raw_setting = { raw_setting, "table" } })

  local default = Setting.default_values()
  local data = vim.tbl_deep_extend("force", default, raw_setting)

  local base_err = validatelib.validate({
    radius = validatelib.greater_than(0, data.radius),
    tile_width = validatelib.equal_or_greater_than(1 + 2, data.tile_width), -- + 2 for border
    position = validatelib.positon_or_nil(data.position),
    start_angle = { data.start_angle, "number" },
    end_angle = { data.end_angle, "number" },
    menus = { data.menus, "table", true },
    animation = { data.animation, "table" },
  })
  if base_err then
    return nil, base_err
  end

  local anim_err = validatelib.validate({
    ["animation.duration"] = validatelib.not_negative(data.animation.duration),
  })
  if anim_err then
    return nil, anim_err
  end

  local tbl = { _data = data }
  return setmetatable(tbl, Setting), nil
end

function Setting.default_values()
  local default = vim.deepcopy(Setting.default)
  for k, v in pairs(Setting.default) do
    if v == Setting.nil_value then
      default[k] = nil
    end
  end
  return default
end

function Setting.merge(self, raw_setting)
  return Setting.new(vim.tbl_deep_extend("force", vim.deepcopy(self._data), raw_setting))
end

function Setting.for_view(self)
  return {
    start_angle = self._data.start_angle,
    end_angle = self._data.end_angle,
    radius = self._data.radius,
    tile_width = math.floor(self._data.tile_width),
    animation = self._data.animation,
    position = self._data.position or cursorlib.global_position(),
  }
end

return Setting
