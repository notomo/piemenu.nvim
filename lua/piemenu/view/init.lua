local Menus = require("piemenu.core.menu").Menus
local Background = require("piemenu.view.background").Background
local Tiles = require("piemenu.view.tile").Tiles
local repository = require("piemenu.lib.repository").Repository.new("view")

local M = {}

local View = {}
View.__index = View
M.View = View

function View.open(name, position)
  vim.validate({name = {name, "string"}, position = {position, "table", true}})

  local menus, err = Menus.new(name)
  if err then
    return err
  end
  position = position or vim.api.nvim_win_get_cursor(0)

  local background = Background.open(name)
  local tiles = Tiles.open(menus, position)

  local tbl = {name = name, _position = position, _background = background, _tiles = tiles}
  local self = setmetatable(tbl, View)

  repository:set(background.window_id, self)
end

function View.hover(self)
  self:_click()
  -- TODO
end

function View.select(self)
  print("select TODO")
  self:close()
end

function View.close(self)
  self._background:close()
  self._tiles:close()
  repository:delete(self._background.window_id)
end

function View.get(window_id)
  vim.validate({window_id = {window_id, "number"}})
  return repository:get(window_id)
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
  vim.validate({name = {name, "string"}})
  for _, view in repository:all() do
    if view.name == name then
      return view
    end
  end
  return nil
end

local mouse = vim.api.nvim_eval("\"\\<LeftMouse>\"")
-- replace on testing
function View._click()
  vim.cmd("normal! " .. mouse)
end

return M
