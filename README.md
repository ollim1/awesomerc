# AwesomeWM rice
Required software: feh, amixer, i3lock

Uses the Papirus and Arc icon sets, install them to /usr/share/icons

xclip and mpv for media playback hotkeys

mpd and mpc for mpd widget

sysstat for cpu stats

Before using, create the files `host.lua`, `autorun.sh` `~/.fehbg`. `host.lua` should have the following contents:

```
local host = {}
host.is_laptop = false
host.gap = 0
return host
```

Set the `is_laptop` to enable battery widget and arandr launcher. Currently the script referenced in the battery widget can be found in the "stuff" repository, but it is specific to devices with two batteries. Set `batwidget = nil` to disable battery stats or point the widget at a script of your choosing. Some hotkeys are also device dependent in laptop mode.

A sample `autorun.sh`:

```
#!/usr/bin/env bash

function run {
    if ! pgrep -f $1 ;
    then
        $@&
    fi
}

run picom
run pasystray
run nm-applet
```

`.fehbg`:

```
feh --no-fehbg --bg-scale ~/Pictures/wallpapers/wallpaper.png
```

### other
Press mod4 + = to toggle the visibility of the system tray.
