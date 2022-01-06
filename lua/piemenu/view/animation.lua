local vim = vim
local hrtime = vim.loop.hrtime

local M = {}

local Animation = {}
Animation.__index = Animation
M.Animation = Animation

function Animation.new(items, duration)
  vim.validate({ items = { items, "table" }, duration = { duration, "number" } })

  local on_tick = function()
    local ok = true
    for _, item in ipairs(items) do
      ok = item:on_tick() and ok
    end
    return ok
  end

  local on_finish = function()
    local ok = true
    for _, item in ipairs(items) do
      ok = item:on_finish() and ok
    end
    return ok
  end

  for _, item in ipairs(items) do
    item:set_duration(duration)
  end

  local tbl = {
    _timer = vim.loop.new_timer(),
    _on_tick = on_tick,
    _on_finish = on_finish,
    _duration = duration,
  }
  return setmetatable(tbl, Animation)
end

function Animation.start(self)
  local start_time = hrtime()
  local end_time = start_time + self._duration * 1E6
  self._timer:start(
    0,
    1,
    vim.schedule_wrap(function()
      local current = hrtime()
      if current > end_time then
        self._timer:stop()
        return self._on_finish()
      end
      local ok = self._on_tick()
      if not ok then
        self._timer:stop()
      end
    end)
  )
end

local Move = {}
Move.__index = Move
M.Move = Move

function Move.new(window_id, from, to)
  local tbl = {
    _window_id = window_id,
    _dx = 0,
    _dy = 0,
    _x = from[2],
    _y = from[1],
    _first_x = from[2],
    _first_y = from[1],
    _last_x = to[2],
    _last_y = to[1],
  }
  return setmetatable(tbl, Move)
end

function Move.set_duration(self, duration)
  self._dx = (self._last_x - self._first_x) / duration
  self._dy = (self._last_y - self._first_y) / duration
end

function Move.on_tick(self)
  return self:_move(self._x + self._dx, self._y + self._dy)
end

function Move.on_finish(self)
  return self:_move(self._last_x, self._last_y)
end

function Move._move(self, x, y)
  if not vim.api.nvim_win_is_valid(self._window_id) then
    return false
  end
  self._x = x
  self._y = y
  vim.api.nvim_win_set_config(self._window_id, { row = self._y, col = self._x, relative = "editor" })
  return true
end

return M
