local helper = require("piemenu.lib.testlib.helper")

describe("piemenu.core.angle_with_offset", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  for _, c in ipairs({
    {base_angle = 0, angle = 0, expected = 0},
    {base_angle = 0, angle = 360, expected = 360},
    {base_angle = 360, angle = 360, expected = 360},
    {base_angle = 60, angle = 450, expected = 90},
    {base_angle = -90, angle = -90, expected = -90},
    {base_angle = -90, angle = 270, expected = -90},
  }) do
    it(("AngleWithOffset.new(%s, %s) == %s"):format(c.base_angle, c.angle, c.expected), function()
      local actual = require("piemenu.core.angle_with_offset").AngleWithOffset.new(c.base_angle, c.angle)
      assert.equals(c.expected, actual)
    end)
  end

end)
