# piemenu.nvim

piemenu.nvim is a circular menu plugin for Neovim (nightly).

<img src="https://github.com/notomo/piemenu.nvim/wiki/image/demo1.gif">

## Example

```lua
vim.opt.mouse = "a"

local group = vim.api.nvim_create_augroup("config.piemenu", {})
vim.api.nvim_create_autocmd({ "FileType" }, {
  group = group,
  pattern = { "piemenu" },
  callback = function()
    vim.o.mousemoveevent = true
    vim.keymap.set("n", "<MouseMove>", [[<Cmd>lua require("piemenu").highlight()<CR>]], { buf = 0 })
    vim.keymap.set("n", "<LeftDrag>", [[<Cmd>lua require("piemenu").highlight()<CR>]], { buf = 0 })
    vim.keymap.set("n", "<LeftRelease>", [[<Cmd>lua require("piemenu").finish()<CR>]], { buf = 0 })
    vim.keymap.set("n", "<RightMouse>", [[<Cmd>lua require("piemenu").cancel()<CR>]], { buf = 0 })
  end,
})

vim.keymap.set("n", "<RightMouse>", [[<LeftMouse><Cmd>lua require("piemenu").start("example")<CR>]])
require("piemenu").register("example", {
  menus = {
    {
      text = "📋 copy",
      action = function()
        vim.cmd.normal({ args = { "yy" }, bang = true })
      end,
    },
    {
      text = "📝 paste",
      action = function()
        vim.cmd.normal({ args = { "p" }, bang = true })
      end,
    },
    {
      text = "✅ save",
      action = function()
        vim.cmd.write()
      end,
    },
    {
      text = "👉 goto file",
      action = function()
        vim.cmd.normal({ args = { "gF" }, bang = true })
      end,
    },
    {
      text = "📚 help",
      action = function()
        vim.cmd.help(vim.fn.expand("<cword>"))
      end,
    },
    {
      text = "❌ close",
      action = function()
        vim.cmd.quit()
      end,
    },
  },
})
```