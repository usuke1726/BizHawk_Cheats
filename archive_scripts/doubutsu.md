
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
-- w8(0x0236D840, 0x22) -- 無人運転
-- w8(0x02370F6F, 0x01) -- 通知みたいのが鳴る
-- motion idx: 0x022A483D
-- x座標: 0x022A4708 (0xd000 -- 0x13100)
-- z座標: 0x022A4710 (0x13300 -- 0x1C000)
-- 回転: 0x022A4739
-- y回転: 0x022A4741

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

- `0x23564D0`: 自分キャラのポリゴン頂点リスト?

```lua
-- ピーナッツマリオぽくなる?
local begin = 0x02346000
local inclusiveEnd = 0x02347fFF
function loop()
    local i = begin
    while i <= inclusiveEnd do
        local v = r32(i)
        i = i + 4
        local _v = v & 0xffff
        if _v == 0x3b38 or _v == 0x03a38 then
            w32(i - 8, 0)
            i = i + 12
        end
    end
end
```

```lua
-- ポリゴン頂点をいじる
local function found(v)
    local vs = {
        0x2621,
        0x2122,
        0x2223,
        0x2321,
        0x2821,
        0x2226,
    }
    local function ok(_v)
        for _, v in pairs(vs) do
            if v == _v then return true end
        end
        return false
    end
    local v1 = v & 0xffff
    local v2 = (v >> 16) & 0xffff
    return ok(v1) and ok(v2)
end

local begin = 0x02356600
local inclusiveEnd = 0x02357fFF
function loop()
    local i = begin
    while i <= inclusiveEnd do
        local v = r32(i)
        i = i + 4
        if found(v) then
            for j = 0, 3 do
                add32(i, rand(-0x400, 0x400))
                i = i + 4
            end
        end
    end
end
```

## 運転手

```
22a483c アニメーション

2351E88, 胴の長さ
2351E8c, 90, 胴のx, z

2351e98, 左腕 y
2351e9c, a0, 左腕x, z
ac, b0, b4: 左手

2351ecc, 右腕 y
2351ed0, d4, 右腕x, z
e0, e4, e8: 右手

f00: 顔y
f04, f08: 顔x, z

=== POLYGON ===
local begin = 0x02352000
local inclusiveEnd = 0x02354fff

local function found(v)
    local vs = {0x21, 0x22, 0x23, 0x24, 0x25, 0x40}
    local function ok2(_v)
        for _, v in pairs(vs) do
            if _v == v then return true end
        end
        return false
    end
    local function ok(_v)
        return ok2(_v & 0xff) and ok2((_v >> 8) & 0xff)
    end
    return ok(v & 0xffff) and ok((v >> 16) & 0xffff)
end
```

波形?: 0213F820 -- 0214081f (bound: 0x1000)

## video14 ドレミ音 & 回転 & 首すっ飛び

```lua
local cursor_y = ValueUpdater(60, -0x30, 0xd, "lerp")
:x_reverseParabola()
:w32(0x02370F84)

local mus_r = CntOnce(240)
local update_mus = function()
if mus_r() then
lib.irume.start(function()
    local head = 0x03ec8640
    local time = 0x2c
    local p1 = 0x12
    local p2 = 0x13
    local vib_speed = 0x25
    local vib_depth = 0x27
    local ps = {
        0x26, 0x2c, 0x30, 0x33,
        0x39, 0x3e, 0x44, 0x47,
    }
    local c = Cnt(5, #ps)
    return function()
        w8(head + p1, 0x30)
        w8(head + p2, ps[c:next() + 1])
        w16(head + time, 0x100)
    end
end)
end
end

local rot_ready = RL(300)
local rot_speed_c = Cnt(60)
local rot_speed = 1

local rot = ValueUpdater(1)
:calc(function(obj)
    if not rot_ready then return end
    if rot_speed_c() then
        rot_speed = rot_speed + 2
    end
    return obj.v + rot_speed
end)
:init(8)
:w8(0x022A4741)

local facey_ready = RL(900)
local facey_d = 0x20
local facey_c = Cnt(2)

local facey = ValueUpdater(1, 0, 0x1f7c)
:calc(function(obj)
    if not facey_ready() then return end
    if facey_c() then facey_d = math.min(facey_d * 2, 0x1000) end
    return obj.v + facey_d
end)
:init(0x066c)
:w32(0x02351f00)

local setup_kappa = function()
    w32(0x22A4708, 0x011000)
    w32(0x22A4710, 0x1000)
    w32(0x22A4ee4, 0x24EC)
    if not rot_ready.fired then
        w8(0x022A4741, 0x08)
    end
    w8(0x025c209f, 0x01)
    -- w8(0x02370F80, 0x30) -- カーソルを画面外にやる
    if r32(0x06000230) == 0xeeeee1ee then
    -- 吹き出しを消す
    lib.fill_in(0x06000000, 0x06002fff)
    end
end

function loop()
    rot_ready()
    update_mus()
    facey()
    cursor_y()
    rot()
    setup_kappa()
end
```

## video14 辻先生ボイス混入 & 運転手荒ぶり

