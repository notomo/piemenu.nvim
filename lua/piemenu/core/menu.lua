local Setting = require("piemenu.core.setting")

local Menu = {}
Menu.__index = Menu

function Menu.new(action, text)
  vim.validate({ action = { action, "function" }, text = { text, "string" } })
  local tbl = { _action = action, _text = vim.split(text, "\n", { plain = true })[1] }
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

function EmptyMenu.new()
  local tbl = {}
  return setmetatable(tbl, EmptyMenu)
end

function EmptyMenu.is_empty(_)
  return true
end

local Menus = {}

function Menus.new(name, raw_menus, setting)
  vim.validate({
    name = { name, "string" },
    raw_menus = { raw_menus, "table" },
    setting = { setting, "table" },
  })
  local tbl = { name = name, setting = setting, _menus = raw_menus }
  return setmetatable(tbl, Menus)
end

function Menus.parse(name, raw_setting)
  vim.validate({ name = { name, "string" }, setting = { raw_setting, "table" } })

  local raw_menus = {}
  for _, menu in ipairs(raw_setting.menus or {}) do
    if vim.tbl_isempty(menu) then
      table.insert(raw_menus, EmptyMenu.new())
    else
      table.insert(raw_menus, Menu.new(menu.action, menu.text))
    end
  end

  local setting, err = Setting.new(raw_setting)
  if err then
    return err
  end

  return Menus.new(name, raw_menus, setting)
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

function Menus.exclude_empty(self)
  local raw_menus = vim
    .iter(self._menus)
    :filter(function(menu)
      return not menu:is_empty()
    end)
    :totable()
  return Menus.new(self.name, raw_menus, self.setting)
end

local _menus = {}

function Menus.find(name)
  vim.validate({ name = { name, "string" } })
  local menus = _menus[name]
  if not menus or menus:is_empty() then
    return ("no menus for `%s`"):format(name)
  end
  return menus
end

function Menus.register(name, setting)
  local menus = Menus.parse(name, setting)
  if type(menus) == "string" then
    local err = menus
    return err
  end
  _menus[name] = menus
end

function Menus.clear(name)
  vim.validate({ name = { name, "string" } })
  _menus[name] = nil
end

function Menus.clear_all()
  for name in pairs(_menus) do
    _menus[name] = nil
  end
end

function Menus.__index(self, k)
  if type(k) == "number" then
    return self._menus[k]
  end
  return Menus[k]
end

return Menus
