local windowlib = require("piemenu.lib.window")

local M = {}

local Background = {}
Background.__index = Background
M.Background = Background

function Background.open(name)
  local width = vim.o.columns
  local height = vim.o.lines - vim.o.cmdheight

  local bufnr = vim.api.nvim_create_buf(false, true)
  local lines = vim.fn["repeat"]({(" "):rep(width)}, height)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].filetype = "piemenu"
  vim.bo[bufnr].bufhidden = "wipe"
  vim.bo[bufnr].modifiable = false

  local window_id = vim.api.nvim_open_win(bufnr, true, {
    width = width,
    height = height,
    relative = "editor",
    row = 0,
    col = 0,
    external = false,
    focusable = true,
    style = "minimal",
  })
  vim.wo[window_id].winblend = 100
  vim.wo[window_id].scrolloff = 0
  vim.wo[window_id].sidescrolloff = 0

  -- NOTE: show and move cursor to the window by <LeftDrag>
  vim.cmd("redraw")

  vim.cmd(([[autocmd WinLeave,TabLeave,BufLeave <buffer=%s> ++once lua require('piemenu.command').Command.new("close", "%s")]]):format(bufnr, name))

  local tbl = {window_id = window_id}
  return setmetatable(tbl, Background)
end

function Background.close(self)
  windowlib.close(self.window_id)
end

function Background.cursor(self)
  return vim.api.nvim_win_get_cursor(self.window_id)
end

return M
