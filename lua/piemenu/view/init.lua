local Menus = require("piemenu.core.menu").Menus
local Background = require("piemenu.view.background").Background
local CircleTiles = require("piemenu.view.circle").CircleTiles

local views = {}

local M = {}

local View = {}
View.__index = View
M.View = View

function View.open(name, raw_setting)
  vim.validate({
    name = { name, "string" },
    raw_setting = { raw_setting, "table" },
  })

  local menus, err
  if not raw_setting.menus then
    menus, err = Menus.find(name)
  else
    menus, err = Menus.parse(name, raw_setting)
  end
  if err then
    return err
  end

  local setting, merge_err = menus.setting:merge(raw_setting)
  if merge_err then
    return merge_err
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
  local position = self._background:click()
  if not position then
    return
  end
  self._tiles:activate(position)
end

function View.finish(self)
  local position = self._background:click()
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

function View.get(window_id)
  vim.validate({ window_id = { window_id, "number" } })
  return views[window_id]
end

function View.current()
  local window_id = vim.api.nvim_get_current_win()
  local view = View.get(window_id)
  if not view then
    return nil, "not found view"
  end
  return view, nil
end

function View.find(name)
  vim.validate({ name = { name, "string" } })
  for _, view in pairs(views) do
    if view.name == name then
      return view
    end
  end
  return nil
end

M.hl_groups = require("piemenu.view.tile").hl_groups

return M
