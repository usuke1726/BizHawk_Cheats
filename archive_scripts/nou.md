
# 脳トレ

## 雑多メモ

```plaintext

音消滅
0x02AF9C09 -- 0x02B1B29D (0xc2)

音がヘンに？
0x0231E31D -- 0x0236E38C (0x1e)


0x0248E384 -- 0x0248E747 (0x14)
0x0296C8B8 -- 0x0296CBF1 (0xe6)
0x0270A93D -- 0x0270AAC0 (0x30)
0x02A5A524 -- 0x02A5A890 (0x62)

```



## video6 あらぶり&イルーム

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


## タイトルの教授の動き制御

- 横方向: `0x02128768`
- 縦方向: `0x02129050`

0に固定すれば動かなくなるし、add16すれば速く移動するようになる

## video10 顔面崩壊 & イルーム

```lua
CLS()

local m = lib.at(0x02000000)

local scales = {
    0x20, 0x40, 0x100,
    0x10, 0x20, 0x200,
    0x40,
}
local i = 0
local r = RC(90)

local function found(v)
    return v & 0xffffff == 0x003B38
end

local backup = lib.range(0x0296E4B8, 0x0296F01F):save()
local prev_l = false
local prev_m = false

w32(0x04000350, 0x66666666) -- 上画面の背景を消す
local count = 0

function loop()
    local scale = scales[mode] or 0x20
    scale = 0x20
    local k = DS.key.get("L")
    if (not prev_l) and k then
        prev_l = true
        backup:rollback()
    elseif prev_l and (not k) then
        prev_l = false
    end
    k = DS.key.get("Left")
    if (not prev_m) and k then
        prev_m = true
        mode = math.min(mode + 1, 7)
        count = 0
        print("=== MODE " .. tostring(mode))
    elseif prev_m and (not k) then
        prev_m = false
    end
    i = (i + 1) % 60
    if i == 0 then
        count = count + 1
        if count % 10 == 0 then
            print("= count " .. tostring(count))
        end
    end
    local v = math.round(math.sin(i * 2 * math.pi / 60) * scale)
    local a = 0x0296E4B8
    while a <= 0x0296EFFF do
        if found(r32(a)) then
            for j = 1, 3 do
                a = a + 4
                m:with(a):add32(rand(-scale, scale))
            end
        end
        a = a + 4
    end
    local _v
    m:with(0x0296E4AC):w32(0xFFFFFD00)
    if mode == 5 then
        _v = math.round(math.sin(i * 2 * math.pi / 60) * 0x3000) + 0x500
    elseif mode == 7 then
        _v = math.round(math.sin(i * 4 * math.pi / 15) * 0x1000) + 0xf00
    else
        _v = 0x1400
    end
    m:with(0x0296E4B0):w32(_v)
    w16(0x02128768, 0)
    w16(0x02129050, 0)
end

-- ==============


mode = 1

local ranges = {
    {-0x10, 0x10, 0x20, 0x30}, -- 初期
    {0, 0x1, 0x20, 0x20}, -- 初期2
    {0x10, 0x20, 0x10, 0x14}, -- 高音
    {-0x30, -0x10, 0x10, 0x34}, -- 低音
    {0x20, 0x24, 0x30, 0x50}, -- 高音2
    {-0x1, 0x1, 0x20, 0x30}, -- 初期3
    {-0x30, 0x30, 0x1, 0x10}, -- finale
}

lib.irume.start(function()
    local head = 0x03EC8A00
    local as = {}
    local prevs = {}
    for i = 0, 16 do
        as[i] = head + 0x40 * i
        prevs[i] = 0
    end
    local p = 0x18
    local t = 0x2c
    local r = RC(20)
    local v = 0x16
    local vib = 0x22 -- -0x600 to 100
    local vib_r = RC(40)
    return function()
        local R = ranges[mode] or {-0x20, 0x20, 0x8, 0x30}
        for i, a in pairs(as) do
            if r() then
                w16(a + p, stou16(rand(R[1], R[2]) * 0x80))
            end
            local _t = r8(a + t)
            if prevs[i] < _t then
                _t = rand(R[3], R[4])
            end
            w8(a + t, _t)
            prevs[i] = _t
            if vib_r() then
                w16(a + vib, stou16(rand(-6, 1) * 0x100))
            end
        end
    end
end)
```

<details>
<summary>ボツコード(メモリ調査中に使用した旧バージョン)</summary>
<div>

```lua
local m = lib.at(0x02000000)

local scale = 0x2
local i = 0
local r = RC(90)

local function found(v)
    for i = 0, 3 do
        local z = (v >> (i*8)) & 0xff
        if not (
            z == 0x21 or
            z == 0x14 or
            z == 0x23 or
            z == 0x28
        ) then return false end
    end
    return true
end

local function found2(v)
    return v & 0xffffff == 0x003B38
end

function loop()
    i = (i + 1) % 60
    local v = math.round(math.sin(i * 2 * math.pi / 60) * scale)
    local a = 0x02969620
    while a <= 0x0296EFFF do
        if found(r32(a)) then
            for j = 1, 3 do
                a = a + 4
                m:with(a):add32(rand(-scale, scale))
            end
        end
        a = a + 4
    end
end
```

