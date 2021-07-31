local M = {}

local Menus = {}
M.Menus = Menus

function Menus.new(name)
  local menus, err = require("piemenu.core.setting").find_menus(name)
  if err then
    return nil, err
  end

  local tbl = {_menus = menus}
  return setmetatable(tbl, Menus), nil
end

function Menus.__index(self, k)
  if type(k) == "number" then
    return self._menus[k]
  end
  return Menus[k]
end

return M
