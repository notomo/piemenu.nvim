local CircleRange = require("piemenu.core.circle_range").CircleRange
local Move = require("piemenu.view.animation").Move
local windowlib = require("piemenu.lib.window")
local stringlib = require("piemenu.lib.string")
local highlightlib = require("piemenu.lib.highlight")
local vim = vim

local M = {}

local Tile = {}
Tile.__index = Tile
M.Tile = Tile

function Tile.open(menu, angle, prev_angle, next_angle, radius, width, height, origin_pos)
  local half_width = width / 2
  local half_height = height / 2
  local rad = math.rad(angle)
  local origin_row, origin_col = unpack(origin_pos)
  local row = radius * math.sin(rad) + origin_row - half_height
  local col = radius * math.cos(rad) * 2 + origin_col - half_width -- *2 for row height and col width ratio

  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, { stringlib.ellipsis(menu:to_string(), width - 2) })
  vim.bo[bufnr].bufhidden = "wipe"
  vim.bo[bufnr].modifiable = false

  local y = origin_pos[1]
  local x = origin_pos[2] - half_width
  local window_id = vim.api.nvim_open_win(bufnr, false, {
    width = width - 2, -- for border
    height = height - 2, -- for border
    anchor = "NW",
    relative = "editor",
    row = y,
    col = x,
    external = false,
    focusable = false,
    style = "minimal",
    zindex = 51,
    border = { { " ", "PimenuNonCurrent" } },
  })
  vim.wo[window_id].winblend = 0

  local tbl = {
    _window_id = window_id,
    _menu = menu,
    _range = CircleRange.new(angle - prev_angle, angle + next_angle),
    _origin_pos = origin_pos,
  }
  local tile = setmetatable(tbl, Tile)
  tile:deactivate()
  return tile, Move.new(window_id, { y, x }, { row + 1, col })
end

function Tile.include(self, position)
  return self._range:include(self._origin_pos, position)
end

function Tile.close(self)
  windowlib.close(self._window_id)
end

function Tile.activate(self)
  vim.wo[self._window_id].winhighlight = "Normal:PiemenuCurrent"
  vim.api.nvim_win_set_config(self._window_id, { border = { { " ", "PiemenuCurrentBorder" } } })
end

function Tile.deactivate(self)
  vim.wo[self._window_id].winhighlight = "Normal:PiemenuNonCurrent"
  vim.api.nvim_win_set_config(self._window_id, { border = { { " ", "PiemenuNonCurrentBorder" } } })
end

function Tile.execute_action(self)
  return self._menu:execute_action()
end

local force = false
M.hl_groups = {
  highlightlib.link("PiemenuNonCurrent", force, "NormalFloat"),
  highlightlib.link("PiemenuNonCurrentBorder", force, "NormalFloat"),
  highlightlib.define("PiemenuCurrent", force, {
    ctermfg = "Normal",
    guifg = "Normal",
    ctermbg = "Normal",
    guibg = "Normal",
    gui = "bold,underline",
  }),
  highlightlib.link("PiemenuCurrentBorder", force, "NormalFloat"),
}

return M
