local Command = require("piemenu.command").Command

local M = {}

--- Start a piemenu.
--- @param name string: registered name by |piemenu.register()|
--- @param opts table: Todo
function M.start(name, opts)
  Command.new("start", name, opts)
end

--- Highlight a current selected menu.
function M.hover()
  Command.new("hover")
end

--- Select a menu and close all.
function M.select()
  Command.new("select")
end

--- Close all displayed menus.
function M.cancel()
  Command.new("cancel")
end

--- Register a piemenu setting.
--- @param name string: Todo
--- @param info table: Todo
function M.register(name, info)
  Command.new("register", name, info)
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
