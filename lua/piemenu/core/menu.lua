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

function Menus.new(name, info)
  vim.validate({name = {name, "string"}, info = {info, "table"}})

  local menus = {}
  for _, menu in ipairs(info.menus or {}) do
    if vim.tbl_isempty(menu) then
      table.insert(menus, EmptyMenu.new())
    else
      table.insert(menus, Menu.new(menu.action, menu.text))
    end
  end

  local tbl = {
    name = name,
    start_angle = info.start_angle,
    increment_angle = info.increment_angle,
    _menus = menus,
  }
  return setmetatable(tbl, Menus)
end

function Menus.find(name)
  vim.validate({name = {name, "string"}})
  local menus = repository:get(name)
  if not menus then
    return nil, ("no menus for `%s`"):format(name)
  end
  return menus, nil
end

function Menus.register(name, info)
  local menus = Menus.new(name, info)
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
