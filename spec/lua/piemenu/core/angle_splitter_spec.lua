local helper = require("piemenu.lib.testlib.helper")

describe("piemenu.core.angle_splitter", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  for _, c in ipairs({
    {start_angle = 0, end_angle = 0, angle_ranges = {}, all_count = 0, expected = {}},
    {start_angle = 0, end_angle = 360, angle_ranges = {{0, 180}}, all_count = 1, expected = {0}},
    {
      start_angle = 0,
      end_angle = 360,
      angle_ranges = {{0, 360}},
      all_count = 2,
      expected = {0, 180},
    },
    {
      start_angle = 360,
      end_angle = 0,
      angle_ranges = {{180, 360}},
      all_count = 2,
      expected = {0, 180},
    },
    {
      start_angle = 0,
      end_angle = 360,
      angle_ranges = {{90, 360}},
      all_count = 4,
      expected = {0, 90, 180, 270},
    },
    {
      start_angle = 180,
      end_angle = 540,
      angle_ranges = {{0, 360}},
      all_count = 4,
      expected = {180, 270, 0, 90},
    },
  }) do
    it(("AngleSplitter.new(%s, %s, %s, %s):split() == %s"):format(c.start_angle, c.end_angle, vim.inspect(c.angle_ranges), c.all_count, vim.inspect(c.expected)), function()
      local angle_ranges = require("piemenu.core.angle_range").AngleRanges.from_raw(c.angle_ranges)
      local actual = require("piemenu.core.angle_splitter").AngleSplitter.new(c.start_angle, c.end_angle, angle_ranges, c.all_count):split()

      assert.is_same(c.expected, actual)
    end)
  end

end)
