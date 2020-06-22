-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

local vicious = require("vicious")
-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")
local host = require("host")
local pbattery = require("awesome-wm-widgets.battery-widget.battery")
local mpdarc_widget = require("awesome-wm-widgets.mpdarc-widget.mpdarc")
local watch = require("awful.widget.watch")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init("~/.config/awesome/themes/default/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "xfce4-terminal"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- EDIT: custom functions

set_sizehints = function(c)
    -- disable size hints for windows that are in tiling mode
    c.size_hints_honor = c.floating
end

sort_client = function(c)
    -- assign tags to windows based on name
    if c.name then
        local tagstring = nil
        if string.match(c.name, "%[%[fun%]%]") or string.match(c.name, "%[%[rice%]%]") then
            tagstring = "web"
        elseif string.match(c.name, "%[%[school1%]%]") then
            tagstring = "school1"
        elseif string.match(c.name, "%[%[school2%]%]") then
            tagstring = "school2"
        elseif string.match(c.name, "%[%[school3%]%]") then
            tagstring = "school3"
        elseif string.match(c.name, "%[%[school4%]%]") then
            tagstring = "school4"
        elseif string.match(c.name, "%[%[work%]%]") then
            tagstring = "work"
        elseif string.match(c.name, "%[%[hobby%]%]") or string.match(c.name, "%[%[graphics%]%]") then
            tagstring = "hobby"
        elseif string.match(c.name, "%[%[temp%]%]") or string.match(c.name, "%[%[a%]%]") then
            tagstring = "a"
        elseif string.match(c.name, "%[%[p%]%]") or string.match(c.name, "%[%[b%]%]") then
            tagstring = "b"
        end
        newtag = awful.tag.find_by_name(awful.screen.focused(), tagstring)
        if newtag then
            c:move_to_tag(newtag)
        end
    end
end

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    -- EDIT: rearranged tiling modes
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.tile,
    -- awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.floating,
    -- awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
-- EDIT: adjust margin
clock_container = wibox.widget {
    wibox.widget.textclock(),
    layout = wibox.container.margin(_, 4, 8, 0)
}

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local function set_wallpaper()
    -- NOTE: using feh for setting wallpaper
    awful.spawn.with_shell("~/.fehbg")
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Each screen has its own tag table.
    awful.tag({ "web", "school1", "school2", "school3", "school4", "work", "hobby", "a", "b" }, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,
        -- remove tasklist text
        layout = wibox.layout.fixed.horizontal(),
        widget_template = {
            {
                {
                    {
                        id     = 'icon_role',
                        widget = wibox.widget.imagebox,
                    },
                    margins = 0,
                    widget  = wibox.container.margin,
                },
                left   = 5,
                right  = 5,
                widget = wibox.container.margin
            },
            id     = 'background_role',
            widget = wibox.container.background,
        }
    }

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s, bg = "#00000077"})

    -- EDIT: custom widgets
    s.systray = wibox.widget.systray()
    s.systray.visible = true

    mpdwidget_container = wibox.widget {
        mpdarc_widget,
        layout = wibox.container.margin(_,4,4,0)
    }

    cpugraph_all = awful.widget.graph({width = 16})
    cpugraph_cpu1 = awful.widget.graph({width = 8})
    cpugraph_cpu2 = awful.widget.graph({width = 8})
    cpugraph_cpu3 = awful.widget.graph({width = 8})
    cpugraph_cpu4 = awful.widget.graph({width = 8})
    cpugraph_cpu5 = awful.widget.graph({width = 8})
    cpugraph_cpu6 = awful.widget.graph({width = 8})
    cpugraph_cpu7 = awful.widget.graph({width = 8})
    cpugraph_cpu8 = awful.widget.graph({width = 8})
    -- TODO: try to get all widgets to update using the same watch widget
    watch([[bash -c "mpstat 5 1 | awk '{if(NR==4) printf \"%3.0f\n\", 100 - \$NF }'"]], 1,
    function(widget, s)
        widget:add_value(tonumber(s) / 100)
    end,
    cpugraph_all)
    watch([[bash -c "mpstat -P 0 5 1 | awk '{if(NR==4) printf \"%3.0f\n\", 100 - \$NF }'"]], 1,
    function(widget, s)
        widget:add_value(tonumber(s) / 100)
    end,
    cpugraph_cpu1)
    watch([[bash -c "mpstat -P 1 5 1 | awk '{if(NR==4) printf \"%3.0f\n\", 100 - \$NF }'"]], 1,
    function(widget, s)
        widget:add_value(tonumber(s) / 100)
    end,
    cpugraph_cpu2)
    watch([[bash -c "mpstat -P 2 5 1 | awk '{if(NR==4) printf \"%3.0f\n\", 100 - \$NF }'"]], 1,
    function(widget, s)
        widget:add_value(tonumber(s) / 100)
    end,
    cpugraph_cpu3)
    watch([[bash -c "mpstat -P 3 5 1 | awk '{if(NR==4) printf \"%3.0f\n\", 100 - \$NF }'"]], 1,
    function(widget, s)
        widget:add_value(tonumber(s) / 100)
    end,
    cpugraph_cpu4)
    watch([[bash -c "mpstat -P 4 5 1 | awk '{if(NR==4) printf \"%3.0f\n\", 100 - \$NF }'"]], 1,
    function(widget, s)
        widget:add_value(tonumber(s) / 100)
    end,
    cpugraph_cpu5)
    watch([[bash -c "mpstat -P 5 5 1 | awk '{if(NR==4) printf \"%3.0f\n\", 100 - \$NF }'"]], 1,
    function(widget, s)
        widget:add_value(tonumber(s) / 100)
    end,
    cpugraph_cpu6)
    watch([[bash -c "mpstat -P 6 5 1 | awk '{if(NR==4) printf \"%3.0f\n\", 100 - \$NF }'"]], 1,
    function(widget, s)
        widget:add_value(tonumber(s) / 100)
    end,
    cpugraph_cpu7)
    watch([[bash -c "mpstat -P 7 5 1 | awk '{if(NR==4) printf \"%3.0f\n\", 100 - \$NF }'"]], 1,
    function(widget, s)
        widget:add_value(tonumber(s) / 100)
    end,
    cpugraph_cpu8)
    cpugraph_container = wibox.widget {
        wibox.widget {
            wibox.widget {
                cpugraph_cpu8,
                cpugraph_cpu6,
                cpugraph_cpu4,
                cpugraph_cpu2,
                cpugraph_cpu7,
                cpugraph_cpu5,
                cpugraph_cpu3,
                cpugraph_cpu1,
                forced_num_rows = 2,
                forced_num_cols = 4,
                homogenous = true,
                expand = true,
                spacing = 1,
                layout = wibox.layout.grid
            },
            wibox.widget {
                cpugraph_all,
                layout = wibox.container.margin(_,1,0,0)
            },
            layout = wibox.layout.fixed.horizontal
        },
        reflection = {
            horizontal = true;
            vertical = false;
        },
        layout = wibox.container.mirror
    }
    cpuwidget_container = wibox.widget {
        wibox.widget {
            wibox.widget.imagebox(os.getenv("HOME").."/.config/awesome/icons/indicator-cpufreq_17x17.png", true),
            wibox.widget {
                cpugraph_container,
                layout = wibox.container.margin(_, 4, 0, 0)
            },
            layout = wibox.layout.fixed.horizontal
        },
        layout = wibox.container.margin(_, 4, 4, 0)
    }

    memwidget = wibox.widget.textbox()
    vicious.register(memwidget, vicious.widgets.mem,
    function (widget, args)
        return ("<span font='monospace'>%3d%% %4dMiB</span>"):format(args[1], args[2])
    end, 5)
    memwidget_container = wibox.widget {
        wibox.widget {
            wibox.widget.imagebox(os.getenv("HOME").."/.config/awesome/icons/indicator-sensors-memory.png", true),
            wibox.widget {
                memwidget,
                layout = wibox.container.margin(_, 0, 0, 2)
            },
            layout = wibox.layout.fixed.horizontal
        },
        layout = wibox.container.margin(_, 4, 4, 0)
    }
    kblayout_container = wibox.widget {
        mykeyboardlayout,
        layout = wibox.container.margin(_, 4, 0, 0)
    }

    arandr_button = nil
    batwidget_container = nil
    if host.is_laptop == true then
        -- NOTE: Arc icon theme must be installed and in the directory /usr/share/.icons
        batwidget_container = wibox.widget {
            wibox.widget {
                pbattery(),
                awful.widget.watch('bash -c "~/Documents/tools/battstat.sh -1"', 15),
                layout = wibox.layout.fixed.horizontal
            },
            layout = wibox.container.margin(_, 4, 4, 0)
        }
        arandr_button = awful.widget.launcher({ image = "/home/londes/.icons/Papirus/24x24/panel/desktopconnected.svg" , command = "arandr" })
    end


    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            s.systray,
            mpdwidget_container,
            kblayout_container,
            batwidget_container,
            cpuwidget_container,
            memwidget_container,
            clock_container,
            arandr_button,
            s.mylayoutbox,
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    -- EDIT: fix super-tab
    awful.key({ modkey,           }, "Tab",
	function ()
	    -- awful.client.focus.history.previous()
	    awful.client.focus.byidx(-1)
	    if client.focus then
		client.focus:raise()
	    end
	end),

    awful.key({ modkey, "Shift"   }, "Tab",
	function ()
	    -- awful.client.focus.history.previous()
	    awful.client.focus.byidx(1)
	    if client.focus then
		client.focus:raise()
	    end
	end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Prompt
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"}),

    -- EDIT: custom keybinds
    awful.key({                   }, "Print",
              function () awful.spawn.with_shell("sleep 0.1 && ~/.scripts/screenshot2.sh full") end,
              { description = "take a full screen screenshot" }),
    awful.key({             "Mod1" }, "Print",
              function () awful.spawn.with_shell("sleep 0.1 && ~/.scripts/screenshot2.sh window") end,
              { description = "take a window screenshot" }),
    awful.key({           "Shift" }, "Print",
              function () awful.spawn.with_shell("sleep 0.1 && ~/.scripts/screenshot2.sh crop") end,
              { description = "take a cropped screenshot" }),
    awful.key({"Mod4", "Mod1"}, "n",
              function () awful.spawn.with_shell("xclip -o | xargs mpv") end,
              { description = "open copied url in mpv" }),
    awful.key({"Mod4", "Mod1"}, "m",
              function () awful.spawn.with_shell("~/.scripts/sinkswitch.sh") end,
              { description = "switch pulseaudio output sink of currently active client" }),
    awful.key({"Control", "Mod1"}, "l",
              function () awful.spawn.with_shell("i3lock -uc aa0000") end,
              { description = "lock the screen" }),
    awful.key({"Control", "Mod1"}, "Delete",
              function () awful.spawn.with_shell("systemctl suspend") end,
              { description = "suspend the system"}),
    awful.key({                 }, "XF86AudioRaiseVolume",
              function () awful.spawn.with_shell("pactl set-sink-volume @DEFAULT_SINK@ +5%") end,
              { description = "raise volume"}),
    awful.key({                 }, "XF86AudioLowerVolume",
              function () awful.spawn.with_shell("pactl set-sink-volume @DEFAULT_SINK@ -5%") end,
              { description = "lower volume"}),
    awful.key({ "Mod4"          }, "F2",
              function () awful.spawn.with_shell("pactl set-sink-volume @DEFAULT_SINK@ -5%") end,
              { description = "lower volume"}),
    awful.key({ "Mod4"          }, "F3",
              function () awful.spawn.with_shell("pactl set-sink-volume @DEFAULT_SINK@ +5%") end,
              { description = "raise volume"}),
    awful.key({ "Mod4"            }, "F4",
              function () awful.spawn.with_shell("~/Documents/tools/hdmiswitch.sh") end,
              { description = "switch between HDMI and analog outputs"}),
    awful.key({modkey, "Mod1"}, "s",
              function () 
                  for _, c in ipairs(client.get()) do
                      sort_client(c)
                  end
              end,
              { description = "sort windows based on name, see sort_client in rc.lua"}),
    awful.key({modkey,    "Mod1"}, "t",
              function () awful.spawn("telegram-desktop") end,
              { description = "open Telegram" }),
    awful.key({ modkey }, "=",
              function ()
                awful.screen.focused().systray.visible = not awful.screen.focused().systray.visible
              end,
              {description = "Toggle systray visibility", group = "custom"}),
    awful.key({"Mod4",    "Mod1"}, "c",
              function () awful.spawn.with_shell("mpc toggle") end,
              { description = "play/pause mpd" }),
    awful.key({ modkey, "Control" }, "Tab", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control", "Shift" }, "Tab", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"})
)

