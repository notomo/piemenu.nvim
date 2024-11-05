local Menus = require("piemenu.core.menu")
local Background = require("piemenu.view.background")
local CircleTiles = require("piemenu.view.circle")

local views = {}

local View = {}
View.__index = View

--- @param name string
--- @param raw_setting PiemenuSetting
function View.open(name, raw_setting)
  local menus
  if not raw_setting.menus then
    menus = Menus.find(name)
  else
    menus = Menus.parse(name, raw_setting)
  end
  if type(menus) == "string" then
    local err = menus
    return err
  end

  local setting = menus.setting:merge(raw_setting)
  if type(setting) == "string" then
    local err = setting
    return err
  end

  local view_setting = setting:for_view()
  local background = Background.open(name, view_setting.position)
  local tiles, open_err = CircleTiles.open(menus, view_setting)
  if open_err then
    background:close()
    return open_err
  end

  local tbl = { name = name, _background = background, _tiles = tiles }
  local self = setmetatable(tbl, View)

  views[background.window_id] = self
end

local mouse_is_on_tabline = function()
  local showtabline = vim.o.showtabline
  if showtabline == 0 then
    return false
  end
  local tab_count = vim.fn.tabpagenr("$")
  if tab_count == 1 and showtabline == 1 then
    return false
  end
  local screen_row = vim.fn.getmousepos().screenrow
  if screen_row > 1 then
    return false
  end
  return true
end

function View.highlight(self)
  if mouse_is_on_tabline() then
    return
  end
  local position = self._background:get_position()
  if not position then
    return
  end
  self._tiles:activate(position)
end

function View.finish(self)
  local position = self._background:get_position()
  if not position then
    return
  end
  local tile = self._tiles:find(position)

  self:close()

  if tile then
    return tile:execute_action()
  end
end

function View.close(self)
  self._background:close()
  self._tiles:close()
  views[self._background.window_id] = nil
end

--- @param window_id integer
function View.get(window_id)
  return views[window_id]
end

function View.current()
  local window_id = vim.api.nvim_get_current_win()
  local view = View.get(window_id)
  if not view then
    return "not found view"
  end
  return view
end

--- @param name string
function View.find(name)
  for _, view in pairs(views) do
    if view.name == name then
      return view
    end
  end
  return nil
end

return View
