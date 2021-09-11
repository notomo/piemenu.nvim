local helper = require("piemenu.lib.testlib.helper")

describe("piemenu.lib.list", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  for _, c in ipairs({
    {items = {}, expected = {}},
    {items = {1}, expected = {{1, 1, 1}}},
    {items = {1, 2}, expected = {{2, 1, 2}, {1, 2, 1}}},
    {items = {1, 2, 3}, expected = {{3, 1, 2}, {1, 2, 3}, {2, 3, 1}}},
  }) do
    it(("tri_circular(%s) == %s"):format(vim.inspect(c.items), vim.inspect(c.expected)), function()
      local actual = require("piemenu.lib.list").tri_circular(c.items)
      assert.is_same(c.expected, actual)
    end)
  end

end)
