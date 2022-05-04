local plugin_name = vim.split((...):gsub("%.", "/"), "/", true)[1]
local helper = require("vusted.helper")

helper.root = helper.find_plugin_root(plugin_name)

function helper.before_each()
  require("piemenu.view.background").Background._click = function() end
end

function helper.after_each()
  helper.cleanup()
  helper.cleanup_loaded_modules(plugin_name)
  print(" ")
end

function helper.set_lines(lines)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(lines, "\n"))
end

local asserts = require("vusted.assert").asserts

asserts.create("filetype"):register_eq(function()
  return vim.bo.filetype
end)

asserts.create("window_count"):register_eq(function()
  return vim.fn.tabpagewinnr(vim.fn.tabpagenr(), "$")
end)

asserts.create("exists_message"):register(function(self)
  return function(_, args)
    local expected = args[1]
    self:set_positive(("`%s` not found message"):format(expected))
    self:set_negative(("`%s` found message"):format(expected))
    local messages = vim.split(vim.api.nvim_exec("messages", true), "\n")
    for _, msg in ipairs(messages) do
      if msg:match(expected) then
        return true
      end
    end
    return false
  end
end)

asserts.create("exists_highlighted_window"):register(function(self)
  return function(_, args)
    local expected = args[1]
    self:set_positive(("window highlighted `%s` is not found"):format(expected))
    self:set_negative(("window highlighted `%s` is found"):format(expected))
    for _, window_id in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      local hls = vim.tbl_filter(function(hl)
        return vim.startswith(hl, "Normal:")
      end, vim.split(vim.wo[window_id].winhighlight, ",", true))
      for _, hl in ipairs(hls) do
        local _, v = unpack(vim.split(hl, ":", true))
        if v == expected then
          return true
        end
      end
    end
    return false
  end
end)

return helper
