local M = {}

local plugin_name = vim.split((...):gsub("%.", "/"), "/", true)[1]
local prefix = ("[%s] "):format(plugin_name)

function M.error(err)
  vim.validate({ err = { err, "string" } })
  error(prefix .. err)
end

function M.warn(msg)
  vim.validate({ msg = { msg, "string" } })
  vim.api.nvim_echo({ { prefix .. msg, "WarningMsg" } }, true, {})
end

return M
