local M = {}

--- Start a piemenu.
--- @param name string: registered name by |piemenu.register()|
--- @param setting table|nil: |piemenu.nvim-setting|
function M.start(name, setting)
  require("piemenu.command").start(name, setting)
end

--- Highlight a current hovered menu.
function M.highlight()
  require("piemenu.command").highlight()
end

--- Execute a current hovered menu's action and close all.
function M.finish()
  require("piemenu.command").finish()
end

--- Close all displayed menus.
function M.cancel()
  require("piemenu.command").cancel()
end

--- Register a piemenu setting.
--- @param name string: key to lookup pimenu setting
--- @param setting table: |piemenu.nvim-setting|
function M.register(name, setting)
  require("piemenu.command").register(name, setting)
end

--- Clear a registered piemenu setting.
--- @param name string: registered name by |piemenu.register()|
function M.clear(name)
  require("piemenu.command").clear(name)
end

--- Clear all registered piemenus settings.
function M.clear_all()
  require("piemenu.command").clear_all()
end

return M
