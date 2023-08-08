local setup_highlight_groups = function()
  local highlightlib = require("piemenu.vendor.misclib.highlight")
  return {
    PiemenuNonCurrent = highlightlib.link("PiemenuNonCurrent", "NormalFloat"),
    PiemenuNonCurrentBorder = highlightlib.link("PiemenuNonCurrentBorder", "NormalFloat"),
    PiemenuCurrent = highlightlib.define("PiemenuCurrent", {
      fg = vim.api.nvim_get_hl(0, { name = "Normal" }).fg,
      bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg,
      bold = true,
      underline = true,
    }),
    PiemenuCurrentBorder = highlightlib.link("PiemenuCurrentBorder", "NormalFloat"),
  }
end

local group = vim.api.nvim_create_augroup("piemenu", {})
vim.api.nvim_create_autocmd({ "ColorScheme" }, {
  group = group,
  pattern = { "*" },
  callback = setup_highlight_groups,
})

return setup_highlight_groups()
