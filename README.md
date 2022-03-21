# piemenu.nvim

piemenu.nvim is a circular menu plugin for Neovim (nightly).

<img src="https://github.com/notomo/piemenu.nvim/wiki/image/demo1.gif" width="1280">

## Example

```lua
vim.opt.mouse = "a"

local group = vim.api.nvim_create_augroup("piemenu_setting", {})
vim.api.nvim_create_autocmd({ "FileType" }, {
  group = group,
  pattern = { "piemenu" },
  callback = function()
    vim.keymap.set("n", "<LeftDrag>", [[<Cmd>lua require("piemenu").highlight()<CR>]], { buffer = true })
    vim.keymap.set("n", "<LeftRelease>", [[<Cmd>lua require("piemenu").finish()<CR>]], { buffer = true })
    vim.keymap.set("n", "<RightMouse>", [[<Cmd>lua require("piemenu").cancel()<CR>]], { buffer = true })
  end,
})

vim.keymap.set("n", "<RightMouse>", [[<LeftMouse><Cmd>lua require("piemenu").start("example")<CR>]])
require("piemenu").register("example", {
  menus = {
    {
      text = "📋 copy",
      action = function()
        vim.cmd("normal! yy")
      end,
    },
    {
      text = "📝 paste",
      action = function()
        vim.cmd("normal! p")
      end,
    },
    {
      text = "✅ save",
      action = function()
        vim.cmd("write")
      end,
    },
    {
      text = "👉 goto file",
      action = function()
        vim.cmd("normal! gF")
      end,
    },
    {
      text = "📚 help",
      action = function()
        vim.cmd("help " .. vim.fn.expand("<cword>"))
      end,
    },
    {
      text = "❌ close",
      action = function()
        vim.cmd("quit")
      end,
    },
  },
})

-- start by gesture.nvim (optional)
local piemenu = require("piemenu")
local gesture = require("gesture")
gesture.register({
  name = "open pie menu",
  inputs = { gesture.up() },
  action = function(ctx)
    piemenu.start("gesture_example", { position = ctx.last_position })
  end,
  nowait = true,
})

piemenu.register("gesture_example", {
  menus = {
    {
      text = "🆕 new tab",
      action = function()
        vim.cmd("tabedit")
      end,
    },
    {
      text = "🏠 open vimrc",
      action = function()
        vim.cmd("edit " .. vim.env.MYVIMRC)
      end,
    },
    {
      text = "🔃 reload",
      action = function()
        vim.cmd("edit!")
      end,
    },
    {
      text = "😃 smile",
      action = function()
        vim.cmd("smile")
      end,
    },
  },
})
```