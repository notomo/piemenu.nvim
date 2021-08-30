local Setting = require("piemenu.core.setting").Setting
local repository = require("piemenu.lib.repository").Repository.new("menu")

local M = {}

local Menu = {}
Menu.__index = Menu
M.Menu = Menu

function Menu.new(action, text)
  vim.validate({action = {action, "function"}, text = {text, "string"}})
  local tbl = {_action = action, _text = vim.split(text, "\n", true)[1]}
  return setmetatable(tbl, Menu)
end

function Menu.execute_action(self)
  local ok, err = pcall(self._action)
  if not ok then
    return err
  end
  return nil
end

function Menu.to_string(self)
  return self._text
end

function Menu.is_empty(_)
  return false
end

local EmptyMenu = {}
EmptyMenu.__index = EmptyMenu
M.EmptyMenu = EmptyMenu

function EmptyMenu.new()
  local tbl = {}
  return setmetatable(tbl, EmptyMenu)
end

function EmptyMenu.is_empty(_)
  return true
end

local Menus = {}
M.Menus = Menus

function Menus.new(name, setting)
  vim.validate({name = {name, "string"}, setting = {setting, "table"}})

  local menus = {}
  for _, menu in ipairs(setting.menus or {}) do
    if vim.tbl_isempty(menu) then
      table.insert(menus, EmptyMenu.new())
    else
      table.insert(menus, Menu.new(menu.action, menu.text))
    end
  end

  local tbl = {name = name, setting = Setting.new(setting), _menus = menus}
  return setmetatable(tbl, Menus)
end

function Menus.is_empty(self)
  for _, m in ipairs(self._menus) do
    if not m:is_empty() then
      return false
    end
  end
  return true
end

function Menus.count(self)
  return #self._menus
end

function Menus.find(name)
  vim.validate({name = {name, "string"}})
  local menus = repository:get(name)
  if not menus or menus:is_empty() then
    return nil, ("no menus for `%s`"):format(name)
  end
  return menus, nil
end

function Menus.register(name, setting)
  local menus = Menus.new(name, setting)
  repository:set(name, menus)
end

function Menus.clear(name)
  vim.validate({name = {name, "string"}})
  repository:delete(name)
end

function Menus.clear_all()
  repository:delete_all()
end

function Menus.__index(self, k)
  if type(k) == "number" then
    return self._menus[k]
  end
  return Menus[k]
end

return M
