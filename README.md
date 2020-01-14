# AwesomeWM rice
Before using, create the files `host.lua` and `autorun.sh`. `host.lua` should have the following contents:

```
module("host")
local host = { }
is_laptop = false
```

Set the `is_laptop` to enable battery widget and arandr launcher. Currently the script referenced in the battery widget can be found in the "stuff" repository, but it is specific to devices with two batteries. Set `batwidget = nil` to disable battery stats or point the widget at a script of your choosing.

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
run ~/.fehbg
```