if host.is_laptop == true then
    gears.table.merge(globalkeys, gears.table.join(
        awful.key({ "Mod4"            }, "F5",
                  function () awful.spawn.with_shell("sudo /root/scripts/backlight.sh -d") end,
                  { description = "lower brightness"}),
        awful.key({ "Mod4"            }, "F6",
                  function () awful.spawn.with_shell("sudo /root/scripts/backlight.sh -u") end,
                  { description = "raise brighness"}),
        awful.key({           "Shift" }, "XF86Display",
                  function () awful.spawn.with_shell("arandr") end,
                  { description = "open display configuration manager"}),
        awful.key({ "Mod4",   "Shift" }, "F7",
                  function () awful.spawn.with_shell("arandr") end,
                  { description = "open display configuration manager"}),
        awful.key({                   }, "XF86Display",
                  function () awful.spawn.with_shell("autorandr --change") end,
                  { description = "toggle or reset display configuration"}),
        awful.key({ "Mod4"            }, "F7",
                  function () awful.spawn.with_shell("autorandr --change") end,
                  { description = "toggle or reset display configuration"})
                  )
    )
end

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    -- EDIT: removed titlebars from everything
    { rule_any = {type = { "normal", "dialog" } },
      -- except_any = { class = { "firefox", "Termite", "mpv"} },
      properties = { titlebars_enabled = false }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "firefox" },
    -- properties = { screen = 1, tag = "web" } },

    -- EDIT: custom rules
    -- { rule = { class = "mpv" },
    -- properties = { floating = true }},
    { rule_any = { class = { "TelegramDesktop", "Audacious" }},
        screen = awful.screen.focused,
        properties = { sticky = true, skip_taskbar = true }
    }
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
    set_sizehints(c)
    sort_client(c)
    -- EDIT: place clients next to master
    if not awesome.startup then
        awful.client.swap.byidx(1)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- rice

