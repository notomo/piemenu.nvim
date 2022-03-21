local View = require("piemenu.view").View
local ShowError = require("piemenu.vendor.error_handler").for_show_error()

function ShowError.start(name, raw_setting)
  vim.validate({ name = { name, "string" }, setting = { raw_setting, "table", true } })
  raw_setting = raw_setting or {}

  local already = View.find(name)
  if already then
    return nil
  end

  return View.open(name, raw_setting)
end

function ShowError.highlight()
  local view, err = View.current()
  if err then
    return err
  end
  view:highlight()
end

function ShowError.finish()
  local view, err = View.current()
  if err then
    return err
  end
  return view:finish()
end

function ShowError.cancel()
  local view, err = View.current()
  if err then
    return err
  end
  view:close()
end

function ShowError.close(name)
  local view = View.find(name)
  if not view then
    return
  end
  view:close()
end

function ShowError.register(name, setting)
  return require("piemenu.core.menu").Menus.register(name, setting)
end

function ShowError.clear(name)
  require("piemenu.core.menu").Menus.clear(name)
end

function ShowError.clear_all()
  require("piemenu.core.menu").Menus.clear_all()
end

return ShowError:methods()
