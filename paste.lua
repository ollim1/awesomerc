
    -- cpugraph_all = awful.widget.graph({max_value = 100, width = 16})
    cpugraph_all = awful.widget.graph({max_value = 100, width = 16, step_width = 1, step_spacing = 0})
    watch([[bash -c "mpstat 1 1 | awk '{if(NR==4) printf "%3.0f", (100 - $NF) }'"]], 2,
    function(widget, s)
        widget:add_value(tonumber(s))
    end,
    cpugraph_all)
--     cpugraph_cpu1 = awful.widget.graph({max_value = 100, width = 8})
--     vicious.register(cpugraph_cpu1, vicious.widgets.cpu, "$2")
--     cpugraph_cpu2 = awful.widget.graph({max_value = 100, width = 8})
--     vicious.register(cpugraph_cpu2, vicious.widgets.cpu, "$3")
--     cpugraph_cpu3 = awful.widget.graph({max_value = 100, width = 8})
--     vicious.register(cpugraph_cpu3, vicious.widgets.cpu, "$4")
--     cpugraph_cpu4 = awful.widget.graph({max_value = 100, width = 8})
--     vicious.register(cpugraph_cpu4, vicious.widgets.cpu, "$5")
--     cpugraph_cpu5 = awful.widget.graph({max_value = 100, width = 8})
--     vicious.register(cpugraph_cpu5, vicious.widgets.cpu, "$6")
--     cpugraph_cpu6 = awful.widget.graph({max_value = 100, width = 8})
--     vicious.register(cpugraph_cpu6, vicious.widgets.cpu, "$7")
--     cpugraph_cpu7 = awful.widget.graph({max_value = 100, width = 8})
--     vicious.register(cpugraph_cpu7, vicious.widgets.cpu, "$8")
--     cpugraph_cpu8 = awful.widget.graph({max_value = 100, width = 8})
--     vicious.register(cpugraph_cpu8, vicious.widgets.cpu, "$9")
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