</div>
</details>

---


## video11 顔面崩壊 その1 & 微ピッチずれ

```lua

CLS()

local m = lib.at(0x02000000)

local scale = 0x20
local i = 0

w32(0x04000350, 0xdddddddd) -- 上画面の背景を消す

local function found(v)
    local _v = v & 0xffffff
    return _v == 0x003B38 or _v == 0x003A38
end
local backup = lib.range(0x0296E4B8, 0x0296F01F):save()

local first = true
local span = 51
function loop()
    i = (i + 1) % span
    local v = math.round(math.sin(i * 2 * math.pi / span) * scale)
    local a = 0x0296E4B8
    while a <= 0x0296EFFF do
        if found(r32(a)) then
            for j = 1, 3 do
                a = a + 4
                if first then
                    m:with(a):add32(-0x600)
                end
                if rand(1, 2) == 1 then
                m:with(a):add32(v * 0x4 + 2)
                end
            end
        end
        a = a + 4
    end
    first  = false
    m:with(0x0296E4AC):w32(0xFFFFFD00)
    w16(0x02128768, 0)
    w16(0x02129050, 0)
end

lib.irume.start(function()
    local head = 0x03EC8A00
    local as = {}
    for i = 0, 16 do
        as[i] = head + 0x40 * i
    end
    local p = 0x18
    local r = RC(10)
    return function()
        for i, a in pairs(as) do
            if r() then
                w16(a + p, stou16(rand(-0x10, 0x10) * 0x4))
            end
        end
    end
end)
```

## video11 ホッピング教授

```lua

local h = 0x0200
-- local H = ValueUpdater(90, -0x1000, 0x2000)
local H = ValueUpdater(60, -0x400, 0x2000)
:calc(function(obj)
    local min, max = obj:get_minmax()
    local x = obj:x() * 2 - 1
    return math.round((1 - x * x) * (max - min)) + min
    -- return obj:isin()
end)
:overflow_behavior("clamp")
:write(function(v) w32(0x0296E4BF, v) end)
local H2 = ValueUpdater(60, -0x1000, 0x400)
:calc(function(obj)
    local min, max = obj:get_minmax()
    local x = obj:x()
    local d = (max - min) // 2
    return math.isin(x, d) + min + d
end)
:overflow_behavior("clamp")
:write(function(v) w32(0x0296E600, v) end)
H2.i = H2.n * 1 // 4 + 10

w32(0x04000350, 0xdddddddd) -- 上画面の背景を消す

local uup = 0
local target = 0
function loop()
    w16(0x02128768, 0)
    w16(0x02129050, 0)
    -- w32(0x0296E600, 0xffffff00)

    H()
    H2()
    -- 教授をどアップに
    -- w32(0x0296E4BF, h)
    -- w32(0x0296E4C0, 0xFFFFE000)
    w32(0x0296E4C0, uup)
    if DS.key.get("Down") then
        target = ilerp(target, -0x2000, 0.05)
        -- uup = ilerp(uup, target, 0.05)
    elseif DS.key.get("Up") then
        -- target = ilerp(target, 0, 0.03)
        target = ilerp(target, 0x3e00, 0.05)
        -- uup = ilerp(uup, 0, 0.05)
    end
    uup = ilerp(uup, target, 0.1)
end


lib.irume.start(function()
    local head = 0x03EC8A00
    local as = {}
    for i = 0, 16 do
        as[i] = head + 0x40 * i
    end
    local p = 0x1f
    local r = RC(10)
    return function()
        if r() then
            local _p = stou8(rand(-2, 4)*2)
            for i, a in pairs(as) do
                w8(a + p, _p)
            end
        end
    end
end)
```

## video13

