local View = require("piemenu.view").View
local messagelib = require("piemenu.lib.message")

local M = {}

local Command = {}
Command.__index = Command
M.Command = Command

function Command.new(name, ...)
  local args = {...}
  local f = function()
    return Command[name](unpack(args))
  end

  local ok, msg = xpcall(f, debug.traceback)
  if not ok then
    return messagelib.error(msg)
  elseif msg then
    return messagelib.warn(msg)
  end
  return nil
end

function Command.start(name, raw_setting)
  vim.validate({name = {name, "string"}, setting = {raw_setting, "table", true}})
  raw_setting = raw_setting or {}

  local already = View.find(name)
  if already then
    return nil
  end

  return View.open(name, raw_setting)
end

function Command.highlight()
  local view, err = View.current()
  if err then
    return err
  end
  view:highlight()
end

function Command.finish()
  local view, err = View.current()
  if err then
    return err
  end
  return view:finish()
end

function Command.cancel()
  local view, err = View.current()
  if err then
    return err
  end
  view:close()
end

function Command.close(name)
  local view = View.find(name)
  if not view then
    return
  end
  view:close()
end

function Command.register(name, setting)
  return require("piemenu.core.menu").Menus.register(name, setting)
end

function Command.clear(name)
  require("piemenu.core.menu").Menus.clear(name)
end

function Command.clear_all()
  require("piemenu.core.menu").Menus.clear_all()
end

return M
