local helper = require("piemenu.test.helper")

describe("piemenu.core.angle", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  for _, c in ipairs({
    { base_angle = 0, angle = 0, expected = 0 },
    { base_angle = 0, angle = 360, expected = 360 },
    { base_angle = 360, angle = 360, expected = 360 },
    { base_angle = 60, angle = 450, expected = 90 },
    { base_angle = -90, angle = -90, expected = -90 },
    { base_angle = -90, angle = 270, expected = -90 },
  }) do
    it(("Angle.new_with_offset(%s, %s) == %s"):format(c.base_angle, c.angle, c.expected), function()
      local actual = require("piemenu.core.angle").new_with_offset(c.base_angle, c.angle)
      assert.equals(c.expected, actual)
    end)
  end

  for _, c in ipairs({
    { angle = 0, next_angle = 0, expected = 360 },
    { angle = 0, next_angle = 360, expected = 360 },
    { angle = 30, next_angle = 50, expected = 20 },
    { angle = 90, next_angle = -90, expected = 180 },
  }) do
    it(("Angle.distance(%s, %s) == %s"):format(c.angle, c.next_angle, c.expected), function()
      local actual = require("piemenu.core.angle").distance(c.angle, c.next_angle)
      assert.equals(c.expected, actual)
    end)
  end
end)
