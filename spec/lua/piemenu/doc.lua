local example_path = "./spec/lua/piemenu/example.vim"
local util = require("genvdoc.util")

local ok, result = pcall(vim.cmd, "source" .. example_path)
if not ok then
  error(result)
end

require("genvdoc").generate("piemenu.nvim", {
  chapters = {
    {
      name = function(group)
        return "Lua module: " .. group
      end,
      group = function(node)
        if not node.declaration then
          return nil
        end
        return node.declaration.module
      end,
    },
    {
      name = "HIGHLIGHT GROUPS",
      body = function(ctx)
        local descriptions = {
          PiemenuCurrent = [[
used for current selected menu content
]],
          PiemenuCurrentBorder = [[
used for current selected menu border
]],
          PiemenuNonCurrent = [[
used for non selected menu content
]],
          PiemenuNonCurrentBorder = [[
used for non selected menu border
]],
        }
        local sections = {}
        for _, hl_group in ipairs(require("piemenu.view").hl_groups) do
          table.insert(sections, util.help_tagged(ctx, hl_group, "hl-" .. hl_group) .. util.indent(descriptions[hl_group] or "Todo\n", 2))
        end
        return vim.trim(table.concat(sections, "\n"))
      end,
    },
    {
      name = "EXAMPLES",
      body = function()
        return require("genvdoc.util").help_code_block_from_file(example_path)
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

## Example

```vim
%s```]]):format(exmaple)

  local readme = io.open("README.md", "w")
  readme:write(content)
  readme:close()
end
gen_readme()