```lua
local update_voice = (function()
    -- どう森 音楽をバグらせる(辻先生まみれにする)
    -- ryori.luaを読み込むこと！！！
    local ready = RL(220)

    local r = RC(60)
    local r2 = RC(45)
    local c = Cnt(90)
    local active = false
    local i = 0

    local data = {
        DATA_Piman_hi,
        DATA_Piman_norm,
        DATA_Piman_fast,
        DATA_Piman_low_slow,
        -- DATA_AAAAAAAA,
        -- DATA_kujikesou,
        -- DATA_last,
    }
    local data_n = #data
    local cdata

    local head = 0x0213F820
    local width = 0x1000

    return function()
        if not ready() then return end
        if (not active) or r() or c() then
            cdata = data[rand(1, data_n)]
            n = #cdata
            c.i = 0
            active = true
            i = 0
        end
        if active then
            i = i + 1
            if i <= n then
                lib.fill_in_arr(head, head + width - 1, cdata[i])
            else active = false
            end
            -- active = not r2()
        end
    end
end)()

local setup_kappa = function()
    w32(0x22A4708, 0x011000)
    w32(0x22A4710, 0x1000)
    w32(0x22A4ee4, 0x24EC)
    w8(0x022A4741, 0x08)
    w8(0x025c209f, 0x01)
    w8(0x02370F80, 0x30) -- カーソルを画面外にやる
    if r32(0x06000230) == 0xeeeee1ee then
    -- 吹き出しを消す
    lib.fill_in(0x06000000, 0x06002fff)
    end
end

local update_move = (function()
    local time = 0x22a483c
    local time_d = 0x1000
    local times_i = 1
    local times = {
        Cnt(120),
        Cnt(60),
        Cnt(90),
        function() return false end,
    }
    return function()
        if times[times_i]() then
            times_i = times_i + 1
            print("update times_i:" .. tostring(times_i))
            time_d = math.min(time_d*2, 0x6000)
        end
        w32(time, (r32(time) + time_d) % 0x28000)
    end
end)()




local update_bodies = (function()
---@type table<string, bool>
local actives = {
    dou_x = true,
    dou_z = true,
}

---@type table<string, [int, int, ValueUpdaterObj]>
local bodies = {
    -- dou_y = {
    --     RL(60), ValueUpdater()
    -- }
    dou_x = {
        0x02351E8C, 0, ValueUpdater(40, -0x2000, 0x2000, "icos")
    },
    dou_xz = {
        0x02351E90, 0, ValueUpdater(40, -0xf000, 0x1000, "isin")
    },
    face_y = {
        0x02351F00, 0x066C, ValueUpdater(1, -0x400, 0x1600)
        :overflow_behavior("loop")
        :calc(function(obj)
            return obj.v + rand(-5, 5) * 0x40
        end)
    },
}

-- default: 1e14
local camera_y_r = RL(500)
local camera_y = ValueUpdater(25, 0x1814, 0x1e14, "lerp")
:x_reverseParabola()
:w32(0x022a4ee0)

local body_ready = RL(640)

local r = RC(30)

local addrs = {
{0x02351e98, 0x0333},
{0x02351e9c, -0x400},
{0x02351ea0, 0},
{0x02351eac, 0x0332},
{0x02351eb0, 0},
{0x02351eb4, 0},
{0x02351ecc, 0x0333},
{0x02351ed0, 0x0400},
{0x02351ed4, 0},
{0x02351ee0, 0x0336},
{0x02351ee4, 0},
{0x02351ee8, 0},
}
local reset_r = RC(60)
return function()
    if not body_ready() then return end
    if camera_y_r() then camera_y() end
    for _, v in pairs(addrs) do
        add32(v[1], rand(-8, 8) * 0x40)
        if reset_r() then
            w32(v[1], v[2])
        end
    end
    for k, v in pairs(bodies) do
        if actives[k] == nil then
            actives[k] = false
        end
        if actives[k] then
            w32(v[1], v[3]:next())
        else
            v[3].i = 0
            w32(v[1], v[2])
        end
        if r() then
            actives[k] = not actives[k]
        end
    end
end
end)()

function loop()
    setup_kappa()
    update_move()
    update_voice()
    update_bodies()
end
```

## video14 首だけ & 口を変える

```lua
-- animation: 22a483c
-- camera y: 22a4ee0  z: 4ee4 x 4edc

-- 22a4F4C -> 一瞬カメラが回転?
-- 22a4f88: worldの太さ
-- 22a4f8c: near clip?

-- lib.fill_in(0x2333600, 0x233363f, 0x44)

SET_LOOP("setup_kappa", function()
    w32(0x22A4708, 0x011000)
    w32(0x22A4710, 0x1000)
    w32(0x22A4ee4, 0x24EC)
    w8(0x022A4741, 0x08)
    w8(0x025c209f, 0x01)
    w8(0x02370F80, 0x30) -- カーソルを画面外にやる
    -- if r32(0x06000230) == 0xeeeee1ee then
    -- 吹き出しを消す
    lib.fill_in(0x06000000, 0x06002fff)
    -- end
end)

function loop()
    w32(0x022a4ee0, 0x1414)
    w32(0x02351f00, 0xfffff700)
end

-- ↓適当なタイミングで実行
w8(0x23522AA, 0x02) -- 口が上に移動
w32(0x023522A8, 0x0d60040c)
```
