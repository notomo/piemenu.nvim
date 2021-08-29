local Command = require("piemenu.command").Command

local M = {}

--- Start a piemenu.
--- @param name string: registered name by |piemenu.register()|
--- @param setting table|nil: |piemenu.nvim-setting|
function M.start(name, setting)
  Command.new("start", name, setting)
end

--- Highlight a current hovered menu.
function M.highlight()
  Command.new("highlight")
end

--- Execute a current hovered menu's action and close all.
function M.finish()
  Command.new("finish")
end

--- Close all displayed menus.
function M.cancel()
  Command.new("cancel")
end

--- Register a piemenu setting.
--- @param name string: key to lookup pimenu setting
--- @param setting table: |piemenu.nvim-setting|
function M.register(name, setting)
  Command.new("register", name, setting)
end

--- Clear a registered piemenu setting.
--- @param name string: registered name by |piemenu.register()|
function M.clear(name)
  Command.new("clear", name)
end

--- Clear all registered piemenus settings.
function M.clear_all()
  Command.new("clear_all")
end

return M
