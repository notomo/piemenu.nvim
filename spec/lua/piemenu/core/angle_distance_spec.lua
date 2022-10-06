local helper = require("piemenu.test.helper")

describe("piemenu.core.angle_distance", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  for _, c in ipairs({
    { angle = 0, next_angle = 0, expected = 360 },
    { angle = 0, next_angle = 360, expected = 360 },
    { angle = 30, next_angle = 50, expected = 20 },
    { angle = 90, next_angle = -90, expected = 180 },
  }) do
    it(("AngleDistance.new(%s, %s) == %s"):format(c.angle, c.next_angle, c.expected), function()
      local actual = require("piemenu.core.angle_distance").AngleDistance.new(c.angle, c.next_angle)
      assert.equals(c.expected, actual)
    end)
  end
end)
