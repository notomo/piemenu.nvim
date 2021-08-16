local helper = require("piemenu.lib.testlib.helper")
local piemenu = helper.require("piemenu")

describe("piemenu.start()", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it("TODO", function()
    piemenu.start("hoge")
  end)

end)

describe("piemenu.hover()", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it("TODO", function()
    piemenu.hover()
  end)

end)

describe("piemenu.select()", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it("TODO", function()
    piemenu.select()
  end)

end)

describe("piemenu.cancel()", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it("TODO", function()
    piemenu.cancel()
  end)

end)

describe("piemenu.register()", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it("TODO", function()
    piemenu.register("default", {
      menus = {
        {
          text = "text A",
          action = function()
          end,
        },
        {},
        {
          text = "text B",
          action = function()
          end,
        },
      },
    })
  end)

end)

describe("piemenu.clear()", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it("TODO", function()
    piemenu.clear("default")
  end)

end)

describe("piemenu.clear_all()", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it("TODO", function()
    piemenu.clear_all()
  end)

end)
