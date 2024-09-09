local helper = require("piemenu.test.helper")
local assert = helper.typed_assert(assert)

describe("piemenu.core.circle_range", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  -- origin, position = {row, col}
  for _, c in ipairs({
    { s = -20, e = 20, origin = { 10, 10 }, position = { 10, 20 }, expected = true },
    { s = 25, e = 65, origin = { 10, 10 }, position = { 20, 20 }, expected = true },
    { s = 70, e = 110, origin = { 10, 10 }, position = { 20, 10 }, expected = true },
    { s = 115, e = 155, origin = { 10, 10 }, position = { 20, 0 }, expected = true },
    { s = 160, e = 200, origin = { 10, 10 }, position = { 10, 0 }, expected = true },
    { s = 205, e = 245, origin = { 10, 10 }, position = { 0, 0 }, expected = true },
    { s = 250, e = 290, origin = { 10, 10 }, position = { 0, 10 }, expected = true },
    { s = 295, e = 335, origin = { 10, 10 }, position = { 0, 20 }, expected = true },

    { s = -20, e = 20, origin = { 10, 10 }, position = { 9, 20 }, expected = true },
  }) do
    it(
      ("CircleRange.new(%s, %s):include(%s, %s) == %s"):format(
        c.s,
        c.e,
        vim.inspect(c.origin),
        vim.inspect(c.position),
        c.expected
      ),
      function()
        local actual = require("piemenu.core.circle_range").new(c.s, c.e):include(c.origin, c.position)
        assert.equal(c.expected, actual)
      end
    )
  end
end)
