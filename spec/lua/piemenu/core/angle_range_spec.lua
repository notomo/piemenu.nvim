local helper = require("piemenu.lib.testlib.helper")

describe("piemenu.core.angle_range", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  for _, c in ipairs({
    {start_angle = 0, end_angle = 0, exclude_s = 0, exclude_e = 0, expected = {}},
    {start_angle = 10, end_angle = 30, exclude_s = 0, exclude_e = 100, expected = {}},
    {start_angle = 0, end_angle = 120, exclude_s = 100, exclude_e = 120, expected = {{0, 99}}},
    {start_angle = 0, end_angle = 120, exclude_s = 0, exclude_e = 20, expected = {{21, 120}}},
    {
      start_angle = 100,
      end_angle = 200,
      exclude_s = 120,
      exclude_e = 130,
      expected = {{100, 119}, {131, 200}},
    },
    {
      start_angle = -270,
      end_angle = -180,
      exclude_s = 90,
      exclude_e = 135,
      expected = {{-224, -180}},
    },
    {start_angle = 90, end_angle = 0, exclude_s = 10, exclude_e = 80, expected = {{90, 81}, {9, 0}}},
    {start_angle = 0, end_angle = 90, exclude_s = 91, exclude_e = 100, expected = {{0, 90}}},
    {start_angle = 10, end_angle = 90, exclude_s = 0, exclude_e = 9, expected = {{10, 90}}},
    {start_angle = 0, end_angle = 360, exclude_s = 330, exclude_e = 360, expected = {{0, 329}}},
  }) do
    it(("AngleRange.new(%s, %s):exclude(%s, %s) == %s"):format(c.start_angle, c.end_angle, c.exclude_s, c.exclude_e, vim.inspect(c.expected)), function()
      local angle_ranges = require("piemenu.core.angle_range").AngleRange.new(c.start_angle, c.end_angle):exclude(c.exclude_s, c.exclude_e)
      local actual = angle_ranges:raw()

      assert.is_same(c.expected, actual)
    end)
  end

  for _, c in ipairs({
    {angle_ranges = {}, expected = {}},
    {angle_ranges = {{0, 360}}, expected = {{0, 360}}},
    {angle_ranges = {{0, 45}, {150, 360}}, expected = {{150, 405}}},
    {angle_ranges = {{360, 150}, {45, 0}}, expected = {{45, -210}}},
    {angle_ranges = {{10, 40}, {50, 360}}, expected = {{10, 40}, {50, 360}}},
  }) do
    it(("AngleRanges.new(%s):join() == %s"):format(vim.inspect(c.angle_ranges), vim.inspect(c.expected)), function()
      local angle_ranges = require("piemenu.core.angle_range").AngleRanges.from_raw(c.angle_ranges):join()
      local actual = angle_ranges:raw()

      assert.is_same(c.expected, actual)
    end)
  end

  for _, c in ipairs({
    {angle_ranges = {}, exclude = {}, expected = {}},
    {angle_ranges = {{0, 360}}, exclude = {{0, 10}}, expected = {{11, 360}}},
    {angle_ranges = {{0, 360}}, exclude = {{0, 10}, {50, 60}}, expected = {{11, 49}, {61, 360}}},
    {angle_ranges = {{11, 360}}, exclude = {{50, 60}}, expected = {{11, 49}, {61, 360}}},
    {angle_ranges = {{0, 360}}, exclude = {{330, 360}}, expected = {{0, 329}}},
  }) do
    it(("AngleRanges.new(%s):exclude(%s) == %s"):format(vim.inspect(c.angle_ranges), vim.inspect(c.exclude), vim.inspect(c.expected)), function()
      local exclude = require("piemenu.core.angle_range").AngleRanges.from_raw(c.exclude)
      local angle_ranges = require("piemenu.core.angle_range").AngleRanges.from_raw(c.angle_ranges):exclude(exclude)
      local actual = angle_ranges:raw()

      assert.is_same(c.expected, actual)
    end)
  end

end)
