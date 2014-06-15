-- => Initialization and Modules {{{
-- ====================================================================

-- Standard awesome library
local gears = require('gears')
local awful = require('awful')
awful.rules = require('awful.rules')
require('awful.autofocus')

-- Widget and layout library
local wibox = require('wibox')

-- Theme handling library
local beautiful = require('beautiful')
beautiful.init(awful.util.getdir('config') .. '/themes/default/theme.lua')

-- Notification library
local naughty = require('naughty')
local menubar = require('menubar')

-- FreeDesktop
require('freedesktop.utils')
require('freedesktop.menu')
freedesktop.utils.icon_theme = {'faenza', 'gnome'}

-- Vicious (Widgets)
vicious = require('vicious')

-- }}}
-- => Error handling {{{
-- ====================================================================
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
  naughty.notify({preset = naughty.config.presets.critical,
                  title = 'Oops, there were errors during startup!',
                  text = awesome.startup_errors})
end

-- Handle runtime errors after startup
do
  local in_error = false
  awesome.connect_signal('debug::error', function (err)
    -- Make sure we don't go into an endless error loop
    if in_error then return end
    in_error = true

    naughty.notify({preset = naughty.config.presets.critical,
                    title = 'Oops, an error happened!',
                    text = err})
    in_error = false
  end)
end
-- }}}
-- => Variable definitions {{{
-- ====================================================================

-- This is used later as the default terminal and editor to run.
terminal   = 'urxvt'
editor     = os.getenv('EDITOR') or 'vim'
editor_cmd = terminal .. ' -e ' .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = 'Mod4'

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
  -- awful.layout.suit.floating,
  awful.layout.suit.tile,
  awful.layout.suit.tile.left,
  awful.layout.suit.tile.bottom,
  awful.layout.suit.tile.top,
  awful.layout.suit.fair,
  awful.layout.suit.fair.horizontal,
  -- awful.layout.suit.spiral,
  -- awful.layout.suit.spiral.dwindle,
  awful.layout.suit.max,
  awful.layout.suit.max.fullscreen,
  -- awful.layout.suit.magnifier
}
-- }}}
-- => Naughty Configuration {{{
-- ====================================================================

naughty.config.defaults.margin          = 8
naughty.config.defaults.ontop           = true
naughty.config.defaults.font            = 'Droid Sans 10'
naughty.config.defaults.border_width    = 2
naughty.config.defaults.hover_timeout   = nil

naughty.config.presets.critical.bg            = '#da4939'
naughty.config.presets.critical.fg            = '#f9f7f3'
naughty.config.presets.critical.border_color  = '#da4939'

-- }}}
-- => Wallpaper {{{
-- ====================================================================
if beautiful.wallpaper then
  for s = 1, screen.count() do
    gears.wallpaper.maximized(beautiful.wallpaper, s, true)
  end
end
-- }}}
-- => Tags {{{
-- ====================================================================
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
  -- Each screen has its own tag table.
  tags[s] = awful.tag({1, 2, 3, 4, 5, 6, 7, 8, 9}, s, layouts[1])
end
-- }}}
-- => Wallpaper Changer {{{
local wallpaper_menu = {}
local function wallpaper_load(wallpaper)
  local config_dir = awful.util.getdir('config')
  local f = io.popen('ln -sfn ' .. config_dir .. '/wallpapers/' .. wallpaper ..
                     ' ' .. config_dir .. '/themes/default/background.png')
  awesome.restart()
end

local function populate_wallpaper_menu()
  local f = io.popen('ls -1 ' .. awful.util.getdir('config') .. '/wallpapers/')
 
  for l in f:lines() do
    local item = {l, function () wallpaper_load(l) end}
    table.insert(wallpaper_menu, item)
  end
 
  f:close()
end
populate_wallpaper_menu()
-- }}}
-- => Menu {{{
-- ====================================================================

-- Create a FreeDesktop menu
menu_items = freedesktop.menu.new()

-- Create a launcher widget and a main menu
awesome_menu = {
  {'manual',      terminal .. ' -e man awesome', freedesktop.utils.lookup_icon({icon = 'help'})},
  {'edit config', editor_cmd .. ' ' .. awesome.conffile, freedesktop.utils.lookup_icon({icon = 'package_settings'})},
  {'restart',     awesome.restart, freedesktop.utils.lookup_icon({icon = 'sytem_shutdown'})},
  {'quit',        awesome.quit, freedesktop.utils.lookup_icon({icon = 'sytem_shutdown'})}
}

table.insert(menu_items, {'Awesome', awesome_menu, beautiful.awesome_icon})
table.insert(menu_items, {'Wallpaper', wallpaper_menu, freedesktop.utils.lookup_icon({icon = 'gnome-settings-background'})})

main_menu = awful.menu({items = menu_items, width = 150})

launcher = awful.widget.launcher({image = beautiful.awesome_icon,
                                    menu = main_menu})

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}
-- => Widgets {{{
-- ====================================================================

clock = awful.widget.textclock()

spacer = wibox.widget.textbox()
spacer:set_text(' | ')

weather = wibox.widget.textbox()
weather_format = '${city}: ' ..
                 '${sky}, ' ..
                 '${tempf}F, ' ..
                 '${humid}%, ' ..
                 '${windmph}mph.'
vicious.register(weather, vicious.widgets.weather, weather_format, 1800, 'KLBB')

-- Pacman {{{
pacman_icon = wibox.widget.imagebox()
pacman_icon:set_image(beautiful.widget_pacman_default)

pacman = wibox.widget.textbox()
vicious.register(pacman, vicious.widgets.pkg, function (widget, args)
  if args[1] > 0 then
    pacman_icon:set_image(beautiful.widget_pacman_new)
  else
    pacman_icon:set_image(beautiful.widget_pacman_default)
  end

  return args[1]
end, 1800, 'Arch S')

function pacman_popup()
  local pacman_updates = ''
  local f = io.popen('pacman -Sup --dbpath /tmp/pacsync')

  if f then
    pacman_updates = f:read('*a'):match('.*/(.*)-.*\n$')
  end
  
  f:close()

  if not pacman_updates then
    pacman_updates = 'System is up-to-date'
  end

  naughty.notify({text = pacman_updates})
end

pacman:buttons(awful.util.table.join(awful.button({}, 1, pacman_popup)))
pacman_icon:buttons(pacman:buttons())
-- }}}

-- Volume {{{

vicious.cache(vicious.widgets.volume)

volume_spacer = wibox.widget.textbox()
volume_spacer:set_text(' ')

volume_icon = wibox.widget.imagebox()
volume_icon:set_image(beautiful.widget_volume)

volume_percent = wibox.widget.textbox()
vicious.register(volume_percent, vicious.widgets.volume, '$1%', nil, 'Master')

volume_icon:buttons(awful.util.table.join(
  awful.button({}, 1, function () awful.util.spawn_with_shell('amixer -q set Master toggle') end),
  awful.button({}, 4, function () awful.util.spawn_with_shell('amixer -q set Master 3+% unmute') end),
  awful.button({}, 5, function () awful.util.spawn_with_shell('amixer -q set Master 30% unmute') end)
))
volume_percent:buttons(volume_icon:buttons())
volume_spacer:buttons(volume_icon:buttons())

-- }}}

-- Calendar {{{

require('calendar2')
calendar2.addCalendarToWidget(clock)

-- }}}

-- CPU {{{

cpu_icon = wibox.widget.imagebox()
cpu_icon:set_image(beautiful.widget_cpu)

cpu = wibox.widget.textbox()
vicious.register(cpu, vicious.widgets.cpu, "All: $1% 1: $2% 2: $3% 3: $4% 4: $5%", 2)

-- }}}
-- }}}
-- => Wibox {{{
-- ====================================================================

-- Create a wibox for each screen and add it
top_wibox  = {}
info_wibox = {}
prompt_box = {}
layout_box = {}
tag_list   = {}
tag_list.buttons = awful.util.table.join(
                      awful.button({}, 1, awful.tag.viewonly),
                      awful.button({modkey}, 1, awful.client.movetotag),
                      awful.button({}, 3, awful.tag.viewtoggle),
                      awful.button({modkey}, 3, awful.client.toggletag),
                      awful.button({}, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                      awful.button({}, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
task_list = {}
task_list.buttons = awful.util.table.join(
                       awful.button({}, 1, function (c)
                                             if c == client.focus then
                                               c.minimized = true
                                             else
                                               -- Without this, the following
                                               -- :isvisible() makes no sense
                                               c.minimized = false
                                               if not c:isvisible() then
                                                 awful.tag.viewonly(c:tags()[1])
                                               end
                                               -- This will also un-minimize
                                               -- the client, if needed
                                               client.focus = c
                                               c:raise()
                                             end
                                           end),
                       awful.button({}, 3, function ()
                                             if instance then
                                               instance:hide()
                                               instance = nil
                                             else
                                               instance = awful.menu.clients({
                                                 theme = {width = 250}
                                               })
                                             end
                                           end),
                       awful.button({}, 4, function ()
                                             awful.client.focus.byidx(1)
                                             if client.focus then client.focus:raise() end
                                           end),
                       awful.button({}, 5, function ()
                                             awful.client.focus.byidx(-1)
                                             if client.focus then client.focus:raise() end
                                           end)
                     )

for s = 1, screen.count() do
  -- Create a promptbox for each screen
  prompt_box[s] = awful.widget.prompt()
  -- Create an imagebox widget which will contains an icon indicating which layout we're using.
  -- We need one layoutbox per screen.
  layout_box[s] = awful.widget.layoutbox(s)
  layout_box[s]:buttons(awful.util.table.join(
                          awful.button({}, 1, function () awful.layout.inc(layouts, 1) end),
                          awful.button({}, 3, function () awful.layout.inc(layouts, -1) end),
                          awful.button({}, 4, function () awful.layout.inc(layouts, 1) end),
                          awful.button({}, 5, function () awful.layout.inc(layouts, -1) end)))
  -- Create a taglist widget
  tag_list[s]  = awful.widget.taglist(s, awful.widget.taglist.filter.all, tag_list.buttons)

  -- Create a tasklist widget
  task_list[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, task_list.buttons)

  -- Create the wibox
  top_wibox[s] = awful.wibox({position = 'top', screen = s})

  -- Widgets that are aligned to the left
  local left_layout = wibox.layout.fixed.horizontal()
  left_layout:add(launcher)
  left_layout:add(tag_list[s])
  left_layout:add(prompt_box[s])

  -- Widgets that are aligned to the right
  local right_layout = wibox.layout.fixed.horizontal()
  if s == 1 then right_layout:add(wibox.widget.systray()) end
  right_layout:add(pacman_icon)
  right_layout:add(pacman)

  right_layout:add(spacer)

  right_layout:add(volume_icon)
  right_layout:add(volume_percent)
  right_layout:add(volume_spacer)

  right_layout:add(spacer)

  right_layout:add(clock)
  right_layout:add(layout_box[s])

  -- Now bring it all together (with the tasklist in the middle)
  local layout = wibox.layout.align.horizontal()
  layout:set_left(left_layout)
  layout:set_middle(task_list[s])
  layout:set_right(right_layout)

  top_wibox[s]:set_widget(layout)

  -- Create the bottom infobox
  info_wibox[s] = awful.wibox({position = 'bottom', screen = s})

  local infobox_layout = wibox.layout.fixed.horizontal()
  infobox_layout:add(cpu_icon)
  infobox_layout:add(cpu)

  infobox_layout:add(spacer)

  infobox_layout:add(weather)

  info_wibox[s]:set_widget(infobox_layout)
end
-- }}}
-- => Mouse bindings {{{
-- ====================================================================
root.buttons(awful.util.table.join(
  awful.button({}, 3, function () main_menu:toggle() end),
  awful.button({}, 4, awful.tag.viewnext),
  awful.button({}, 5, awful.tag.viewprev)
))
-- }}}
-- => Key bindings {{{
-- ====================================================================
globalkeys = awful.util.table.join(
  awful.key({modkey,          }, 'Left',   awful.tag.viewprev       ),
  awful.key({modkey,          }, 'Right',  awful.tag.viewnext       ),
  awful.key({modkey,          }, 'Escape', awful.tag.history.restore),

  awful.key({modkey,          }, 'j',
            function ()
              awful.client.focus.byidx( 1)
              if client.focus then client.focus:raise() end
            end),
  awful.key({modkey,          }, 'k',
            function ()
              awful.client.focus.byidx(-1)
              if client.focus then client.focus:raise() end
            end),

  -- Layout manipulation
  awful.key({modkey, 'Shift'  }, 'j', function () awful.client.swap.byidx(  1)    end),
  awful.key({modkey, 'Shift'  }, 'k', function () awful.client.swap.byidx( -1)    end),
  awful.key({modkey, 'Control'}, 'j', function () awful.screen.focus_relative( 1) end),
  awful.key({modkey, 'Control'}, 'k', function () awful.screen.focus_relative(-1) end),
  awful.key({modkey,          }, 'u', awful.client.urgent.jumpto),
  awful.key({modkey,          }, 'Tab',
            function ()
              awful.client.focus.history.previous()
              if client.focus then
                client.focus:raise()
              end
            end),

  -- Standard program
  awful.key({modkey,          }, 'Return', function () awful.util.spawn(terminal) end),
  awful.key({modkey, 'Control'}, 'r', awesome.restart),
  awful.key({modkey, 'Shift'  }, 'q', awesome.quit),

  awful.key({modkey,          }, 'l',     function () awful.tag.incmwfact( 0.05)    end),
  awful.key({modkey,          }, 'h',     function () awful.tag.incmwfact(-0.05)    end),
  awful.key({modkey, 'Shift'  }, 'h',     function () awful.tag.incnmaster( 1)      end),
  awful.key({modkey, 'Shift'  }, 'l',     function () awful.tag.incnmaster(-1)      end),
  awful.key({modkey, 'Control'}, 'h',     function () awful.tag.incncol( 1)         end),
  awful.key({modkey, 'Control'}, 'l',     function () awful.tag.incncol(-1)         end),
  awful.key({modkey,          }, 'space', function () awful.layout.inc(layouts,  1) end),
  awful.key({modkey, 'Shift'  }, 'space', function () awful.layout.inc(layouts, -1) end),
  awful.key({modkey,          }, 'w',     function () awful.util.spawn('chromium')  end),

  awful.key({modkey, 'Control'}, 'n', awful.client.restore),

  -- Prompt
  awful.key({modkey},            'r',     function () prompt_box[mouse.screen]:run() end),

  awful.key({modkey}, 'x',
            function ()
              awful.prompt.run({prompt = 'Run Lua code: '},
              prompt_box[mouse.screen].widget,
              awful.util.eval, nil,
              awful.util.getdir('cache') .. '/history_eval')
            end),
  -- Menubar
  awful.key({modkey}, 'p', function() menubar.show() end)
)

clientkeys = awful.util.table.join(
    awful.key({modkey,          }, 'f',      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({modkey, 'Shift'  }, 'c',      function (c) c:kill()                         end),
    awful.key({modkey, 'Control'}, 'space',  awful.client.floating.toggle                     ),
    awful.key({modkey, 'Control'}, 'Return', function (c) c:swap(awful.client.getmaster()) end),
    awful.key({modkey,          }, 'o',      awful.client.movetoscreen                        ),
    awful.key({modkey,          }, 't',      function (c) c.ontop = not c.ontop            end),
    awful.key({modkey,          }, 'n',
              function (c)
                -- The client currently has the input focus, so it cannot be
                -- minimized, since minimized clients can't have the focus.
                c.minimized = true
              end),
    awful.key({modkey,          }, 'm',
              function (c)
                c.maximized_horizontal = not c.maximized_horizontal
                c.maximized_vertical   = not c.maximized_vertical
              end)
)

-- Compute the maximum tag number, clamped to 9
num_tags = 0
for s = 1, screen.count() do
  num_tags = math.min(9, math.max(#tags[s], num_tags))
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, num_tags do
  globalkeys = awful.util.table.join(globalkeys,
    -- View tag only.
    awful.key({modkey}, '#' .. i + 9,
              function ()
                local screen = mouse.screen
                local tag = awful.tag.gettags(screen)[i]
                if tag then
                  awful.tag.viewonly(tag)
                end
              end),
    -- Toggle tag.
    awful.key({modkey, 'Control'}, '#' .. i + 9,
              function ()
                local screen = mouse.screen
                local tag = awful.tag.gettags(screen)[i]
                if tag then
                  awful.tag.viewtoggle(tag)
                end
              end),
    -- Move client to tag.
    awful.key({modkey, 'Shift'}, '#' .. i + 9,
              function ()
                if client.focus then
                  local tag = awful.tag.gettags(client.focus.screen)[i]
                  if tag then
                    awful.client.movetotag(tag)
                  end
                end
              end),
    -- Toggle tag.
    awful.key({modkey, 'Control', 'Shift'}, '#' .. i + 9,
              function ()
                if client.focus then
                  local tag = awful.tag.gettags(client.focus.screen)[i]
                  if tag then
                    awful.client.toggletag(tag)
                  end
                end
              end))
end

clientbuttons = awful.util.table.join(
  awful.button({}, 1, function (c) client.focus = c; c:raise() end),
  awful.button({modkey}, 1, awful.mouse.client.move),
  awful.button({modkey}, 3, awful.mouse.client.resize)
)

-- Set keys
root.keys(globalkeys)
-- }}}
-- => Rules {{{
-- ====================================================================
-- Rules to apply to new clients (through the 'manage' signal).
awful.rules.rules = {
  -- All clients will match this rule.
  {rule = {},
   properties = {border_width = beautiful.border_width,
                 border_color = beautiful.border_normal,
                 focus = awful.client.focus.filter,
                 raise = true,
                 keys = clientkeys,
                 buttons = clientbuttons}},
  {rule = {class = 'MPlayer'},
   properties = {floating = true}},
  {rule = {class = 'pinentry' },
   properties = {floating = true}},
  {rule = {class = 'gimp'},
   properties = {floating = true}},
  -- Set Firefox to always map on tags number 2 of screen 1.
  -- {rule = {class = 'Firefox'},
  --  properties = {tag = tags[1][2]}},
}
-- }}}
-- => Signals {{{
-- ====================================================================
-- Signal function to execute when a new client appears.
client.connect_signal('manage', function (c, startup)
  -- Enable sloppy focus
  c:connect_signal('mouse::enter', function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
       and awful.client.focus.filter(c) then
      client.focus = c
    end
  end)

  if not startup then
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- awful.client.setslave(c)

    -- Put windows in a smart way, only if they does not set an initial position.
    if not c.size_hints.user_position and not c.size_hints.program_position then
      awful.placement.no_overlap(c)
      awful.placement.no_offscreen(c)
    end
  end

  local titlebars_enabled = false
  if titlebars_enabled and (c.type == 'normal' or c.type == 'dialog') then
    -- buttons for the titlebar
    local buttons = awful.util.table.join(
                      awful.button({}, 1, function()
                        client.focus = c
                        c:raise()
                        awful.mouse.client.move(c)
                      end),
                      awful.button({}, 3, function()
                        client.focus = c
                        c:raise()
                        awful.mouse.client.resize(c)
                      end)
                    )

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(awful.titlebar.widget.iconwidget(c))
    left_layout:buttons(buttons)

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    right_layout:add(awful.titlebar.widget.floatingbutton(c))
    right_layout:add(awful.titlebar.widget.maximizedbutton(c))
    right_layout:add(awful.titlebar.widget.stickybutton(c))
    right_layout:add(awful.titlebar.widget.ontopbutton(c))
    right_layout:add(awful.titlebar.widget.closebutton(c))

    -- The title goes in the middle
    local middle_layout = wibox.layout.flex.horizontal()
    local title = awful.titlebar.widget.titlewidget(c)
    title:set_align('center')
    middle_layout:add(title)
    middle_layout:buttons(buttons)

    -- Now bring it all together
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_right(right_layout)
    layout:set_middle(middle_layout)

    awful.titlebar(c):set_widget(layout)
  end
end)

client.connect_signal('focus', function(c) c.border_color = beautiful.border_focus end)
client.connect_signal('unfocus', function(c) c.border_color = beautiful.border_normal end)
-- }}}
