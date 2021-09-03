local helper = require("piemenu.lib.testlib.helper")

describe("piemenu.view.circle_splitter", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  local allocate_if_odd = function(_, item)
    if (item % 2) == 0 then
      return nil
    end
    return item
  end

  for _, c in ipairs({
    {start_angle = 0, end_angle = 360, items = {}, expected = {}},
    {start_angle = 0, end_angle = 360, items = {1}, expected = {{angle = 0, inner = 1}}},
    {start_angle = 0, end_angle = 360, items = {1, 2}, expected = {{angle = 0, inner = 1}}},
    {
      start_angle = 0,
      end_angle = 360,
      items = {1, 3},
      expected = {{angle = 0, inner = 1}, {angle = 180, inner = 3}},
    },
    {start_angle = 370, end_angle = 0, items = {1}, expected = {{angle = 370, inner = 1}}},
    {
      start_angle = 0,
      end_angle = 360,
      items = {1, 2, 3},
      expected = {{angle = 0, inner = 1}, {angle = 240, inner = 3}},
    },
    {
      start_angle = 30,
      end_angle = 90,
      items = {1, 3, 5},
      expected = {{angle = 30, inner = 1}, {angle = 60, inner = 3}, {angle = 90, inner = 5}},
    },
    {
      start_angle = 90,
      end_angle = 30,
      items = {1, 3, 5},
      expected = {{angle = 90, inner = 1}, {angle = 60, inner = 3}, {angle = 30, inner = 5}},
    },
  }) do
    it(("CircleSplitter.new(%d, %d, {allocate_if_odd}):split(%s) == %s"):format(c.start_angle, c.end_angle, vim.inspect(c.items), vim.inspect(c.expected)), function()
      local splitter = require("piemenu.view.circle_splitter").CircleSplitter.new(c.start_angle, c.end_angle, allocate_if_odd)
      local actual = splitter:split(c.items)
      assert.is_same(c.expected, actual)
    end)
  end

  it("CircleSplitter does not give duplicated angle in retry", function()
    local splitter = require("piemenu.view.circle_splitter").CircleSplitter.new(30, 90, function(angle, item)
      if angle == 30 and item ~= 3 then
        return item
      end
    end)
    local actual = splitter:split({1, 2, 3})
    assert.is_same({{angle = 30, inner = 1}}, actual)
  end)

  it("CircleSplitter does not give duplicated angle even if it is over 360", function()
    local splitter = require("piemenu.view.circle_splitter").CircleSplitter.new(0, 360, function(angle, item)
      if angle == 0 or angle == 360 then
        return item
      end
    end)
    local actual = splitter:split({1, 2, 3, 4})
    assert.is_same({{angle = 0, inner = 1}}, actual)
  end)

end)
