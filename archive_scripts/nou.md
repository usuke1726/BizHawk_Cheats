
# 脳トレ

video6 あらぶり&イルーム

```lua
-- 背景を真っ白に
-- lib.fill_in(0x06000000, 0x0600ffff)
-- lib.fill_in(0x06200000, 0x062fffff)
-- lib.fill_in(0x06600000, 0x066fffff)
-- or
-- lib.fill_in(0x04000300, 0x0400ffff, 0xff)

local bug_bottom = (function()
    local button_c = Cnt(30, 2)
    local button = lib.at(0x04001000)
    return function()
        w32(0x04000350, 0xffffffff) -- 上画面の背景を消す
        w16(0x04001008, r16(0x04001008) + rand(0x80, 0x100))
        button:w32(0xc0011100 | (button_c:next() * 0x11))
    end
end)()

-- 211a740

-- 211A74F 20 -> てかる
-- 211A740 204354A0
-- 211A77C 肌色変更

local update_color = (function()
    local m = lib.at(0x0211A77C)
    local r = RC(40)
    local colors = {
        0x000000ff, -- red
        0x0000320f, -- kogetya
        0x00000f32, -- yellow?
        0x00000011, -- dark red
        0x0000ff00, -- blue
        0x00001f00, -- green
        0x00000000, -- black
        0x00444444, -- dark blue
        0xffffffff, -- normal
    }
    return function()
        if r() then
            m:w32(colors[rand(1, #colors)])
        end
    end
end)()

local kgb_change_speed_r = RL(360)

local kgb = (function()
    local m = lib.at(0x02129074)
    local v = 0
    local min = -0x2700
    local max = 0x2660
    local speed = 0x100
    local speed_r = RC(60)
    -- min -0x2700 -- 0x2660
    return function()
        if kgb_change_speed_r() and speed_r() then speed = rand(0, 8) * 0x100 end
        v = v + speed
        m:w32(stou32(v % (max - min) + min))
    end
end)()

local kgb_vert_change_speed_r = RL(260)
local kgb_vert = (function()
    local m = lib.at(0x02129078)
    local v = 0
    local min = -0x4500
    local max = 0x2380
    local speed = 0x100
    local speed_r = RC(60)
    return function()
        if kgb_vert_change_speed_r() and speed_r() then speed = rand(0, 8) * 0x100 end
        v = v + speed
        m:w32(stou32(v % (max - min) + min))
    end
end)()

local lerp = function(v, t, sc)
    if v == t then return v end
    if v < t then
        return v + math.ceil((t-v) * sc)
    else
        return v - math.ceil((v-t) * sc)
    end
end

local kgb_z = (function()
    local m = lib.at(0x02129080)
    local v = 0
    local min = 0x0100
    local max = 0x3000
    local target = 0x0640
    local r = RC(60)
    local cnt = -1
    return function()
        if cnt > 0 then cnt = cnt - 1 end
        if r() or cnt == 0 then
            cnt = 90
            local x = rand(0, 1000) / 1000
            target = math.floor(x * x * x * (max - min)) + min
        end
        v = lerp(m:r32(), target, 0.1)
        m:w32(stou32(v))
    end
end)()

local update_tekari = (function()
    local m = lib.at(0x0211A74F)
    local r = RC(60)
    local vs = {
        0x20, 0x10, 40
    }
    return function()
        if r() then
            m:w8(vs[rand(1, #vs)])
        end
    end
end)()

local mode_1 = RL(680)
local mode_2 = RL(980)
local mode_3 = RL(1280)

function loop()
    bug_bottom()
    kgb()
    if mode_1() then
        update_color()
        update_tekari()
    end
    if mode_2() then
        kgb_vert()
    end
    if mode_3() then
        kgb_z()
    end
end

lib.irume.start(function()
    local head = 0x03EC8A00
    local as = {}
    for i = 0, 16 do as[i] = head + 0x40 * i end
    local p = 0x18
    local t = 0x2c
    local r = RC(40)
    local rt = RC(20)
    return function()
        for _, a in pairs(as) do
            if r() then
                w16(a + p, stou16(rand(-10, 10) * 0x80))
            end
            if rt() then
                local v = r8(a + t)
                v = math.max(v + rand(-2, 2), 1)
                w8(a + t, v)
            end
        end
    end
end)
```

## ポリゴンをいじる

だいたい `0x0296C8B8` あたり！！

- テキトーにいじる

```lua
local st = 0x0296C8B8
local ed = 0x0296CFFF
-- local ed = 0x02975FFF
-- local ed = 0x029750FF

local r = RC(30)

for i = st, ed, 4 do
    if r() then
        w32(i, rand(0, 0xffffffff))
    end
end
```

