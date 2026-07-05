
# どうぶつの森

名前案:
ちーたら(女)
ゴそほネぬ村


video6 タイトル画面

```lua
local function set_utsu()
    lib.fill_in(0x06200400, 0x06200bff)
    lib.fill_in(0x06202000, 0x062035ff)
    for i = 0x06203500, 0x06205fff, 4 do
        if within(i, 0x06204a00, 0x06205fff) then w32(i, 0) end
        if within(i & 0xff, 0x80, 0xff) then w32(i, 0)
        else
            local _i = (i >> 8) & 0x3
            if _i == 0 or _i == 3 then w32(i, 0) end
        end
    end
end

local update_move_r = RL(600)
local function update_move()
    if not update_move_r() then return end
    w16(0x023847AC, rand(0, 0xffff))
    -- for i = 0x02384000, 0x0238438f, 4 do
    for i = 0x02384000, 0x023846ff, 4 do
        w32(i, stou32(r32(i) + rand(-0x1000, 0x1000)))
    end
end
local function update_gra()
    local vs1 = {0x8b, 0x80, 0x9b}
    w8(0x04000240, vs1[rand(1, #vs1)])
    local vs = {0x83, 0x80, 0x11}
    w8(0x04000241, vs[rand(1, #vs)])
end

local music_mode = RL(360)
local head = 0x0213F820
local head2 = 0x0214C800
local width = 0x1000
local scale = 1.1
local scale_r = RC(60)
local step = 14
local step_r = RC(30)
local function round(x) return math.floor(x + 0.5) end
local _i = 0
local function update_music()
    _i = _i + 1
    if step_r() then step = rand(8, 30) end
    if music_mode() then
        scale = round(math.sin(_i * 2 * math.pi / 30) * 2 + 103) / 100
    else
        scale = round(math.sin(_i * 2 * math.pi / 30) * 50 + 153) / 100
    end
    for i = 0, width-1, 4 do
        local _i = (round(i * scale) & 0xfffffffc) % width
        w32(head + i, r32(head + _i))
        w32(head2 + i, r32(head2 + _i))
    end
end

local meses = {
    "82a882cd82e682a482b282b482a282dc82b782b582cb",
    "975682d182c98140978882bd82f182c582b782b582cb",
    "975682d182b582cb814082a882cd82b582cb814082b582cb8140814082b582cb"
}
local mes = table.concat(meses, "")
local function update_text()
    local mes = lib.htob(mes)
    lib.warr(0x0238C0E4, mes)
end

local touch_colors = {
    {0, 0, 0, 0},
    {0, 0, 0x00ff0000, 0},
    {0x00ff0000, 0x00ff0000, 0x00ff0000, 0x00ff0000},
    {0, 0, 0xffffffff, 0},
}
local touch_color_r = RC(5)
local touch_color = touch_colors[1]
local function update_touch_icon()
    if touch_color_r() then
        touch_color = touch_colors[rand(1, #touch_colors)]
    end
    for i = 1, 4 do
        w32(0x05000020 + 4 * (i-1), touch_color[i])
    end
end

function loop()
    set_utsu()
    update_move()
    update_gra()
    update_music()
    update_text()
    update_touch_icon()
end
```

video6 運転手との会話パート

```lua
-- motion idx: 0x022A483D
-- x座標: 0x022A4708 (0xd000 -- 0x13100)
-- z座標: 0x022A4710 (0x13300 -- 0x1C000)
-- 回転: 0x022A4739

local update_move = (function()
    local r = RC(60)
    local rot_y_speed = 16
    local rot_y_speed_r = RC(30)
    local ready = RL(240)
    local rot_y = lib.at(0x022A4741)
    local rot_x = lib.at(0x022A4739)
    local rot_x_active = false
    local rot_x_active_r = RC(60)
    local rot_x_speed = 2
    local rot_x_speed_r = RC(90)
    local pos_x = lib.at(0x022A4708)
    local pos_z = lib.at(0x022A4710)
    local pos_x_r = RC(40)
    local pos_z_r = RC(40)
    return function()
        rot_y:add8(rot_y_speed)
        if not ready() then return end
        if rot_y_speed_r() then rot_y_speed = rand(0, 32) end
        if rot_x_speed_r() then rot_x_speed = rand(0, 4) end
        if rot_x_active_r() then rot_x_active = not rot_x_active end
        if rot_x_active then rot_x:add8(rot_x_speed)
        else rot_x:w8(0)
        end
        if pos_x_r() then
            pos_x:w32(rand(0xd000, 0x13100))
        end
        if pos_z_r() then
            pos_z:w32(rand(0x13300, 0x1c000))
        end
    end
end)()

local update_move2 = (function()
    local ready = RL(1000)
    local m = lib.at(0x022A4268)
    local v = 0
    -- min: -0x2000 -- 0x2a00
    return function()
        if not ready() then return end
        v = math.max(math.min(v + rand(-0x200, 0x200), 0x2a00), -0x2000)
        if within(v, -0x2000, -0x1d00) and rand(1, 30) == 1 then
            v = 0x1000
        elseif within(v, 0x2800, 0x2a00) and rand(1, 30) == 1 then
            v = -0x1000
        end
        m:w32(stou32(v))
    end
end)()


local update_cursor = (function()
    local m_x = lib.at(0x02370F80)
    local m_y = lib.at(0x02370F84)
    local _i = 0
    local span = 30
    local spanx = 100
    local spanx_r = RC(60)
    local spany_r = RC(60)
    local x_min = -0xd0
    local x_max = 0x20
    return function()
        if spanx_r() then spanx = rand(10, 90) end
        if spany_r() then span = rand(10, 90) end
        _i = _i + 1
        local v
        v = math.floor(math.sin((_i % span) * math.pi / span) * 0xb0) - 0xa0
        m_y:w32(stou32(v))
        v = math.abs((_i % spanx) / spanx - 0.5) * 2 * (x_max - x_min) + x_min
        m_x:w32(stou32(v))
    end
end)()

local update_music = (function()
    local m = lib.at(0x03EC8652)
    local r = RC(40)
    local c = 120
    return function()
        if c > 0 then c = c - 1 end
        if r() or c == 0 then
            c = 120
            local v1 = rand(0x10, 0x7F)
            local v2 = rand(0x10, 0x7F)
            m:w16((v1 << 8) | v2)
        end
    end
end)()

local update_zoom = (function()
    local ready = RL(2800)
    local lerp = function(v, t, sc)
        if v == t then return v end
        if v < t then
            return v + math.ceil((t-v) * sc)
        else
            return v - math.ceil((v-t) * sc)
        end
    end
    local m = lib.at(0x022A4FA0)
    local r = RC(40)
    local cnt = -1
    local v = 0
    local target = 0
    -- min: 0x0300 -- 0x6000
    return function()
        if not ready() then return end
        if cnt > 0 then cnt = cnt - 1 end
        if r() or cnt == 0 then
            cnt = 60
            target = rand(0x0300, 0x6000)
        end
        if target ~= v then
            v = lerp(v, target, 0.1)
            m:w16(v)
        end
    end
end)()

local update_width = (function()
    local ready = RL(3600)
    local m = lib.at(0x022A4F89)
    local r = Cnt(15)
    return function()
        if not ready() then return end
        if r() then
            local x = rand(0, 1000) / 1000
            local v = math.floor(x * x * 0xf0) + 0x05
            m:w8(v)
        end
    end
end)()

function loop()
    update_cursor()
    update_move()
    update_music()
    update_move2()
    update_zoom()
    update_width()
end
```

