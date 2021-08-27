local vim = vim

local M = {}

function M.link(name, force, to)
  if force then
    vim.cmd(("highlight! link %s %s"):format(name, to))
  else
    vim.cmd(("highlight default link %s %s"):format(name, to))
  end
  return name
end

local ATTRIBUTES = {
  ctermfg = {"fg", "cterm"},
  guifg = {"fg", "gui"},
  ctermbg = {"bg", "cterm"},
  guibg = {"bg", "gui"},
}
function M.define(name, force, attributes)
  local parts = {}
  attributes["blend"] = attributes["blend"] or 0
  for attr_name, v in pairs(attributes) do
    local value = v
    if type(v) == "table" then
      local hl_group, added, default = unpack(v)
      value = M.get_attribute(hl_group, attr_name, added) or default
    elseif type(v) == "string" and ATTRIBUTES[attr_name] then
      value = M.get_attribute(v, attr_name)
    end
    table.insert(parts, ("%s=%s"):format(attr_name, value or "black"))
  end
  local to = table.concat(parts, " ")
  if force then
    vim.cmd(("highlight! %s %s"):format(name, to))
  else
    vim.cmd(("highlight default %s %s"):format(name, to))
  end
  return name
end

function M.get_attribute(hl_group, name, added)
  local hl_id = vim.api.nvim_get_hl_id_by_name(hl_group)
  local ground_type, color_type = unpack(ATTRIBUTES[name])
  local value = vim.fn.synIDattr(hl_id, ground_type, color_type)
  if value == "" then
    return nil
  end
  if added and color_type == "gui" then
    value = M._add_to_gui_color(value, added)
  end
  return value
end

function M._add_to_gui_color(value, added)
  local hex = tonumber("0x" .. value:gsub("#", "")) + added
  hex = math.min(hex, 0xffffff)
  hex = math.max(0x000000, hex)
  return ("#%x"):format(hex)
end

return M
