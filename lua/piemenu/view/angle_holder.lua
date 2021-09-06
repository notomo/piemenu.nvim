local Angle0To360 = require("piemenu.core.angle_with_offset").Angle0To360

local M = {}

local AngleHolder = {}
AngleHolder.__index = AngleHolder
M.AngleHolder = AngleHolder

function AngleHolder.new(angle, inner)
  vim.validate({angle = {angle, "number"}})
  return {angle = angle, inner = inner}
end

local AngleHolders = {}
AngleHolders.__index = AngleHolders
M.AngleHolders = AngleHolders

function AngleHolders.new(raw_holders)
  raw_holders = raw_holders or {}
  local angles = {}
  for _, holder in ipairs(raw_holders) do
    angles[math.floor(Angle0To360.new(holder.angle))] = true
  end
  local tbl = {_holders = raw_holders, _angles = angles}
  return setmetatable(tbl, AngleHolders)
end

function AngleHolders.add(self, angle, inner)
  table.insert(self._holders, AngleHolder.new(angle, inner))
  return AngleHolders.new(self._holders)
end

function AngleHolders.exists(self, angle)
  return self._angles[math.floor(Angle0To360.new(angle))] ~= nil
end

function AngleHolders.sorted(self, asc)
  if asc then
    table.sort(self._holders, function(a, b)
      return a.angle < b.angle
    end)
  else
    table.sort(self._holders, function(a, b)
      return a.angle > b.angle
    end)
  end
  return self._holders
end

return M
