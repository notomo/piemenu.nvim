local helper = require("piemenu.lib.testlib.helper")

describe("piemenu.view.circle_splitter", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  for _, c in ipairs({
    {start_angle = 0, end_angle = 360, count = 0, expected = {}},
    {start_angle = 0, end_angle = 360, count = 1, expected = {{angle = 0, inner = 1}}},
    {
      start_angle = 0,
      end_angle = 360,
      count = 2,
      expected = {{angle = 0, inner = 1}, {angle = 180, inner = 2}},
    },
    {start_angle = 370, end_angle = 0, count = 1, expected = {{angle = 370, inner = 1}}},
    {
      start_angle = 30,
      end_angle = 90,
      count = 3,
      expected = {{angle = 30, inner = 1}, {angle = 60, inner = 2}, {angle = 90, inner = 3}},
    },
    {
      start_angle = 90,
      end_angle = 30,
      count = 3,
      expected = {{angle = 90, inner = 1}, {angle = 60, inner = 2}, {angle = 30, inner = 3}},
    },
  }) do
    it(("CircleSplitter.new(%d, %d, {allocate}):split(%d) == %s"):format(c.start_angle, c.end_angle, c.count, vim.inspect(c.expected)), function()
      local i = 0
      local splitter = require("piemenu.view.circle_splitter").CircleSplitter.new(c.start_angle, c.end_angle, function()
        i = i + 1
        return i
      end)
      local actual = splitter:split(c.count)
      assert.is_same(c.expected, actual)
    end)
  end

  it("CircleSplitter does not give duplicated angle in retry", function()
    local i = 0
    local splitter = require("piemenu.view.circle_splitter").CircleSplitter.new(30, 90, function(angle)
      i = i + 1
      if angle == 30 and i ~= 3 then
        return i
      end
    end)
    local actual = splitter:split(3)
    assert.is_same({{angle = 30, inner = 1}}, actual)
  end)

  it("CircleSplitter does not give duplicated angle even if it is over 360", function()
    local i = 0
    local splitter = require("piemenu.view.circle_splitter").CircleSplitter.new(0, 360, function(angle)
      i = i + 1
      if angle == 0 or angle == 360 then
        return i
      end
    end)
    local actual = splitter:split(4)
    assert.is_same({{angle = 0, inner = 1}}, actual)
  end)

  it("CircleSplitter gives angle near original in retry", function()
    local retry = false
    local i = 0
    local splitter = require("piemenu.view.circle_splitter").CircleSplitter.new(0, 360, function(angle)
      if not retry and i == 4 then
        retry = true
        return nil
      end
      if angle == 270 then
        return nil
      end
      i = i + 1
      return i
    end)

    local actual = splitter:split(4)
    assert.is_same({
      {angle = 0, inner = 1},
      {angle = 90, inner = 2},
      {angle = 180, inner = 3},
      {angle = 225, inner = 4},
    }, actual)
  end)

end)
