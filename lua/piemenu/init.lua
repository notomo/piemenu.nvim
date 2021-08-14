local Command = require("piemenu.command").Command

local M = {}

function M.start(name, opts)
  Command.new("start", name, opts)
end

function M.hover()
  Command.new("hover")
end

function M.select()
  Command.new("select")
end

function M.cancel()
  Command.new("cancel")
end

function M.register(name, info)
  Command.new("register", name, info)
end

function M.clear(name)
  Command.new("clear", name)
end

function M.clear_all()
  Command.new("clear_all")
end

return M
