set mouse=a

augroup piemenu_setting
  autocmd!
  autocmd FileType piemenu call s:setting()
augroup END
function! s:setting() abort
  nnoremap <buffer> <LeftDrag> <Cmd>lua require("piemenu").highlight()<CR>
  nnoremap <buffer> <LeftRelease> <Cmd>lua require("piemenu").finish()<CR>
  nnoremap <buffer> <RightMouse> <Cmd>lua require("piemenu").cancel()<CR>
endfunction

nnoremap <RightMouse> <LeftMouse><Cmd>lua require("piemenu").start("example")<CR>
lua << EOF
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
EOF

" start by gesture.nvim (optional)
lua << EOF
local piemenu = require("piemenu")
local gesture = require("gesture")
gesture.register({
  name = "open pie menu",
  inputs = {gesture.up()},
  action = function(ctx)
    piemenu.start("gesture_example", {position = ctx.last_position})
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
    --TODO
  },
})
EOF
