local M = {}

--- @class PiemenuSetting
--- @field animation PiemenuAnimation? |PiemenuAnimation|
--- @field menus (PiemenuMenu|{})[]? If the element is empty table, the menu is not opened but used as spacer. If the circle is clipped by editor area, spacers are omitted. |PiemenuMenu|
--- @field position integer[]? {row, col}
--- @field radius integer? piemenu circle radius, default: 12
--- @field start_angle integer? angle to open first tile, default: 0
--- @field end_angle integer? angle to limit open tile, default: 360
--- @field tile_width integer? menu tile width, default: 15

--- @class PiemenuAnimation
--- @field duration integer? open animation duration milliseconds. default: 100

--- @class PiemenuMenu
--- @field action fun() action triggered by |piemenu.nvim-piemenu.finish()|
--- @field text string displayed text in menu tile

--- Start a piemenu.
--- @param name string: registered name by |piemenu.register()|
--- @param setting PiemenuSetting: |PiemenuSetting|
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
--- @param setting PiemenuSetting: |PiemenuSetting|
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
