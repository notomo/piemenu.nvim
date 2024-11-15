local View = require("piemenu.view")

local M = {}

--- @param name string
--- @param raw_setting PiemenuSetting?
function M.start(name, raw_setting)
  raw_setting = raw_setting or {}

  local already = View.find(name)
  if already then
    return nil
  end

  local err = View.open(name, raw_setting)
  if err then
    error("[piemenu] " .. err, 0)
  end
end

function M.highlight()
  local view = View.current()
  if type(view) == "string" then
    local err = view
    error("[piemenu] " .. err, 0)
  end
  view:highlight()
end

function M.finish()
  local view = View.current()
  if type(view) == "string" then
    local err = view
    error("[piemenu] " .. err, 0)
  end
  local finish_err = view:finish()
  if finish_err then
    error("[piemenu] " .. finish_err, 0)
  end
end

function M.cancel()
  local view = View.current()
  if type(view) == "string" then
    local err = view
    error("[piemenu] " .. err, 0)
  end
  view:close()
end

function M.close(name)
  local view = View.find(name)
  if not view then
    return
  end
  view:close()
end

function M.register(name, setting)
  local err = require("piemenu.core.menu").register(name, setting)
  if err then
    error("[piemenu] " .. err, 0)
  end
end

function M.clear(name)
  require("piemenu.core.menu").clear(name)
end

function M.clear_all()
  require("piemenu.core.menu").clear_all()
end

return M
