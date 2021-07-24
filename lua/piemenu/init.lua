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

function M.register(info)
  Command.new("register", info)
end

function M.clear()
  Command.new("clear")
end

return M
