local util = require("genvdoc.util")
local plugin_name = vim.env.PLUGIN_NAME
local full_plugin_name = plugin_name .. ".nvim"

local example_path = ("./spec/lua/%s/example.lua"):format(plugin_name)
dofile(example_path)

require("genvdoc").generate(full_plugin_name, {
  chapters = {
    {
      name = function(group)
        return "Lua module: " .. group
      end,
      group = function(node)
        if node.declaration == nil or node.declaration.type ~= "function" then
          return nil
        end
        return node.declaration.module
      end,
    },
    {
      name = "STRUCTURE",
      group = function(node)
        if node.declaration == nil or node.declaration.type ~= "class" then
          return nil
        end
        return "STRUCTURE"
      end,
    },
    {
      name = "HIGHLIGHT GROUPS",
      body = function(ctx)
        local descriptions = {
          PiemenuCurrent = [[used for current selected menu content]],
          PiemenuCurrentBorder = [[used for current selected menu border]],
          PiemenuNonCurrent = [[used for non selected menu content]],
          PiemenuNonCurrentBorder = [[used for non selected menu border]],
        }
        local names = require("piemenu.view").hl_groups
        return util.hl_group_sections(ctx, names, descriptions)
      end,
    },
    {
      name = "EXAMPLES",
      body = function()
        return util.help_code_block_from_file(example_path, { language = "lua" })
      end,
    },
  },
})

local gen_readme = function()
  local f = io.open(example_path, "r")
  local exmaple = f:read("*a")
  f:close()

  local content = ([[
# piemenu.nvim

piemenu.nvim is a circular menu plugin for Neovim (nightly).

<img src="https://github.com/notomo/piemenu.nvim/wiki/image/demo1.gif">

## Example

```lua
%s```]]):format(exmaple)

  local readme = io.open("README.md", "w")
  readme:write(content)
  readme:close()
end
gen_readme()