awful.spawn.with_shell("~/.config/awesome/autorun.sh")

beautiful.useless_gap = beautiful.xresources.apply_dpi(host.gap)

client.connect_signal("property::floating", set_sizehints)
client.connect_signal("property::name", sort_client)

-- enable restoration of client layout on change of screen configuration
-- Save and restore tags, when monitor setup is changed
local naughty = require("naughty")
local tag_store = {}
tag.connect_signal("request::screen", function(t)
  local fallback_tag = nil

  -- find tag with same name on any other screen
  for other_screen in screen do
    if other_screen ~= t.screen then
      fallback_tag = awful.tag.find_by_name(other_screen, t.name)
      if fallback_tag ~= nil then
        break
      end
    end
  end

  -- no tag with same name exists, chose random one
  if fallback_tag == nil then
    fallback_tag = awful.tag.find_fallback()
  end

  if not (fallback_tag == nil) then
    local output = next(t.screen.outputs)

    if tag_store[output] == nil then
      tag_store[output] = {}
    end

    clients = t:clients()
    tag_store[output][t.name] = clients

    for _, c in ipairs(clients) do
      c:move_to_tag(fallback_tag)
    end
  end
end)

screen.connect_signal("added", function(s)
  local output = next(s.outputs)
  naughty.notify({ text = output .. " Connected" })

  tags = tag_store[output]
  if not (tags == nil) then
    naughty.notify({ text = "Restoring Tags" })

    for _, tag in ipairs(s.tags) do
      clients = tags[tag.name]
      if not (clients == nil) then
        for _, client in ipairs(clients) do
          client:move_to_tag(tag)
        end
      end
    end
  end
end)

