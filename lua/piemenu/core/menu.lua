local M = {}

local Menus = {}
Menus.__index = Menus
M.Menus = Menus

function Menus.new(name)
  local menus, err = require("piemenu.core.setting").find_menus(name)
  if err then
    return nil, err
  end

  local tbl = {_menus = menus}
  return setmetatable(tbl, Menus), nil
end

return M
