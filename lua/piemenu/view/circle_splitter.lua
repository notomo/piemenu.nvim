local M = {}

local Spaces = {}
Spaces.__index = Spaces

function Spaces.new(spaces)
  spaces = spaces or {}
  local angles = {}
  for _, space in ipairs(spaces) do
    angles[space.angle] = true
  end
  local tbl = {_spaces = spaces, _angles = angles}
  return setmetatable(tbl, Spaces)
end

function Spaces.add(self, space)
  table.insert(self._spaces, space)
  return Spaces.new(self._spaces)
end

function Spaces.exists(self, angle)
  return self._angles[angle] ~= nil
end

function Spaces.sorted(self)
  table.sort(self._spaces, function(a, b)
    return a.angle < b.angle
  end)
  return self._spaces
end

local CircleSplitter = {}
CircleSplitter.__index = CircleSplitter
M.CircleSplitter = CircleSplitter

function CircleSplitter.new(start_angle, end_angle, allocate_space)
  local tbl = {_start_angle = start_angle, _end_angle = end_angle, _allocate_space = allocate_space}
  return setmetatable(tbl, CircleSplitter)
end

function CircleSplitter.split(self, menus)
  local spaces = Spaces.new()
  local failed_menus = {}
  local menu_increment_angle = self._end_angle / menus:count()
  for i, menu in menus:iter() do
    if menu:is_empty() then
      goto continue
    end
    local angle = self._start_angle + (i - 1) * menu_increment_angle
    local space = self._allocate_space(angle, menu)
    if space then
      spaces = spaces:add(space)
    else
      table.insert(failed_menus, menu)
    end
    ::continue::
  end

  local increment_angle = math.max(menu_increment_angle / 3, 1)
  for _, menu in ipairs(failed_menus) do
    for angle = self._start_angle, self._end_angle - 1, increment_angle do
      if spaces:exists(angle) then
        goto continue
      end
      local space = self._allocate_space(angle, menu)
      if space then
        spaces = spaces:add(space)
        break
      end
      ::continue::
    end
  end

  return spaces:sorted()
end

return M
