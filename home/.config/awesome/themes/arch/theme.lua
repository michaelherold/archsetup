-- => Initialization and Modules {{{
-- ====================================================================
local awful = require('awful')
awful.util = require('awful.util')

theme = {}

home          = os.getenv('HOME')
config        = awful.util.getdir('config')
shared        = '/usr/share/awesome'
if not awful.util.file_readable(shared .. '/icons/awesome16.png') then
  shared    = '/usr/share/local/awesome'
end
sharedicons   = shared .. '/icons'
sharedthemes  = shared .. '/themes'
themes        = config .. '/themes'
themename     = '/arch'
if not awful.util.file_readable(themes .. themename .. '/theme.lua') then
  themes = sharedthemes
end
themedir      = themes .. themename

wallpaper_jpg     = themedir .. '/background.jpg'
wallpaper_png     = themedir .. '/background.png'
wpscript          = home .. '/.wallpaper'
wallpaper_default = sharedthemes .. '/default/background.jpg'

if awful.util.file_readable(wallpaper_jpg) then
  theme.wallpaper = wallpaper_jpg
elseif awful.util.file_readable(wallpaper_png) then
  theme.wallpaper = wallpaper_png
elseif awful.util.file_readable(wpscript) then
  theme.wallpaper_cmd = {'sh' .. wpscript}
else
  theme.wallpaper = wallpaper_default
end
-- }}}
-- => Fonts and Colors {{{
-- ====================================================================
theme.font          = 'Droid Sans 8'

theme.bg_normal     = '#000000'
theme.bg_focus      = '#1793d1'
theme.bg_urgent     = '#ff0000'
theme.bg_minimize   = '#000000'
theme.bg_tooltip    = theme.bg_urgent

theme.fg_normal     = '#1793d1'
theme.fg_focus      = '#000000'
theme.fg_urgent     = '#ffffff'
theme.fg_minimize   = '#1793d1'
theme.fg_tooltip    = theme.fg_urgent

theme.border_width  = '1'
theme.border_normal = '#000000'
theme.border_focus  = '#1793d1'
theme.border_marked = '#91231c'
theme.border_tooltip = theme.border_focus

-- }}}
-- => Tag- and Tasklist Icons {{{
-- ====================================================================

theme.taglist_squares_sel   = sharedthemes .. '/default/taglist/squarefw.png'
theme.taglist_squares_unsel = sharedthemes .. '/default/taglist/squarew.png'

theme.tasklist_floating_icon = sharedthemes .. '/default/tasklist/floatingw.png'

-- }}}
-- => Menu Configuration {{{
-- ====================================================================

theme.menu_submenu_icon = sharedthemes .. '/default/submenu.png'
theme.menu_height = '15'
theme.menu_width  = '100'

-- }}}
-- => Titlebar Icons {{{
-- ====================================================================

theme.titlebar_close_button_normal = sharedthemes .. '/default/titlebar/close_normal.png'
theme.titlebar_close_button_focus  = sharedthemes .. '/default/titlebar/close_focus.png'

theme.titlebar_ontop_button_normal_inactive = sharedthemes .. '/default/titlebar/ontop_normal_inactive.png'
theme.titlebar_ontop_button_focus_inactive  = sharedthemes .. '/default/titlebar/ontop_focus_inactive.png'
theme.titlebar_ontop_button_normal_active = sharedthemes .. '/default/titlebar/ontop_normal_active.png'
theme.titlebar_ontop_button_focus_active  = sharedthemes .. '/default/titlebar/ontop_focus_active.png'

theme.titlebar_sticky_button_normal_inactive = sharedthemes .. '/default/titlebar/sticky_normal_inactive.png'
theme.titlebar_sticky_button_focus_inactive  = sharedthemes .. '/default/titlebar/sticky_focus_inactive.png'
theme.titlebar_sticky_button_normal_active = sharedthemes .. '/default/titlebar/sticky_normal_active.png'
theme.titlebar_sticky_button_focus_active  = sharedthemes .. '/default/titlebar/sticky_focus_active.png'

theme.titlebar_floating_button_normal_inactive = sharedthemes .. '/default/titlebar/floating_normal_inactive.png'
theme.titlebar_floating_button_focus_inactive  = sharedthemes .. '/default/titlebar/floating_focus_inactive.png'
theme.titlebar_floating_button_normal_active = sharedthemes .. '/default/titlebar/floating_normal_active.png'
theme.titlebar_floating_button_focus_active  = sharedthemes .. '/default/titlebar/floating_focus_active.png'

theme.titlebar_maximized_button_normal_inactive = sharedthemes .. '/default/titlebar/maximized_normal_inactive.png'
theme.titlebar_maximized_button_focus_inactive  = sharedthemes .. '/default/titlebar/maximized_focus_inactive.png'
theme.titlebar_maximized_button_normal_active = sharedthemes .. '/default/titlebar/maximized_normal_active.png'
theme.titlebar_maximized_button_focus_active  = sharedthemes .. '/default/titlebar/maximized_focus_active.png'

-- }}}
-- => Layout Icons {{{
-- ====================================================================

theme.layout_fairh = sharedthemes .. '/default/layouts/fairhw.png'
theme.layout_fairv = sharedthemes .. '/default/layouts/fairvw.png'
theme.layout_floating  = sharedthemes .. '/default/layouts/floatingw.png'
theme.layout_magnifier = sharedthemes .. '/default/layouts/magnifierw.png'
theme.layout_max = sharedthemes .. '/default/layouts/maxw.png'
theme.layout_fullscreen = sharedthemes .. '/default/layouts/fullscreenw.png'
theme.layout_tilebottom = sharedthemes .. '/default/layouts/tilebottomw.png'
theme.layout_tileleft   = sharedthemes .. '/default/layouts/tileleftw.png'
theme.layout_tile = sharedthemes .. '/default/layouts/tilew.png'
theme.layout_tiletop = sharedthemes .. '/default/layouts/tiletopw.png'
theme.layout_spiral  = sharedthemes .. '/default/layouts/spiralw.png'
theme.layout_dwindle = sharedthemes .. '/default/layouts/dwindlew.png'

-- }}}
-- => Widget Icons {{{

theme.widget_cpu            = themedir .. '/widgets/cpu.png'
theme.widget_pacman_new     = themedir .. '/widgets/pacman_new.png'
theme.widget_pacman_default = themedir .. '/widgets/pacman_default.png'
theme.widget_volume         = themedir .. '/widgets/volume.png'

-- }}}
-- => Finalization {{{
-- ====================================================================

theme.awesome_icon = themedir .. '/awesome16.png'

return theme
-- }}}
-- vim: filetype=lua:expandtab:shiftwidth=2:tabstop=2:softtabstop=2:encoding=utf-8:textwidth=80
