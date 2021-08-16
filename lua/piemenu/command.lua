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

function Command.start(name, opts)
  vim.validate({name = {name, "string"}, opts = {opts, "table", true}})
  opts = opts or {}

  local already = View.find(name)
  if already then
    return nil
  end

  return View.open(name, opts.position, opts.start_angle)
end

function Command.hover()
  local view, err = View.current()
  if err then
    return err
  end
  view:hover()
end

function Command.select()
  local view, err = View.current()
  if err then
    return err
  end
  return view:select()
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

function Command.register(name, info)
  require("piemenu.core.menu").Menus.register(name, info)
end

function Command.clear(name)
  require("piemenu.core.menu").Menus.clear(name)
end

function Command.clear_all()
  require("piemenu.core.menu").Menus.clear_all()
end

return M
