


---@param silent bool?
local function setup_touching(silent)
    local frames = 10
    local width = 110
    local height = 60
    local cx = 125
    local cy = 84

    local function round(x) return math.floor(x + 0.5) end

    local function do_touch(i)
        return cx, cy
    end
    local __use_half = false
    local function do_right(i)
        if __use_half then
            return cx + round((i / frames) * width)
        else
            return cx + round((i / frames - 0.5) * 2 * width)
        end
    end
    local function do_left(i)
        if __use_half then
            return cx - round((i / frames) * width)
        else
            return cx - round((i / frames - 0.5) * 2 * width)
        end
    end
    local function do_up(i)
        if __use_half then
            return cy - round((i / frames) * height)
        else
            return cy - round((i / frames - 0.5) * 2 * height)
        end
    end
    local function do_down(i)
        if __use_half then
            return cy + round((i / frames) * height)
        else
            return cy + round((i / frames - 0.5) * 2 * height)
        end
    end

    local _i = 0
    local touching = false

    local b_hor = 0
    local b_ver = 0
    local pp = function(s)
        if not silent then print(s) end
    end
    SET_LOOP("___nodame_touching", function()
        if not silent then CLS() end
        local mouse = input.get()["WMouse L"]
        if mouse then
            local mouse_pos = input.getmouse()
            local _x = math.min(math.max(mouse_pos["X"], 0), 255)
            local _y = math.min(math.max(mouse_pos["Y"], 0) // 2, 191)
            pp(string.format("MOUSE OVERRIDE (%d, %d)", _x, _y))
            joypad.set({
                ["Touch"] = true,
            })
            joypad.setanalog({
                ["Touch X"] = _x,
                ["Touch Y"] = _y,
            })
            return
        end

        local keys = joypad.get()
        local left = keys[DS_KEYS.Left]
        local right = keys[DS_KEYS.Right]
        local up = keys[DS_KEYS.Up]
        local down = keys[DS_KEYS.Down]
        local a = keys[DS_KEYS.A]
        local L = keys[DS_KEYS.L]
        if not (left or right or up or down or a or L) then
            if ((not touching) or _i >= frames) or (b_hor == 0 and b_ver == 0) then
                _i = 0
                touching = false
                b_hor = 0
                b_ver = 0
                joypad.set({
                    ["Touch"] = false,
                })
                return
            end
        end
        touching = true
        _i = _i + 1
        local i = _i % frames
        if a or L then
            pp("A")
            local _x, _y = do_touch(i)
            joypad.set({
                ["Touch"] = true,
            })
            joypad.setanalog({
                ["Touch X"] = _x,
                ["Touch Y"] = _y,
            })
            return
        end
        if up then b_ver = 1
        elseif down then b_ver = -1
        end
        if left then b_hor = -1
        elseif right then b_hor = 1
        end
        local _x, _y = cx, cy
        if b_ver == 1 then pp("UP") _y = do_up(i) _x = cx + rand(-3, 3)
        elseif b_ver == -1 then pp("DOWN") _y = do_down(i) _x = cx + rand(-3, 3)
        end
        if b_hor == -1 then pp("LEFT") _x = do_left(i)
        elseif b_hor == 1 then pp("RIGHT") _x = do_right(i)
        end
        pp(string.format("(x, y) = (%d, %d)", _x, _y))
        joypad.set({
            ["Touch"] = true,
        })
        joypad.setanalog({
            ["Touch X"] = _x,
            ["Touch Y"] = _y,
        })
    end)
end

return {
    setup_touching = setup_touching,
}
