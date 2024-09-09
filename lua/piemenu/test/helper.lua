local helper = require("vusted.helper")
local plugin_name = helper.get_module_root(...)

helper.root = helper.find_plugin_root(plugin_name)
vim.opt.packpath:prepend(vim.fs.joinpath(helper.root, "spec/.shared/packages"))
require("assertlib").register(require("vusted.assert").register)

function helper.before_each()
  ---@diagnostic disable-next-line: duplicate-set-field
  require("piemenu.view.background")._click = function() end
end

function helper.after_each()
  helper.cleanup()
  helper.cleanup_loaded_modules(plugin_name)
end

function helper.set_lines(lines)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(lines, "\n"))
end

local asserts = require("vusted.assert").asserts

asserts.create("exists_highlighted_window"):register(function(self)
  return function(_, args)
    local expected = args[1]
    self:set_positive(("window highlighted `%s` is not found"):format(expected))
    self:set_negative(("window highlighted `%s` is found"):format(expected))
    for _, window_id in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      local hls = vim
        .iter(vim.split(vim.wo[window_id].winhighlight, ",", { plain = true }))
        :filter(function(hl)
          return vim.startswith(hl, "Normal:")
        end)
        :totable()
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

function helper.typed_assert(assert)
  local x = require("assertlib").typed(assert)
  ---@cast x +{exists_highlighted_window:fun(want)}
  return x
end

return helper
