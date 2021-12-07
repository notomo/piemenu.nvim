local example_path = "./spec/lua/piemenu/example.vim"
local util = require("genvdoc.util")

vim.cmd("source" .. example_path)

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
        local setting_text
        do
          local descriptions = {
            start_angle = [[(number | nil): angle to open first tile, default: %s]],
            end_angle = [[(number | nil): angle to limit open tile, default: %s]],
            radius = [[(number | nil): piemenu circle radius, default: %s]],
            tile_width = [[(number | nil): menu tile width, default: %s]],
            animation = [[(table | nil): |piemenu.nvim-animation|]],
            menus = [[(table | nil): |piemenu.nvim-menus|]],
            position = [[(table | nil): {row, col}]],
          }
          local keys = vim.tbl_keys(require("piemenu.core.setting").Setting.default)
          local default_values = require("piemenu.core.setting").Setting.default_values()
          local setting_lines = util.each_keys_description(keys, descriptions, default_values)
          setting_text = table.concat(setting_lines, "\n")
        end

        local animation_text
        do
          local descriptions = {duration = [[(number | nil): open animation duration, default: %s]]}
          local keys = vim.tbl_keys(require("piemenu.core.setting").AnimationSetting.default)
          local default_values = require("piemenu.core.setting").AnimationSetting.default
          local animation_lines = util.each_keys_description(keys, descriptions, default_values)
          animation_text = table.concat(animation_lines, "\n")
        end

        local menu_text
        do
          local descriptions = {
            action = [[(function): action triggered by |piemenu.nvim-piemenu.finish()|]],
            text = [[(string): displayed text in menu tile]],
          }
          local keys = vim.tbl_keys(descriptions)
          local menu_lines = util.each_keys_description(keys, descriptions)
          menu_text = [[
The following key's table or empty table are allowed.
If it is empty table, the menu is not opened but used as spacer.
If the circle is clipped by editor area, spacers are omitted.

]] .. table.concat(menu_lines, "\n")
        end

        return util.sections(ctx, {
          {name = "Setting", tag_name = "setting", text = setting_text},
          {name = "Animation", tag_name = "animation", text = animation_text},
          {name = "Menus", tag_name = "menus", text = menu_text},
        })
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

<img src="https://github.com/notomo/piemenu.nvim/wiki/image/demo1.gif" width="1280">

## Example

```vim
%s```]]):format(exmaple)

  local readme = io.open("README.md", "w")
  readme:write(content)
  readme:close()
end
gen_readme()
