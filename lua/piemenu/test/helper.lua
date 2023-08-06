local helper = require("vusted.helper")
local plugin_name = helper.get_module_root(...)

helper.root = helper.find_plugin_root(plugin_name)

function helper.before_each()
end

function helper.after_each()
  helper.cleanup()
  helper.cleanup_loaded_modules(plugin_name)
end

function helper.set_lines(lines)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(lines, "\n"))
end

local asserts = require("vusted.assert").asserts
local asserters = require(plugin_name .. ".vendor.assertlib").list()
require(plugin_name .. ".vendor.misclib.test.assert").register(asserts.create, asserters)

asserts.create("exists_highlighted_window"):register(function(self)
  return function(_, args)
    local expected = args[1]
    self:set_positive(("window highlighted `%s` is not found"):format(expected))
    self:set_negative(("window highlighted `%s` is found"):format(expected))
    for _, window_id in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      local hls = vim.tbl_filter(function(hl)
        return vim.startswith(hl, "Normal:")
      end, vim.split(vim.wo[window_id].winhighlight, ",", { plain = true }))
      for _, hl in ipairs(hls) do
        local _, v = unpack(vim.split(hl, ":", { plain = true }))
        if v == expected then
          return true
        end
      end
    end
    return false
  end
end)

return helper
