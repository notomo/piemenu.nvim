local View = require("piemenu.view").View

local M = {}

function M.start(name, raw_setting)
  vim.validate({ name = { name, "string" }, setting = { raw_setting, "table", true } })
  raw_setting = raw_setting or {}

  local already = View.find(name)
  if already then
    return nil
  end

  local err = View.open(name, raw_setting)
  if err then
    require("piemenu.vendor.misclib.message").error(err)
  end
end

function M.highlight()
  local view, err = View.current()
  if err then
    require("piemenu.vendor.misclib.message").error(err)
  end
  view:highlight()
end

function M.finish()
  local view, err = View.current()
  if err then
    require("piemenu.vendor.misclib.message").error(err)
  end
  local finish_err = view:finish()
  if finish_err then
    require("piemenu.vendor.misclib.message").error(finish_err)
  end
end

function M.cancel()
  local view, err = View.current()
  if err then
    require("piemenu.vendor.misclib.message").error(err)
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
  local err = require("piemenu.core.menu").Menus.register(name, setting)
  if err then
    require("piemenu.vendor.misclib.message").error(err)
  end
end

function M.clear(name)
  require("piemenu.core.menu").Menus.clear(name)
end

function M.clear_all()
  require("piemenu.core.menu").Menus.clear_all()
end

return M
