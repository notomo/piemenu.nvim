local windowlib = require("piemenu.vendor.misclib.window")
local bufferlib = require("piemenu.vendor.misclib.buffer")

local M = {}

local Background = {}
Background.__index = Background
M.Background = Background

function Background.open(name, position)
  local width = vim.o.columns
  local height = vim.o.lines - vim.o.cmdheight

  local bufnr = vim.api.nvim_create_buf(false, true)
  local buffer_name = ("piemenu://%s"):format(name)
  bufferlib.delete_by_name(buffer_name)
  vim.api.nvim_buf_set_name(bufnr, buffer_name)
  local lines = vim.fn["repeat"]({ (" "):rep(width) }, height)
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
  vim.api.nvim_win_set_cursor(window_id, { position[1] + 1, position[2] - 1 })

  -- NOTE: show and move cursor to the window by <LeftDrag>
  vim.cmd.redraw()

  vim.api.nvim_create_autocmd({ "WinLeave", "TabLeave", "BufLeave" }, {
    buffer = bufnr,
    once = true,
    callback = function()
      require("piemenu.command").close(name)
    end,
  })

  local ns = vim.api.nvim_create_namespace("piemenu")
  vim.api.nvim_set_decoration_provider(ns, {
    on_win = function(_, _, buf, topline)
      if topline == 0 or buf ~= bufnr or not vim.api.nvim_win_is_valid(window_id) then
        return false
      end
      vim.fn.winrestview({ topline = 0, leftcol = 0 })
    end,
  })

  local tbl = { window_id = window_id, _ns = ns }
  return setmetatable(tbl, Background)
end

function Background.close(self)
  windowlib.safe_close(self.window_id)
  vim.api.nvim_set_decoration_provider(self._ns, {})
end

function Background.click(self)
  self:_click()
  if not vim.api.nvim_win_is_valid(self.window_id) then
    return nil
  end
  return vim.api.nvim_win_get_cursor(self.window_id)
end

local mouse = vim.api.nvim_eval('"\\<LeftMouse>"')
-- replace on testing
function Background._click()
  vim.cmd.normal({ args = { mouse }, bang = true })
end

return M