```lua
w32(0x04000350, 0x33333333) -- 上画面の背景を消す


local function s32(v)
    if v > 0x80000000 then
        return v - 0x100000000
    end
    return v
end

---@param obj ValueUpdaterObj
local function update(obj)
    return obj.v + rand(-0x20, 0x20) * 2
end

local left_eye = {
ValueUpdater(1, 0x06D0, 0x07E0, update):w32(0x0296E550),
ValueUpdater(1, 0x0190, 0x0330, update):w32(0x0296E558),
}
local right_eye = {
ValueUpdater(1, 0x06D0, 0x07E0, update):w32(0x0296E564),
ValueUpdater(1, 0xFFFFFCD0, 0xFFFFFEB0, update):w32(0x0296E56C),
}
local glasses = {
ValueUpdater()
:calc(function() return 0x0b68 end)
:w32(0x0296E5D8),
ValueUpdater()
:calc(function() return rand(0x2, 0x19) end)
:w8(0x0296E5E4),
}

local hoo = {
ValueUpdater(45, -0x100, 0x800, function(obj) return obj:isin() end):w32(0x0296E5F4),
ValueUpdater(45, -0x750, 0x100, function(obj)
    local min, max = obj:get_minmax()
    return math.ilerp(min, max, math.sin01(1.0 - obj:x()))
end):w32(0x0296E644),
}

local mouses = {
--  -0x1000  -- 0x10C6 shita (def 01c6)
--  -0x800 -- 0x10BA ue (def 02ba)
(function()
    local d = 0xf4
    local a_shita = 0x0296E600
    local a_ue = 0x0296E650
    local def_shita = 0x01c6
    local def_ue = 0x02ba
    local r = RC(60)
    return function()
        d = clamp(d + rand(-0x20, 0x20)*4, 0x10,0x1000)
        local v = s32(r32(a_shita))
        v = clamp(v + rand(-0x80, 0x80)*2, -0x1000, 0x10c6)
        w32(a_shita, r() and def_shita or stou32(v))
        w32(a_ue, r() and def_ue or stou32(v + d))
    end
end)(),
}

local left_eyebrow = {
ValueUpdater(1, -0x400, 0x200)
:calc((function()
    local r = RC(10)
    local target = 0
    ---@param obj ValueUpdaterObj
    return function(obj)
        if r() then
            target = rand(obj:get_minmax())
        end
        return math.ilerp(s32(obj.v), target, 0.1)
    end
end)())
:write(function(v) w32(0x0296E504, stou32(v)) end),
ValueUpdater(1, -0x400, 0x200)
:calc((function()
    local r = RC(3)
    local target = 0
    ---@param obj ValueUpdaterObj
    return function(obj)
        if r() then
            target = rand(obj:get_minmax())
        end
        return math.ilerp(s32(obj.v), target, 0.3)
    end
end)())
:write(function(v) w32(0x0296E544, stou32(v)) end),
}

local body = {
(function()
    local ay = 0x0296E4BC
    local ax = 0x0296E4C4
    local iy = 0
    local ix = 0
    local span = 60
    local def_x = 0
    local def_y = 0x0500
    local depth = 0x20
    return function()
        iy = (iy + rand(-2, 4)) % span
        ix = (ix + rand(-2, 4)) % span
        local x = math.round(math.sin(ix * 2 * math.pi / span) * depth)
        local y = math.round(math.sin(iy * 2 * math.pi / span) * depth)
        w32(ax, stou32(def_x + x))
        w32(ay, stou32(def_y + y))
    end
end)(),
}

local bodies = {
left_eye,
right_eye,
glasses,
left_eyebrow,
mouses,
hoo,
body,
}

function loop()
    for _, __body in pairs(bodies) do
        for _, v in pairs(__body) do v() end
    end
    local _v
    w32(0x0296E4AC, 0xFFFFFD00)
    _v = 0x1400
    w32(0x0296E4B0, _v)
    w16(0x02128768, 0)
    w16(0x02129050, 0)
    w16(0x02128768, 0)
    w16(0x02129050, 0)
end

lib.irume.start(function()
    local head = 0x03EC8A00
    local as = {}
    local prev = 0
    for i = 0, 16 do
        as[i] = head + 0x40 * i
    end
    local p = 0x1f
    local r = RC(10)
    local time = 0x2c
    local c = Cnt(5) c()
    local v = 0x16
    return function()
        local _t = r8(as[0] + time)
        if prev < _t then
            _t = c() and 0x16 or 0x6
            for i, a in pairs(as) do
                w8(a + p, stou8(rand(0, 24)))
            end
        end
        for i, a in pairs(as) do
            w16(a + v, 0x80)
            w8(a + time, _t)
        end
        prev = _t
    end
end)
```

## video13 雑多メモ

```lua
local addrs = {
-- 顔全体
-- 0x0296E4B8,
-- まゆげあたり
-- 0x0296E4E4,
-- 0x0296E4F8,
-- 0x0296E524,
-- 0x0296E538,

-- 黒目
-- 0x0296E54C,
-- 0x0296E560,

-- メガネ
-- 0x0296E5D4,

-- 左頬
-- 0x0296E5E8,

-- 下唇, あご中心
0x0296E5FC,

-- あご左
-- 0x0296E610,

-- あご右
-- 0x0296E624,

-- 右頬
-- 0x0296E638,

-- 上唇
0x0296E64C,
}


local backup = lib.range(0x0296E4B8, 0x0296F01F):save()
local r = RC(90)
function loop()
    if r() then backup:rollback() end
    local scale = 0x20
    for i, a in pairs(addrs) do
        for j = 1, 3 do
            add32(a+j*4, rand(-scale, scale))
        end
    end
end
```

