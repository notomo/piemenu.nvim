local persist = {}

local M = {}

local Repository = {}
Repository.__index = Repository
M.Repository = Repository

function Repository.new(name)
  if persist[name] ~= nil then
    return persist[name]
  end
  local tbl = {_data = {}}
  local self = setmetatable(tbl, Repository)
  persist[name] = self
  return self
end

function Repository.get(self, key)
  return self._data[key]
end

function Repository.set(self, key, value)
  self._data[key] = value
end

function Repository.delete(self, key)
  self:set(key, nil)
end

function Repository.all(self)
  return pairs(self._data)
end

return M
