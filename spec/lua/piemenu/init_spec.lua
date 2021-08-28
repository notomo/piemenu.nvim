local helper = require("piemenu.lib.testlib.helper")
local piemenu = helper.require("piemenu")

describe("piemenu.start()", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it("shows pie menu", function()
    piemenu.register("default", {
      menus = {
        {
          text = "text A",
          action = function()
          end,
        },
        {
          text = "text B",
          action = function()
          end,
        },
      },
    })

    piemenu.start("default", {position = {vim.o.lines / 2, vim.o.columns / 2}})

    assert.filetype("piemenu")
    assert.window_count(4)
  end)

  it("raises error if menus is empty", function()
    piemenu.register("default", {menus = {{}, {}}})

    piemenu.start("default")

    assert.exists_message("no menus for `default`")
  end)

  it("can show space if menu is empty dict", function()
    local called = false
    piemenu.register("default", {
      menus = {
        {},
        {},
        {
          text = "text A",
          action = function()
            called = true
          end,
        },
      },
    })

    piemenu.start("default", {position = {math.floor(vim.o.lines / 2) - 3, vim.o.columns / 2}})
    helper.wait()

    vim.api.nvim_win_set_cursor(0, {vim.o.lines - 1, math.floor(vim.o.columns / 2)})
    piemenu.select()

    assert.is_true(called)
  end)

end)

describe("piemenu.hover()", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it("highlights a menu if cursor is in area", function()
    piemenu.register("default", {
      menus = {
        {
          text = "text A",
          action = function()
          end,
        },
      },
    })

    piemenu.start("default", {position = {vim.o.lines / 2, vim.o.columns / 2}})
    helper.wait()

    vim.api.nvim_win_set_cursor(0, {math.floor(vim.o.lines / 2), vim.o.columns})
    piemenu.hover()

    assert.exists_highlighted_window("PimenuCurrent")
  end)

end)

describe("piemenu.select()", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it("executes selected menu's action", function()
    local called = false
    piemenu.register("default", {
      menus = {
        {
          text = "text A",
          action = function()
            called = true
          end,
        },
      },
    })

    piemenu.start("default", {position = {vim.o.lines / 2, vim.o.columns / 2}})
    helper.wait()

    vim.api.nvim_win_set_cursor(0, {math.floor(vim.o.lines / 2), vim.o.columns})
    piemenu.select()

    assert.is_true(called)
  end)

end)

describe("piemenu.cancel()", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it("closes pie menu", function()
    local called = false

    piemenu.register("default", {
      menus = {
        {
          text = "text A",
          action = function()
            called = true
          end,
        },
        {
          text = "text B",
          action = function()
            called = true
          end,
        },
      },
    })

    piemenu.start("default", {position = {vim.o.lines / 2, vim.o.columns / 2}})
    piemenu.cancel()

    assert.is_false(called)
    assert.filetype("")
    assert.window_count(1)
  end)

end)

describe("piemenu.register()", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it("registers menus", function()
    piemenu.register("default", {
      menus = {
        {
          text = "text A",
          action = function()
          end,
        },
        {
          text = "text B",
          action = function()
          end,
        },
      },
    })
    piemenu.start("default")
  end)

  it("can overwrite setting", function()
    piemenu.register("default", {menus = {}})
    piemenu.register("default", {
      menus = {
        {
          text = "text A",
          action = function()
          end,
        },
      },
    })
    piemenu.start("default")
  end)

  it("can register empty menus", function()
    piemenu.register("default", {
      menus = {
        {
          text = "text A",
          action = function()
          end,
        },
        {},
        {},
        {
          text = "text B",
          action = function()
          end,
        },
      },
    })
    piemenu.start("default")
  end)

end)

describe("piemenu.clear()", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it("clears a setting by name", function()
    piemenu.register("default", {
      menus = {
        {
          text = "text A",
          action = function()
          end,
        },
      },
    })

    piemenu.clear("default")

    piemenu.start("default")
    assert.exists_message("no menus for `default`")
  end)

end)

describe("piemenu.clear_all()", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it("clears all settings", function()
    piemenu.register("default1", {
      menus = {
        {
          text = "text A",
          action = function()
          end,
        },
      },
    })
    piemenu.register("default2", {
      menus = {
        {
          text = "text A",
          action = function()
          end,
        },
      },
    })

    piemenu.clear_all()

    piemenu.start("default1")
    assert.exists_message("no menus for `default1`")

    piemenu.start("default2")
    assert.exists_message("no menus for `default2`")
  end)

end)
