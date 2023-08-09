local helper = require("piemenu.test.helper")
local piemenu = helper.require("piemenu")

describe("piemenu.start()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("shows pie menu", function()
    piemenu.register("default", {
      menus = {
        {
          text = "text A",
          action = function() end,
        },
        {
          text = "text B",
          action = function() end,
        },
      },
    })

    piemenu.start("default", { position = { vim.o.lines / 2, vim.o.columns / 2 } })

    assert.filetype("piemenu")
    assert.window_count(4)
  end)

  it("raises error if menus is empty", function()
    piemenu.register("default", { menus = { {}, {} } })

    local ok, err = pcall(function()
      piemenu.start("default")
    end)
    assert.is_false(ok)
    assert.match("no menus for `default`", err)
  end)

  it("can show space if menu is empty dict", function()
    local called = false
    piemenu.register("default", {
      animation = { duration = 0 },
      radius = 5.0,
      menus = {
        {},
        {
          text = "text A",
          action = function()
            called = true
          end,
        },
        {},
        {},
      },
    })

    piemenu.start("default", { position = { math.floor(vim.o.lines / 2) - 3, vim.o.columns / 2 } })

    vim.api.nvim_win_set_cursor(0, { vim.o.lines - 1, math.floor(vim.o.columns / 2) })
    piemenu.finish()

    assert.is_true(called)
  end)

  it("fallbacks if menu can't be displayed", function()
    piemenu.register("default", {
      animation = { duration = 0 },
      start_angle = -90,
      menus = {
        {
          text = "text A",
          action = function() end,
        },
      },
    })

    piemenu.start("default", { position = { 1, vim.o.columns / 2 } })

    assert.window_count(3)
  end)

  it("shows validate error with position", function()
    piemenu.register("default", {
      menus = {
        {
          text = "text A",
          action = function() end,
        },
      },
    })

    local ok, err = pcall(function()
      piemenu.start("default", { position = { -1, -1 } })
    end)
    assert.is_false(ok)
    assert.match([[position: expected between { 1, 1 } and { 22, 80 }]], err)
  end)

  it("shows an error with too large radius", function()
    piemenu.register("default", {
      menus = {
        {
          text = "text A",
          action = function() end,
        },
      },
    })

    local ok, err = pcall(function()
      piemenu.start("default", { radius = 1000 })
    end)
    assert.is_false(ok)
    assert.match([[could not open: radius=1000]], err)
    assert.window_count(1)
  end)
end)

describe("piemenu.highlight()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("highlights a menu if cursor is in area", function()
    piemenu.register("default", {
      animation = { duration = 0 },
      radius = 5.0,
      menus = {
        {
          text = "text A",
          action = function() end,
        },
      },
    })

    piemenu.start("default", { position = { vim.o.lines / 2, vim.o.columns / 2 } })

    vim.api.nvim_win_set_cursor(0, { math.floor(vim.o.lines / 2), vim.o.columns })
    piemenu.highlight()

    assert.exists_highlighted_window("PiemenuCurrent")
  end)

  it("highlights a menu if mouse cursor is in area with mousemoveevent", function()
    vim.o.mousemoveevent = true

    piemenu.register("default", {
      animation = { duration = 0 },
      radius = 5.0,
      menus = {
        {
          text = "text A",
          action = function() end,
        },
      },
    })

    piemenu.start("default", { position = { vim.o.lines / 2, vim.o.columns / 2 } })

    vim.api.nvim_input_mouse("left", "press", "", 0, math.floor(vim.o.lines / 2), vim.o.columns)
    piemenu.highlight()

    assert.exists_highlighted_window("PiemenuCurrent")
  end)
end)

describe("piemenu.finish()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("executes selected menu's action", function()
    local called = false
    piemenu.register("default", {
      animation = { duration = 0 },
      radius = 5.0,
      menus = {
        {
          text = "text A",
          action = function()
            called = true
          end,
        },
      },
    })

    piemenu.start("default", { position = { vim.o.lines / 2, vim.o.columns / 2 } })

    vim.api.nvim_win_set_cursor(0, { math.floor(vim.o.lines / 2), vim.o.columns })
    piemenu.finish()

    assert.is_true(called)
  end)

  it("raises error if action raises error", function()
    piemenu.register("default", {
      animation = { duration = 0 },
      radius = 5.0,
      menus = {
        {
          text = "text A",
          action = function()
            error("test", 0)
          end,
        },
      },
    })

    piemenu.start("default", { position = { vim.o.lines / 2, vim.o.columns / 2 } })

    vim.api.nvim_win_set_cursor(0, { math.floor(vim.o.lines / 2), vim.o.columns })
    local ok, err = pcall(function()
      piemenu.finish()
    end)
    assert.is_false(ok)
    assert.equal([=[[piemenu] test]=], err)
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

    piemenu.start("default", { position = { vim.o.lines / 2, vim.o.columns / 2 } })
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
          action = function() end,
        },
        {
          text = "text B",
          action = function() end,
        },
      },
    })
    piemenu.start("default")
  end)

  it("can overwrite setting", function()
    piemenu.register("default", { menus = {} })
    piemenu.register("default", {
      menus = {
        {
          text = "text A",
          action = function() end,
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
          action = function() end,
        },
        {},
        {},
        {
          text = "text B",
          action = function() end,
        },
      },
    })
    piemenu.start("default")
  end)

  it("shows validate error with tile_width", function()
    local ok, err = pcall(function()
      piemenu.register("default", { tile_width = 2.9, menus = {} })
    end)
    assert.is_false(ok)
    assert.match([[tile_width: expected equal or greater than 3, got 2.9]], err)
  end)

  it("shows validate error with radius", function()
    local ok, err = pcall(function()
      piemenu.register("default", { radius = -1, menus = {} })
    end)
    assert.is_false(ok)
    assert.match([[radius: expected greater than 0, got %-1]], err)
  end)

  it("shows validate error with small position", function()
    local ok, err = pcall(function()
      piemenu.register("default", { position = { -1, -1 }, menus = {} })
    end)
    assert.is_false(ok)
    assert.match([[position: expected between { 1, 1 } and { 22, 80 }]], err)
  end)

  it("shows validate error with large position", function()
    local ok, err = pcall(function()
      piemenu.register("default", { position = { 1000, 1000 }, menus = {} })
    end)
    assert.is_false(ok)
    assert.match([[position: expected between { 1, 1 } and { 22, 80 }]], err)
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
          action = function() end,
        },
      },
    })

    piemenu.clear("default")

    local ok, err = pcall(function()
      piemenu.start("default")
    end)
    assert.is_false(ok)
    assert.match("no menus for `default`", err)
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
          action = function() end,
        },
      },
    })
    piemenu.register("default2", {
      menus = {
        {
          text = "text A",
          action = function() end,
        },
      },
    })

    piemenu.clear_all()

    local ok1, err1 = pcall(function()
      piemenu.start("default1")
    end)
    assert.is_false(ok1)
    assert.match("no menus for `default1`", err1)

    local ok2, err2 = pcall(function()
      piemenu.start("default2")
    end)
    assert.is_false(ok2)
    assert.match("no menus for `default2`", err2)
  end)
end)
