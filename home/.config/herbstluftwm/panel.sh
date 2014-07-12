#!/bin/bash
# vim: set fileencodig=utf-8 ts=2 sts=2 sw=2 tw=80 expandtab :

# => Configuration {{{
# ====================================================================

CONFIG_PATH=${XDG_CONFIG_HOME:-~/.config}/herbstluftwm
ICON_PATH=${CONFIG_PATH}/dzen/icons

hc() { herbstclient "$@"; }

# }}}
# => Commands {{{
# ====================================================================

# Find the installed version of textwidth
textwidth="textwidth";

uniq_linebuffered() {
  awk '$0 != l { print ; l=$0 ; fflush(); }' "$@"
}

# }}}
# => Geometry {{{
# ====================================================================

monitor=${1:-0}
geometry=( $(hc monitor_rect "$monitor") )
if [ -z "$geometry" ] ;then
  echo "Invalid monitor $monitor"
  exit 1
fi
# geometry has the format W H X Y
x=${geometry[0]}
y=${geometry[1]}
panel_width=${geometry[2]}
panel_height=16

# }}}
# => Look and Feel {{{
# ====================================================================

# font="xft:Droid Sans Mono:pixelsize=12:antialias=true:hinting=true"
font="-*-fixed-medium-*-*-*-12-*-*-*-*-*-*-*"

# Colors

declare -A color

index=0
for name in black red green yellow blue magenta cyan white grey bright_red bright_green bright_yellow bright_blue bright_magenta bright_cyan bright_white; do
  color[${name}]=$(xrdb -query | grep -P "color${index}:" | cut -f 2-)
  ((index++))
done

fgcolor=${color["white"]}
bgcolor=${color["black"]}
separator_color=${color["grey"]}
hint_color_separator=${color["grey"]}

tag_default_color_fg=${color["white"]}
tag_default_color_fg=${color["black"]}
tag_default_color_separator=${color["grey"]}

tag_active_color_fg=${color["black"]}
tag_active_color_bg=${color["green"]}
tag_active_color_separator=${color["bright_green"]}

tag_notice_color_fg=${color["white"]}
tag_notice_color_bg=${color["red"]}
tag_notice_color_separator=${color["bright_red"]}

tag_populated_color_fg=${color["white"]}
tag_populated_color_bg=${color["black"]}
tag_populated_color_separator=${color["grey"]}

tag_unfocused_color_fg=${color["white"]}
tag_unfocused_color_bg=${color["blue"]}
tag_unfocused_color_separator=${color["bright_blue"]}

# }}}
# => Runtime {{{ 
# ====================================================================

hc pad $monitor $panel_height

{
  # => Event Generator {{{
  # ==================================================================

  #mpc idleloop player &

  while true ; do
    date +$'date\t%H:%M, %Y-%m-%d'
    sleep 1 || break
  done > >(uniq_linebuffered) &

  childpid=$!
  hc --idle
  kill $childpid

  # }}}
} 2> /dev/null | {
  # => Output Generator {{{

  IFS=$'\t' read -ra tags <<< "$(hc tag_status $monitor)"
  visible=true
  date=""
  windowtitle=""
  separator="^ro(1x$panel_height)^fg()"
  colored_separator="^fg($separator_color)$separator"

  while true ; do

    
    # => Draw Tags {{{
    # ================================================================
    
    # Legend:
    #   . Empty
    #   : Not Empty
    #   + Viewed on current monitor, not focused
    #   # Viewed on current monitor, focused
    #   - Viewed on different monitor, not focused
    #   % Viewed on different monitor, focused
    #   ! Has urgent window
    for i in "${tags[@]}" ; do
      case ${i:0:1} in
        '#')
          echo -n "^fg($tag_active_color_separator)"
          echo -n "$separator"
          echo -n "^bg($tag_active_color_bg)^fg($tag_active_color_fg)"
          ;;
        '!')
          echo -n "^fg($tag_notice_color_separator)"
          echo -n "$separator"
          echo -n "^bg($tag_notice_color_bg)^fg($tag_notice_color_fg)"
          ;;
        ':')
          echo -n "^fg($tag_populated_color_separator)"
          echo -n "$separator"
          echo -n "^bg($tag_populated_color_bg)^fg($tag_populated_color_fg)"
          ;;
        '+')
          echo -n "^fg()"
          echo -n "$separator"
          echo -n "^bg($tag_unfocused_color_bg)^fg($tag_unfocused_color_fg)"
          ;;
        *)
          echo -n "^fg($tag_default_color_fg)"
          echo -n "$separator"
          echo -n "^bg()^fg()"
          ;;
      esac
      echo -n "^ca(1,"
      echo -n "herbstclient focus_monitor $monitor && "
      echo -n "herbstclient use ${i:1})"
      echo -n " ${i:1} "
      echo -n "^ca()"
      echo -n "^fg($separator_color)$separator"
    done

    # }}}
    # => Draw Main Section {{{
    # ================================================================

    echo -n "^bg()^fg() ${windowtitle//^/^^}"

    # }}}
    # => Draw Right Section {{{
    # ================================================================
    
    right="$colored_separator^bg() $date"
    right_text_only=$(echo -n "$right" | sed 's.\^[^(]*([^)]*)..g')
    width=$($textwidth "$font" "$right_text_only ")
    echo -n "^pa($(($panel_width - $width)))$right"
    echo

    # }}}
    # => Data Handling {{{
    # ================================================================

    IFS=$'\t' read -ra cmd || break

    case "${cmd[0]}" in
      tag*)
        IFS=$'\t' read -ra tags <<< "$(hc tag_status $monitor)"
        ;;
      date)
        date="${cmd[@]:1}"
        ;;
      quit_panel)
        exit
        ;;
      togglehidepanel)
        currentmonidx=$(hc list_monitors | sed -n '/\[FOCUS\]$/s/:.*//p')

        if [ "${cmd[1]}" -ne "$monitor" ] ; then
          continue
        fi
        if [ "${cmd[1]}" = "current" ] && [ "$currentmonidx" -ne "$monitor" ] ; then
          continue
        fi

        echo "^togglehide()"

        if $visible ; then
          visible=false
          hc pad $monitor 0
        else
          visible=true
          hc pad $monitor $panel_height
        fi
        ;;
      reload)
        exit
        ;;
      focus_changed|window_title_changed)
        windowtitle="${cmd[@]:2}"
        ;;
      #player)
        #    ;;
    esac

    # }}}

  done

  # }}}
} 2> /dev/null | dzen2 -w $panel_width -x $x -y $y -fn "$font" -h $panel_height \
  -e 'button3=;button4=exec:herbstclient use_index -1;button5=exec:herbstclient use_index +1' \
  -ta l -bg "$bgcolor" -fg "$fgcolor"

# }}}
