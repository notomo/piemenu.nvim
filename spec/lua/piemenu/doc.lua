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
      name = "PARAMETERS",
      body = function(ctx)
        local descriptions = {
          start_angle = [[
- {start_angle} (number | nil): angle to open first tile, default: %s]],
          end_angle = [[
- {end_angle} (number | nil): angle to limit open tile, default: %s]],
          radius = [[
- {radius} (number | nil): piemenu circle radius, default: %s]],
          tile_width = [[
- {tile_width} (number | nil): menu tile width, default: %s]],
          animation = [[
- {animation} (table | nil): |piemenu.nvim-animation|]],
          menus = [[
- {menus} (table | nil): |piemenu.nvim-menus|]],
          position = [[
- {position} (table | nil): {row, col}]],
        }
        local setting_lines = {}
        do
          local keys = vim.tbl_keys(require("piemenu.core.setting").Setting.default)
          local values = require("piemenu.core.setting").Setting.default_values()
          table.sort(keys, function(a, b)
            return a < b
          end)
          for _, key in ipairs(keys) do
            local desc = (descriptions[key] or "Todo\n"):format(vim.inspect(values[key]))
            table.insert(setting_lines, desc)
          end
        end

        local animation_descriptions = {
          duration = [[
- {duration} (number | nil): open animation duration, default: %s]],
        }
        local animation_lines = {}
        do
          local keys = vim.tbl_keys(require("piemenu.core.setting").AnimationSetting.default)
          local values = require("piemenu.core.setting").AnimationSetting.default
          table.sort(keys, function(a, b)
            return a < b
          end)
          for _, key in ipairs(keys) do
            local desc = (animation_descriptions[key] or "Todo\n"):format(vim.inspect(values[key]))
            table.insert(animation_lines, desc)
          end
        end

        return util.help_tagged(ctx, "Setting", "piemenu.nvim-setting") .. [[

]] .. vim.trim(table.concat(setting_lines, "\n")) .. [[


]] .. util.help_tagged(ctx, "Animation", "piemenu.nvim-animation") .. [[

]] .. vim.trim(table.concat(animation_lines, "\n")) .. [[


]] .. util.help_tagged(ctx, "Menus", "piemenu.nvim-menus") .. [[

The following key's table or empty table are allowed.
If it is empty table, the menu is not opened but used as spacer.
If the circle is clipped, spacers are omitted.

- {text} (string): displayed text in menu tile
- {action} (function): action triggered by |piemenu.nvim-piemenu.finish()|]]
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
