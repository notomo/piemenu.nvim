local vim = vim

local M = {}

local Animation = {}
Animation.__index = Animation
M.Animation = Animation

function Animation.new(timeout_ms, on_tick, on_finish)
  vim.validate({
    timeout_ms = {timeout_ms, "number"},
    on_tick = {on_tick, "function"},
    on_finish = {on_finish, "function"},
  })
  local tbl = {
    _timer = vim.loop.new_timer(),
    _on_tick = on_tick,
    _timeout_ms = timeout_ms,
    _on_finish = on_finish,
  }
  return setmetatable(tbl, Animation)
end

function Animation.start(self)
  local start_time = vim.loop.hrtime()
  local end_time = start_time + self._timeout_ms * 1E6
  self._timer:start(0, 1, vim.schedule_wrap(function()
    local current = vim.loop.hrtime()
    if current > end_time then
      self._timer:stop()
      return self._on_finish()
    end
    return self._on_tick()
  end))
end

local Move = {}
M.Move = Move

function Move.start(from, to, timeout_ms, on_tick, on_finish)
  local dx = (to[2] - from[2]) / timeout_ms
  local dy = (to[1] - from[1]) / timeout_ms
  local animation = Animation.new(timeout_ms, function()
    on_tick(dx, dy)
  end, on_finish)
  return animation:start()
end

return M
