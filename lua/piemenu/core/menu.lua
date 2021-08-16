local repository = require("piemenu.lib.repository").Repository.new("menu")

local M = {}

local Menu = {}
Menu.__index = Menu
M.Menu = Menu

function Menu.new(action, icon, description)
  vim.validate({
    action = {action, "function"},
    icon = {icon, "string", true},
    description = {description, "string", true},
  })
  local tbl = {_action = action, _icon = icon or "", _description = description or ""}
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
  return ("%s %s"):format(self._icon, self._description)
end

local Menus = {}
M.Menus = Menus

function Menus.new(name, info)
  vim.validate({name = {name, "string"}, info = {info, "table"}})

  local menus = {}
  for _, menu in ipairs(info.menus or {}) do
    table.insert(menus, Menu.new(menu.action, menu.icon, menu.description))
  end

  local tbl = {name = name, _menus = menus, start_angle = info.start_angle or 0}
  return setmetatable(tbl, Menus)
end

function Menus.find(name)
  vim.validate({name = {name, "string"}})
  local menus = repository:get(name)
  if not menus then
    return nil, "no menus for " .. name
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
