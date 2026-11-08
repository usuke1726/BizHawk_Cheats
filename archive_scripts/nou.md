
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

## video17

<details>
<summary>画像データ</summary>
<div>

<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IB2cksfwAAAARnQU1BAACxjwv8YQUAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAAlwSFlzAAAuIwAALiMBeKU/dgAAAAd0SU1FB+oJDwMtJDAX4AQAAABsSURBVDjLtVJBDsAgCCvG4P+fCxd2gujmMHGzx1JrxZKIGDNjFxUAVDWI1togEJG1wf1Qj7eZG5fd6G68beD4bFABwMyCIKJBkM3+f8LshuM7KF6kvkz9X8/4xxKzwmQliwQr0fkdZF0/nuACWPciHowdyJgAAAAASUVORK5CYII=">
<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IB2cksfwAAAARnQU1BAACxjwv8YQUAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAAlwSFlzAAAuIwAALiMBeKU/dgAAAAd0SU1FB+oJDwMuEDqOR3IAAABSSURBVDjLvZLBDgAgCEKx8f+/TKdulk4rzrI9BJMkNDTQFAHAzEpmSX2COxE8NE9e1H8Rdo/mCTkypwiiilk1LmpmDbuWRmV9qQjZbTA6eD7lCVxeHCeFhfnMAAAAAElFTkSuQmCC">
<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IB2cksfwAAAARnQU1BAACxjwv8YQUAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAAlwSFlzAAAuIwAALiMBeKU/dgAAAAd0SU1FB+oJDwMuHUQ/O88AAABISURBVDjLzZFJCgAwCAPH4v+/nJ56KRaK0iXnZMDRJIlCHMDMloWZP3cbxbwHeHTnUYn/ObgrMXLl2eH2F446kJQHDG+tMgboJDUZJXHCL54AAAAASUVORK5CYII=">
<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IB2cksfwAAAARnQU1BAACxjwv8YQUAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAAlwSFlzAAAuIwAALiMBeKU/dgAAAAd0SU1FB+oJDwMuK4uFrlYAAABVSURBVDjLxZNJDsAwCAMN4v9fnp4qRVH2pfWV1TYYgDYQkmRmS8WAXJv4v0G8XHqo6fQNhZZLMZpYsnCZQqrZWQ2AriN5fHqDXCevTRn9MZ9Z98ohPTj4IhM0TiEvAAAAAElFTkSuQmCC">

<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IB2cksfwAAAARnQU1BAACxjwv8YQUAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAAlwSFlzAAAuIwAALiMBeKU/dgAAAAd0SU1FB+oJDwMVDWU6xJMAAABiSURBVFjD7ZfbCQAgDANNcf+V6wKCD9QgXD9F7dEoJMrMLMaKYi47QO0tSupuXlVr5h4kqLsHT8mEBAAAAAAAAADwrx84ZaZj1mhcn8Drxv89wlsBKpzNh7/gRWwU4dQN0ACCux07MUmRJwAAAABJRU5ErkJggg==">
<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IB2cksfwAAAARnQU1BAACxjwv8YQUAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAAlwSFlzAAAuIwAALiMBeKU/dgAAAAd0SU1FB+oJDwQAI4sWOc0AAACTSURBVFjD7dfRDoAgCAVQcfz/L9NTGzZzJNdhE95aNQRPpiQiUgKDZ14ioubaUwN7EiOiRiYfduBLQsuzb9NUS3CED8CEcFa5ZWo4EmAaSANpYLkB2ABWGLiLSgNnGtAFnWlAd3RfhE94PQdWnCNDjNjze84J+68Do/YhPs9/rITo3ZA2wr2bVlSIQyp71n7EP+ICc9o6Z8Whe8gAAAAASUVORK5CYII=">

</div>
</details>


```py
from PIL import Image
name = "SIMA"

img = Image.open(f"./{name}.png").convert("RGB")

data = f"local DATA_{name} = {{\n"
size = img.size

for y in range(0, size[1]):
    s = ""
    for x in range(0, size[0]):
        r = img.getpixel((x, y))[0]
        # 色は白(255,255,255)と黒(0,0,0)の2色のみを想定
        c = "#" if r < 50 else "."
        s += c
    data += f"\"{s}\",\n"

data += "}"

with open(f"./out.txt", "w") as f:
    f.write(data)
```

```lua
-- 「カワシマ」などのフォントのドットデータをインポート
-- データは、まずGimp等で32x32(漢字)あるいは16x16(カタカナ)のフォント画像を作成、
-- その後、上のpythonスクリプトでluaデータを生成し、それを格納したのがこのデータファイル
local data = require "misc/_kawashima_data"

local function set_left_screen()


local function pos(x, y)
    return lib.pos.Morton(x, y, 4, 0x20, 0x400) + 0x06004000
end

local function IN(x, y)
    x, y = y, 67-x
    if within(y, 0, 1) or within(y, 66, 67) then
        return false
    end
    y = y - 2
    local d
    if x < 16 then
        if y < 16 then d = data.KA
        elseif y < 32 then d = data.WA
        elseif y < 48 then d = data.SI
        else d = data.MA
        end
        y = y % 16
    else
        x = (x - 16) % 32
        if y < 32 then d = data.KAWA
        else d = data.SIMA
        end
        y = y % 32
    end
    local c = string.sub(d[y+1], x+1, x+1)
    return c ~= "."
end

local function dot(x, y)
    local n = 10
    x = (x - 128) / 128
    y = (y - 96) / 96
    local r
    if x == 0 then
        r = math.pi / 2.0
        if y < 0 then r = -r end
    else r = math.atan(y/x)
    end
    r = clamp(r + math.pi / 2.0, 0.0, math.pi)
    local _r = math.pi / n
    while r >= _r do r = r - _r end
    r = clamp(r, 0, _r)
    return r < 0.3*_r and 1 or 0
end

-- width: 128(1byteに2dotなので実際はその2倍), height: 192
lib.image.filterObj()
:width(128):height(192)
:go(function(x, y)
    if within(x, 24, 57) then
        local f1 = IN((x-24)*2, y)
        local f2 = IN((x-24)*2+1, y)
        if f1 == nil or f2 == nil then return end
        f1 = f1 and 1 or 0
        f2 = f2 and 1 or 0
        local v = (f2 << 4) | f1
        return pos(x, y), v
    end
    local x1 = x*2
    local x2 = x*2 + 1
    local v = (dot(x2, y) << 4) | dot(x1, y)
    return pos(x, y), v
end)

end


local function set_right_screen()

local function pos(x, y)
    return lib.pos.Morton(x, y, 4, 0x20, 0x400) + 0x06600460
end

local function pos2(x, y)
    return lib.pos.Morton(x, y, 4, 0x20, 0x400) + 0x06204000
end


lib.image.filterObj()
:width(128):height(192)
:go(function(x, y)
    local _x = (x - 40) % 15 + 40
    local _y = (y - 9) % 27 + 9
    return pos(x, y), r8(pos(_x, _y))
end)
:go(function(x, y)
    if x < 112 then return end
    local _x = x - 112 + 40
    local _y = (y - 9) % 27 + 9
    return pos2(x, y), r8(pos(_x, _y))
end)

end



local update_rip = (function()
    local c = Cnt(30, 2)
    return function()
        w8(0x02969376, c:next() == 0 and 0xce or 0x9e)
    end
end)()

local update_eyes = (function()
    local d = 0x80
    local v1 = ValueUpdater(1, 0x06d0, 0x07ff, VUO.addrand(-d, d))
    :init(0x0740)
    :w32(0x296E5C0)
    local v2 = ValueUpdater(1, 0x06d0, 0x07ff, VUO.addrand(-d, d))
    -- local v2 = ValueUpdater(10, 0x06d0, 0x07ff, "pingpong")
    :init(0x0740)
    :w32(0x296E5A8)
    -- local v3 = ValueUpdater(20, 0x06e0, 0x0840, "pingpong")
    local v3 = ValueUpdater(20, 0x0680, 0x08f0, "lerp")
    :w32(0x0296e550)
    -- local v4 = ValueUpdater(20, 0x06e0, 0x0840, "pingpong")
    local v4 = ValueUpdater(20, 0x0680, 0x08f0, "lerp")
    :w32(0x0296e564)
    local cooltime = 180
    local r = RC(60)
    return function()
        v3()
        v4()
        if cooltime > 0 then
            w32(0x296E5C0, 0x07ff)
            w32(0x296E5A8, 0x07ff)
            cooltime = cooltime - 1
            return
        end
        if r() then v3.n = rand(5, 30) end
        if r() then v4.n = rand(5, 30) end
        v1()
        v2()
    end
end)()

local update_AGO = (function()
    local cooltime = 280
    local scale = 0x10
    local r = RC(20)
    return function()
        if cooltime > 0 then
            w32(0x0296E604, 0x10c)
            cooltime = cooltime - 1
            return
        end
        if r() then
            w32(0x0296E604, rand(-0x100, 0x10fc))
        end
    end
end)()

local update_eye_color = (function()
    local vs = {0x1fce0000, 0x11110000}
    local r = RC(10)
    local c = Cnt(#vs)
    return function()
        if r() then
            w32(0x0296926C, vs[c:next()+1])
        end
    end
end)()

local update_time = (function()
    local cooltime = 280
    local scale = 0x1c
    local c = Cnt(60)
    -- local scale = 0x8
    local v = ValueUpdater(20, -scale, scale, "pingpong")
    :w32(0x02128768)
    return function()
        w16(0x02129050, 0)
        if cooltime > 0 then
            w16(0x02128768, 0)
            cooltime = cooltime - 1
            return
        end
        if c() then
            v.n = clamp(v.n-1, 2, 20)
        end
        v()
    end
end)()

local ready_m = lib.at(0x0210b024)
local ready = false

local function irume()
    local head = 0x03EC8A00
    local as = {}
    local prev = {}
    for i = 0, 18 do
        as[i] = head + 0x40 * i
        prev[i] = 0
    end
    local _t = 0x2c
    local p2 = 0x18
    local vol = 0x16
    return function()
        for i, a in pairs(as) do
            w16(a+vol, 0x8000)
            w16(a+p2, rand(-20,20)*0x8)
            local t = r8(a + _t)
            if prev[i] < t then
                t = clamp(t*3, 0x20, 0xe0)
            end
            w8(a+_t, t)
            prev[i] = t
        end
    end
end

function loop()
    if not ready then
        if ready_m:r32() == 0 then
            return
        end
        print("== READY!! ==")
        lib.irume.start(irume)
        set_left_screen()
        set_right_screen()
        ready = true
    end
    w8(0x029692E2, 0) -- ハゲ
    update_eye_color()
    -- w32(0x029692F0, 0x77FF0000) -- 髪の毛ワイヤー
    -- w32(0x0296926C, 0x11110000)
    update_AGO()
    update_time()

    w16(0x029692B8, 0x1111)
    w8(0x02969288, 0x11)
    -- w8(0x029693bb, rand(0,0xff))
    -- update_rip()
    update_eyes()

    w32(0x0296E4BC, 0x0a00)
    w32(0x0296E4C0, 0xffffe800)
end
```

## video19

```lua

local _, JNT_addrs = lib.find_all(0x02000000, 0x023fffff, ascii("JNT0"), nil, nil, true)

local addrs = lib.array.flat(lib.array.map(JNT_addrs, function(a)
    local res = Nitro.read_JNT0(a, lib.path.dummy())
    return lib.array.flat({
        -- res.addrs_tr,
        res.addrs_scl,
        res.addrs_rot,
    })
end))

local origs = {}
for _, a in pairs(addrs) do
    origs[a] = r8(a)
    origs[a+1] = r8(a+1)
end

local r = RC(5)
-- local r = RC(20)
local r2 = RC(30)
SET_LOOP("MOVE", function()
    for _, a in pairs(addrs) do
        if r() then
            -- add8(a + rand(0,1), rand(-3, 3)*(0x4 << rand(0,2)))
            add8(a + rand(0,0), rand(-3, 3)*0x4)
        end
        if r2() then w8(a, origs[a]) end
        if r2() then w8(a+1, origs[a+1]) end
    end
end)

w32(0x04000350, 0x99990099) -- 上画面の背景を赤くする

lib.irume.start(function()
    local head = 0x03EC8A00
    local as = {}
    local prev = {}
    local ps = {}
    for i = 0, 18 do
        as[i] = head + 0x40 * i
        prev[i] = 0
        ps[i] = 0
    end
    local _t = 0x2c
    local p1 = 0x1f
    local p2 = 0x18
    local vol = 0x16
    return function()
        for i, a in pairs(as) do
            w16(a+vol, 0x8000)
            ps[i] = (ps[i] + 0x10) % 0x800
            w16(a+p2, ps[i] - 0x400)
            local t = r8(a + _t)
            if prev[i] < t then
                t = clamp(t*3, 0x20, 0xe0)
            end
            w8(a+_t, t)
            prev[i] = t
        end
    end
end)
```


## video24 ゴンさん風

```lua
local function set_left_screen()

w32(0x04000350, 0x99990099) -- 上画面の背景を赤くする
-- ゴンさん化
local res = Nitro.read_MDL0(0x02168B54, 0)
local meshes = res.addrs_mesh
local num = #meshes
local v16 = MESH_LIB.VTX_16
local vdif = MESH_LIB.VTX_DIFF
printf("%d meshes", num)
for _, mesh in pairs(pick(meshes, {
range(1, 3)
})) do
local B = Nitro.Bound3D()
local cnt = Array.countUp()
Nitro.filter_mesh(mesh.begin, mesh.iend, function(addr, info)
    if info.name == MESH_COMMANDS.VTX_16 then
        assert(addr%2==0)
        local pos = v16.read(addr)
        B:push(pos.x, pos.y, pos.z)
    end
end)
Nitro.filter_mesh(mesh.begin, mesh.iend, function(addr, info)
    cnt:add(info.name)
    if info.name == MESH_COMMANDS.VTX_16 then
        assert(addr%2==0)
        local pos = v16.read(addr)
        local x = pos.x
        if within(B:xinv(x), 0.4, 1.0) then
            pos.x = x+3
        end
        -- pos.x = pos.x + 1
        v16.write(addr, pos)
    end
end)
-- cnt:print()
end

for _, mesh in pairs(pick(meshes, {
range(9, 9)
})) do
local B = Nitro.Bound3D()
Nitro.filter_mesh(mesh.begin, mesh.iend, function(addr, info)
    if info.name == MESH_COMMANDS.VTX_16 then
        assert(addr%2==0)
        local pos = v16.read(addr)
        B:push(pos.x, pos.y, pos.z)
    end
end)
Nitro.filter_mesh(mesh.begin, mesh.iend, function(addr, info)
    if info.name == MESH_COMMANDS.VTX_16 then
        assert(addr%2==0)
        local pos = v16.read(addr)
        pos.x = 1-B:xinv(pos.x)
        -- pos.x = pos.x + 0.1
        -- pos.z = pos.z+0.1
        -- pos.x = pos.x + 1
        v16.write(addr, pos)
    elseif info.name == MESH_COMMANDS.VTX_DIFF then
        local pos = vdif.read(addr)
        pos.x = pos.x - 0.01
        -- vdif.write(addr, pos)
    end
end)
end

for _, mesh in pairs(pick(meshes, {
range(13, 13)
})) do
Nitro.filter_mesh(mesh.begin, mesh.iend, function(addr, info)
    if info.name == MESH_COMMANDS.VTX_16 then
        assert(addr%2==0)
        local pos = v16.read(addr)
        pos.x = pos.x - 0.1
        -- pos.z = pos.z+0.1
        -- pos.x = pos.x + 1
        v16.write(addr, pos)
    elseif info.name == MESH_COMMANDS.VTX_DIFF then
        local pos = vdif.read(addr)
        pos.x = pos.x - 0.01
        vdif.write(addr, pos)
    end
end)
end

for _, mesh in pairs(pick(meshes, {
range(6, 6)
})) do
Nitro.filter_mesh(mesh.begin, mesh.iend, function(addr, info)
    if info.name == MESH_COMMANDS.VTX_16 then
        local pos = v16.read(addr)
        pos.x = pos.x + 4.5
        v16.write(addr, pos)
    end
end)
end

-- 黒目
w32(0x0296E550, 0x0590)
w32(0x0296E554, 0x1A48)
w32(0x0296E558, 0x0140)
w32(0x0296E564, 0x0590)
w32(0x0296E568, 0x1A48)
w32(0x0296E56C, 0xFFFFFEB0)
-- w32(0x0296E550, 0x0600)
-- w32(0x0296E554, 0x1448)
-- w32(0x0296E558, 0x0160)
-- w32(0x0296E564, 0x0600)
-- w32(0x0296E568, 0x1448)
-- w32(0x0296E56C, 0xFFFFFEB0)

w32(0x0296E5D8, 0x3000)
-- まゆ
w32(0x0296E4EC, 0x0140)
w32(0x0296E52C, 0x0140)
w32(0x0296E504, -0x180)
w32(0x0296E544, 0x0180)
-- w32(0x0296E4E8, 0)
-- w32(0x0296E528, 0)

w32(0x0296E5C0, 0x0a20)
w32(0x0296E5A8, 0x0a20)

local update_time = (function()
    return function()
        w16(0x02129050, 0)
        w16(0x02128768, 0)
    end
end)()
SET_LOOP("update_time", update_time)

w16(0x216E468, 1) -- 瞬きをさせない


w32(0x0296E5A8, 0x2200)
w32(0x0296E5C0, 0x2200)
-- local res = Nitro.read_MDL0(0x02168B54, 0)
-- local meshes = res.addrs_mesh
-- local num = #meshes
-- local v16 = MESH_LIB.VTX_16
-- local vdif = MESH_LIB.VTX_DIFF

for _, mesh in pairs(pick(meshes, {
range(9, 9)
})) do
local B = Nitro.Bound3D()
Nitro.filter_mesh(mesh.begin, mesh.iend, function(addr, info)
    if info.name == MESH_COMMANDS.VTX_16 then
        assert(addr%2==0)
        local pos = v16.read(addr)
        B:push(pos.x, pos.y, pos.z)
    end
end)
Nitro.filter_mesh(mesh.begin, mesh.iend, function(addr, info)
    if info.name == MESH_COMMANDS.VTX_16 then
        assert(addr%2==0)
        local pos = v16.read(addr)
        -- if within(B:zinv(pos.z), 0,0.3) then
        -- pos.z = pos.z+4.1
        -- end
        local dx = math.max(B:xinv(pos.x) *0.2 - 0.5, 0)
        pos.z = B:zinv(pos.z)*0.1 - 0.05 - dx
        pos.x = pos.x - 0.15

        -- pos.x = pos.x + 0.1
        -- pos.x = pos.x + 1
        v16.write(addr, pos)
    elseif info.name == MESH_COMMANDS.VTX_DIFF then
        local pos = vdif.read(addr)
        pos.x = pos.x + 0.01
        -- vdif.write(addr, pos)
    end
end)
end

end


local set_right_screen = (function()
local _FONTS = {
["貴"] = {
"........",
"....#...",
"..#####.",
"..#.#.#.",
".#######",
"..#...#.",
"..#####.",
".##...##",
},
["様"] = {
"........",
"..#.#.#.",
".#######",
"..#.###.",
".#######",
".###.#.#",
"..#.###.",
"..##.#.#",
},
["を"] = {
"........",
"....#...",
"..#####.",
"...#....",
"..###.##",
".#..##..",
"...#.#..",
"....####",
},
["殺"] = {
"........",
"..#.####",
"...#.#.#",
".##.#...",
"...#.###",
".#####.#",
"..###.#.",
".#.#.#.#",
},
["す"] = {
"........",
".....#..",
".#######",
"....##..",
"...#.#..",
"....##..",
".....#..",
"....#...",
},
["お"] = {
"........",
"...#....",
".####.#.",
"...#...#",
"...####.",
"..##...#",
".#.#...#",
"..##.##.",
},
["う"] = {
"........",
"..####..",
"........",
"..####..",
".#....#.",
"......#.",
".....#..",
"..###...",
},
["終"] = {
"........",
"..#..##.",
".#..#.#.",
"..#..#..",
".#.##.##",
"..#..#..",
".###....",
"..#..##.",
},
["や"] = {
"........",
"..#..#..",
"..#.###.",
".###...#",
"...#..#.",
"...#....",
"....#...",
"....#...",
},
["み"] = {
"........",
"..###...",
"....#...",
"...#..#.",
"..#####.",
".#.#..##",
".##...#.",
"....##..",
},
["わ"] = {
"........",
"...#....",
"...#.##.",
".####..#",
"...#...#",
"..##...#",
".#.#...#",
"...#.##.",
},
["も"] = {
"........",
"...#....",
".######.",
"..#.....",
".######.",
"..#....#",
"..#....#",
"...####.",
},
["っ"] = {
"........",
"........",
"........",
"...###..",
".##...#.",
"......#.",
".....#..",
"...##...",
},
["て"] = {
"........",
".#######",
"....#...",
"...#....",
"...#....",
"...#....",
"...#....",
"....###.",
},
["い"] = {
"........",
".#....#.",
".#.....#",
".#.....#",
".#.....#",
".#.....#",
".#.#....",
"..#.....",
},
}

local function pos(x, y)
    return lib.pos.Morton(x, y, 4, 0x20, 0x400) + 0x06600460
end

local function pos2(x, y)
    return lib.pos.Morton(x, y, 4, 0x20, 0x400) + 0x06204000
end

local texts = {
{"終わってもいい", 7},
{"貴様を殺す", 5},
{"もうおやすみ", 6},
}
local idx = 1
local function bit(x, y)
    local len = texts[idx][2]
    local _x = x % 8
    local _y = (y+(x//8)*27) % (8*len)
    local _y2, _y3 = _y // 8, _y % 8
    _x = 7-_x
    local c = string.sub(texts[idx][1], _y2*3+1, _y2*3+3)
    local _c = _FONTS[c]
    if not _c then
        error(string.format("NOT FOUND \"%s\"", c))
    end
    local c2 = string.sub(assert(_c[_x+1]), _y3+1, _y3+1)
    return c2 == "#" and 0xf or 0x1
end

local enable_noise = true
local function noise()
    if not enable_noise then return 0xf end
    return (rand(0,5)>=1 and 0xf or 0x1)
end
local function update(i)
lib.image.filterObj_HalfByte()
:width(256):height(192)
:reverse()
:addr(pos)
:go(function(x, y, vs)
    x = x - 4 + i//4
    y = y - 9 + i
    return bit(x, y) & noise()
end)

lib.image.filterObj_HalfByte()
:width(256):height(192)
:reverse()
:addr(pos2)
:go(function(x, y, vs)
    x = x - 4 + i//4
    y = y - 9 + i
    return bit(x, y) & noise()
end)
end
local r = RC(10)

local t = 0
return function()
    t = t + 8
    if r() then
        local _idx = rand(1, #texts)
        if idx ~= _idx then
            idx = _idx
        end
    end
    update(t)
end
end)()

local ready_m = lib.at(0x0210b024)
local ready = false
local ready_mdl_m = lib.at(0x02168B54)
local ready_mdl = false
local mdl_change_cooltime = CntOnce(5)
mdl_change_cooltime.active = false
local time = 0

local vb = 0x10
local v1 = ValueUpdater(1, -vb, vb, VUO.addrand(-8, 8))
:w32(0x0296E4A8)
local v2 = ValueUpdater(1, -0xc00-vb, -0xc00+vb, VUO.addrand(-8, 8))
:w32(0x0296E4AC)

function loop()
    if not ready_mdl then
        if ready_mdl_m:r8() ~= 0 then
            ready_mdl = true
            mdl_change_cooltime.active = true
        end
    end
    if mdl_change_cooltime() then
        set_left_screen()
        print("=== FIRE ===")
    end
    if not ready then
        if ready_m:r32() == 0 then
            return
        end
        print("== READY!! ==")
        -- SET_LOOP("right", set_right_screen)
        ready = true
    else
        time = time + 1
        CLS()
        printf("time: %f", time / 60)
        v1() v2()
    end
end

lib.irume.start(function()
    local head = 0x03EC8A00
    local as = {}
    local prev = {}
    local ps = {}
    local tone = 0xe
    for i = 0, 18 do
        as[i] = head + 0x40 * i
        prev[i] = 0
        ps[i] = rand(-50, -46)*0x20
    end
    local _t = 0x2c
    local p1 = 0x1f
    local p2 = 0x18
    local vol = 0x16
    local r = RC(90)
    local rl = RL(300)
    return function()
        rl()
        for i, a in pairs(as) do
            w16(a+vol, 0x8000)
            if rl.fired and r() then
                ps[i] = rand(-80, 160)*0x20
            end
            w16(a+p2, ps[i])
            local t = r8(a + _t)
            if prev[i] < t then
                t = rand(0xf0, 0xff)
                t = t * t
            end
            w8(a+_t, t)
            prev[i] = t
            w8(a+tone, 2)
        end
    end
end)
```

<details open>
<summary>(旧版)</summary>
<div>

```lua

w32(0x04000350, 0x99990099) -- 上画面の背景を赤くする
-- ゴンさん化
local res = Nitro.read_MDL0(0x02168B54, 0)
local meshes = res.addrs_mesh
local num = #meshes
local v16 = MESH_LIB.VTX_16
local vdif = MESH_LIB.VTX_DIFF
printf("%d meshes", num)
for _, mesh in pairs(pick(meshes, {
range(1, 3)
})) do
local B = Nitro.Bound3D()
local cnt = Array.countUp()
Nitro.filter_mesh(mesh.begin, mesh.iend, function(addr, info)
    if info.name == MESH_COMMANDS.VTX_16 then
        assert(addr%2==0)
        local pos = v16.read(addr)
        B:push(pos.x, pos.y, pos.z)
    end
end)
Nitro.filter_mesh(mesh.begin, mesh.iend, function(addr, info)
    cnt:add(info.name)
    if info.name == MESH_COMMANDS.VTX_16 then
        assert(addr%2==0)
        local pos = v16.read(addr)
        local x = pos.x
        if within(B:xinv(x), 0.4, 1.0) then
            pos.x = x+3
        end
        -- pos.x = pos.x + 1
        v16.write(addr, pos)
    end
end)
-- cnt:print()
end

for _, mesh in pairs(pick(meshes, {
range(9, 9)
})) do
local B = Nitro.Bound3D()
Nitro.filter_mesh(mesh.begin, mesh.iend, function(addr, info)
    if info.name == MESH_COMMANDS.VTX_16 then
        assert(addr%2==0)
        local pos = v16.read(addr)
        B:push(pos.x, pos.y, pos.z)
    end
end)
Nitro.filter_mesh(mesh.begin, mesh.iend, function(addr, info)
    if info.name == MESH_COMMANDS.VTX_16 then
        assert(addr%2==0)
        local pos = v16.read(addr)
        pos.x = 1-B:xinv(pos.x)
        -- pos.x = pos.x + 0.1
        -- pos.z = pos.z+0.1
        -- pos.x = pos.x + 1
        v16.write(addr, pos)
    elseif info.name == MESH_COMMANDS.VTX_DIFF then
        local pos = vdif.read(addr)
        pos.x = pos.x - 0.01
        -- vdif.write(addr, pos)
    end
end)
end

for _, mesh in pairs(pick(meshes, {
range(13, 13)
})) do
Nitro.filter_mesh(mesh.begin, mesh.iend, function(addr, info)
    if info.name == MESH_COMMANDS.VTX_16 then
        assert(addr%2==0)
        local pos = v16.read(addr)
        pos.x = pos.x - 0.1
        -- pos.z = pos.z+0.1
        -- pos.x = pos.x + 1
        v16.write(addr, pos)
    elseif info.name == MESH_COMMANDS.VTX_DIFF then
        local pos = vdif.read(addr)
        pos.x = pos.x - 0.01
        vdif.write(addr, pos)
    end
end)
end

for _, mesh in pairs(pick(meshes, {
range(6, 6)
})) do
Nitro.filter_mesh(mesh.begin, mesh.iend, function(addr, info)
    if info.name == MESH_COMMANDS.VTX_16 then
        local pos = v16.read(addr)
        pos.x = pos.x + 4.5
        v16.write(addr, pos)
    end
end)
end

-- 黒目
w32(0x0296E550, 0x0590)
w32(0x0296E554, 0x1A48)
w32(0x0296E558, 0x0140)
w32(0x0296E564, 0x0590)
w32(0x0296E568, 0x1A48)
w32(0x0296E56C, 0xFFFFFEB0)
-- w32(0x0296E550, 0x0600)
-- w32(0x0296E554, 0x1448)
-- w32(0x0296E558, 0x0160)
-- w32(0x0296E564, 0x0600)
-- w32(0x0296E568, 0x1448)
-- w32(0x0296E56C, 0xFFFFFEB0)

w32(0x0296E5D8, 0x3000)
-- まゆ
w32(0x0296E4EC, 0x0140)
w32(0x0296E52C, 0x0140)
w32(0x0296E504, -0x180)
w32(0x0296E544, 0x0180)
-- w32(0x0296E4E8, 0)
-- w32(0x0296E528, 0)

w32(0x0296E5C0, 0x0a20)
w32(0x0296E5A8, 0x0a20)

local update_time = (function()
    return function()
        w16(0x02129050, 0)
        w16(0x02128768, 0)
    end
end)()
SET_LOOP("update_time", update_time)

w16(0x216E468, 1) -- 瞬きをさせない



w32(0x0296E5A8, 0x2200)
w32(0x0296E5C0, 0x2200)
-- local res = Nitro.read_MDL0(0x02168B54, 0)
-- local meshes = res.addrs_mesh
-- local num = #meshes
-- local v16 = MESH_LIB.VTX_16
-- local vdif = MESH_LIB.VTX_DIFF

for _, mesh in pairs(pick(meshes, {
range(9, 9)
})) do
local B = Nitro.Bound3D()
Nitro.filter_mesh(mesh.begin, mesh.iend, function(addr, info)
    if info.name == MESH_COMMANDS.VTX_16 then
        assert(addr%2==0)
        local pos = v16.read(addr)
        B:push(pos.x, pos.y, pos.z)
    end
end)
Nitro.filter_mesh(mesh.begin, mesh.iend, function(addr, info)
    if info.name == MESH_COMMANDS.VTX_16 then
        assert(addr%2==0)
        local pos = v16.read(addr)
        -- if within(B:zinv(pos.z), 0,0.3) then
        -- pos.z = pos.z+4.1
        -- end
        local dx = math.max(B:xinv(pos.x) *0.2 - 0.5, 0)
        pos.z = B:zinv(pos.z)*0.1 - 0.05 - dx
        pos.x = pos.x - 0.15

        -- pos.x = pos.x + 0.1
        -- pos.x = pos.x + 1
        v16.write(addr, pos)
    elseif info.name == MESH_COMMANDS.VTX_DIFF then
        local pos = vdif.read(addr)
        pos.x = pos.x + 0.01
        -- vdif.write(addr, pos)
    end
end)
end



local function set_right_screen()
local _FONTS = {
["終"] = {
"........",
"..#..##.",
".#..#.#.",
"..#..#..",
".#.##.##",
"..#..#..",
".###....",
"..#..##.",
},
["わ"] = {
"........",
"...#....",
"...#.##.",
".####..#",
"...#...#",
"..##...#",
".#.#...#",
"...#.##.",
},
["も"] = {
"........",
"...#....",
".######.",
"..#.....",
".######.",
"..#....#",
"..#....#",
"...####.",
},
["っ"] = {
"........",
"........",
"........",
"...###..",
".##...#.",
"......#.",
".....#..",
"...##...",
},
["て"] = {
"........",
".#######",
"....#...",
"...#....",
"...#....",
"...#....",
"...#....",
"....###.",
},
["い"] = {
"........",
".#....#.",
".#.....#",
".#.....#",
".#.....#",
".#.....#",
".#.#....",
"..#.....",
},
}

local function pos(x, y)
    return lib.pos.Morton(x, y, 4, 0x20, 0x400) + 0x06600460
end

local function pos2(x, y)
    return lib.pos.Morton(x, y, 4, 0x20, 0x400) + 0x06204000
end

local function bit(x, y)
    local _y = y % 56
    local _y2, _y3 = _y // 8, _y % 8
    local _x = x % 8
    _x = 7-_x
    local c = string.sub("終わってもいい", _y2*3+1, _y2*3+3)
    local c2 = string.sub(assert(_FONTS[c][_x+1]), _y3+1, _y3+1)
    return c2 == "#" and 0xf or 0x1
end

lib.image.filterObj_HalfByte()
:width(256):height(192)
:reverse()
:addr(pos)
:go(function(x, y, vs)
    x = x - 4
    y = y - 9
    return bit(x, y)
end)

lib.image.filterObj_HalfByte()
:width(256):height(192)
:reverse()
:addr(pos2)
:go(function(x, y, vs)
    x = x - 4
    y = y - 9
    return bit(x, y)
end)

end

local ready_m = lib.at(0x0210b024)
local ready = false
function loop()
    if not ready then
        if ready_m:r32() == 0 then
            return
        end
        print("== READY!! ==")
        set_right_screen()
        ready = true
    end
end

-- イルームは同じなので省略
```

</div>
</details>

---

## video24 カツラ風 & へんな眉毛

```lua

local res = Nitro.read_MDL0(0x02168B54, 0)
local meshes = res.addrs_mesh
local num = #meshes
local v16 = MESH_LIB.VTX_16
local vdif = MESH_LIB.VTX_DIFF

for _, mesh in pairs(pick(meshes, {
range(1, 3)
})) do
Nitro.filter_mesh(mesh.begin, mesh.iend, function(addr, info)
    if info.name == MESH_COMMANDS.VTX_16 then
        assert(addr%2==0)
        local pos = v16.read(addr)
        pos.x = pos.x /2+0.4
        pos.z=pos.z/3
        pos.y=pos.y+0.1
        -- pos.z = pos.z+0.1
        -- pos.x = pos.x + 1
        v16.write(addr, pos)
    elseif info.name == MESH_COMMANDS.VTX_DIFF then
        local pos = vdif.read(addr)
        pos.x = pos.x + 0.005
        -- vdif.write(addr, pos)
    end
end)
end
for _, mesh in pairs(pick(meshes, {
range(11, 11),
range(13, 13),
})) do
Nitro.filter_mesh(mesh.begin, mesh.iend, function(addr, info)
    if info.name == MESH_COMMANDS.VTX_16 then
        assert(addr%2==0)
        local pos = v16.read(addr)
        pos.x = pos.x - 0.1
        -- pos.z = pos.z+0.1
        -- pos.x = pos.x + 1
        v16.write(addr, pos)
    elseif info.name == MESH_COMMANDS.VTX_DIFF then
        local pos = vdif.read(addr)
        pos.x = pos.x - 0.01
        vdif.write(addr, pos)
    end
end)
end
w32(0x0296E4E8, 0)
w32(0x0296E528, 0)

w32(0x0296E5C0, 0x0a20)
w32(0x0296E5A8, 0x0a20)

-- 激チカ
w32(0x0296E4BC, 0x0a00)
w32(0x0296E4C0, 0xffffe800)


local update_time = (function()
    return function()
        w16(0x02129050, 0)
        w16(0x02128768, 0)
w16(0x216E468, 1) -- 瞬きをさせない
    end
end)()
SET_LOOP("update_time", update_time)


local update_move = (function()
local v1 = ValueUpdater(1, -0x600, 0x600, VUO.addrand(-0x8, 0x8, 0xa0))
:w32(0x0296E4A8)
local c = Cnt(2)
return function()
    if c() then return end
    v1()
end
end)()

SET_LOOP("move", update_move)


lib.irume.start(function()
    local head = 0x03EC8A00
    local as = {}
    local prev = {}
    local ps = {}
    local tone = 0xe
    for i = 0, 18 do
        as[i] = head + 0x40 * i
        prev[i] = 0
        ps[i] = 0x200
    end
    local _t = 0x2c
    local p1 = 0x1f
    local p2 = 0x18
    local vol = 0x16
    local r = RC(90)
    local sin = ValueUpdater(90, -0x100, 0x100, "pingpong")
    return function()
        sin()
        for i, a in pairs(as) do
            w16(a+vol, 0x80)
            w16(a+p2, sin.v)
            w8(a+tone, 2)
        end
    end
end)
```

## video24 アンニュイ顔

```lua

local res = Nitro.read_MDL0(0x02168B54, 0)
local meshes = res.addrs_mesh
local num = #meshes
local v16 = MESH_LIB.VTX_16
local vdif = MESH_LIB.VTX_DIFF

for _, mesh in pairs(pick(meshes, {
range(1, 3)
})) do
Nitro.filter_mesh(mesh.begin, mesh.iend, function(addr, info)
    if info.name == MESH_COMMANDS.VTX_16 then
        assert(addr%2==0)
        local pos = v16.read(addr)
        pos.x = pos.x /2-0
        pos.z=pos.z
        pos.y=pos.y+0.5
        -- pos.z = pos.z+0.1
        -- pos.x = pos.x + 1
        v16.write(addr, pos)
    elseif info.name == MESH_COMMANDS.VTX_DIFF then
        local pos = vdif.read(addr)
        pos.x = pos.x + 0.005
        -- vdif.write(addr, pos)
    end
end)
end
for _, mesh in pairs(pick(meshes, {
range(11, 11),
range(13, 13),
})) do
Nitro.filter_mesh(mesh.begin, mesh.iend, function(addr, info)
    if info.name == MESH_COMMANDS.VTX_16 then
        assert(addr%2==0)
        local pos = v16.read(addr)
        pos.x = pos.x - 0.1
        -- pos.z = pos.z+0.1
        -- pos.x = pos.x + 1
        v16.write(addr, pos)
    elseif info.name == MESH_COMMANDS.VTX_DIFF then
        local pos = vdif.read(addr)
        pos.x = pos.x - 0.01
        vdif.write(addr, pos)
    end
end)
end
w32(0x0296E4E8, 0)
w32(0x0296E528, 0)

w32(0x0296E5C0, 0x06b0)
w32(0x0296E5A8, 0x06b0)
-- w32(0x0296E5C0, 0x0a20)
-- w32(0x0296E5A8, 0x0a20)

-- 激チカ
w32(0x0296E4BC, 0x0a00)
w32(0x0296E4C0, 0xffffe800)

-- メガネを消す
w32(0x0296E5D8, 0x9000) -- 568で鼻に設置(これはボツにした)

local update_time = (function()
    return function()
        w16(0x02129050, 0)
        w16(0x02128768, 0)
w16(0x216E468, 1) -- 瞬きをさせない
    end
end)()
SET_LOOP("update_time", update_time)


lib.irume.start(function()
    local head = 0x03EC8A00
    local as = {}
    local prev = {}
    local ps = {}
    local tone = 0xe
    for i = 0, 18 do
        as[i] = head + 0x40 * i
        prev[i] = 0
        ps[i] = 0x200
    end
    local _t = 0x2c
    local p1 = 0x1f
    local p2 = 0x18
    local vol = 0x16
    local r = RC(90)
    return function()
        for i, a in pairs(as) do
            w16(a+vol, 0x80)
            ps[i] = (ps[i] - 0x4) % 0x300
            w16(a+p2, ps[i]-0x300)
            w8(a+tone, 2)
        end
    end
end)
```

## video24 髪の毛を上下に & 従来のゆがませ

```lua

local function GO()
local res = Nitro.read_MDL0(0x02168B54, 0)
local meshes = res.addrs_mesh
local num = #meshes
local f = FixFloatConverter(3, 12)

local hair = {}

for _, mesh in pairs(pick(meshes, {
range(3, 3)
})) do
local B = Nitro.Bound3D()
Nitro.filter_mesh(mesh.begin, mesh.iend, function(addr, info)
    if info.name == MESH_COMMANDS.VTX_16 then
        assert(addr%2==0)
        local d = addr - mesh.begin
        if within(d, 0xd0, 0xdf) then
            return
        end
        if within(d, 0x2d0, 0x2df) then
            return
        end
        if within(d, 0x690, 0x69f) then
            return
        end
        if within(d, 0xcd0, 0xcdf) then
            return
        end
        -- if addr - mesh.begin < 0x080 then
        --     return
        -- end
        -- if addr - mesh.begin < 0xd00 then
        hair[addr] = r16(addr)
    end
end)
end
local v = ValueUpdater(40, 0, 0x40, "pingpong")
-- 0.1

local res = Nitro.read_JNT0(0x0216E434, 0)
local vs = {}
for _, a in pairs(res.addrs_tr) do
    vs[a] = r32(a)
end

-- 激チカ
local rl = RL(500)
local hair_d = 0
local hair_drc = Cnt(40)
local hair_dr = RC(60)

local face_c = Cnt(8)
local face_cr = RC(5)
SET_LOOP("main", function()
    v()
    local d = v.v / 0x100 - hair_d
    for a, _v in pairs(hair) do
        w16(a, f:toi(f:tof(_v) + d))
    end

    if not rl() then return end
    if hair_dr() or hair_drc() then
        hair_drc.i = 0
        hair_d = rand(-2, 6)/10
    end

    if face_c() then
        if face_cr() then
            face_c:N(rand(7, 9))
        end
    for a, v in pairs(vs) do
        w32(a, v+rand(-0x80, 0x80))
    end
    end
w32(0x0296E4BC, 0x0a00)
w32(0x0296E4C0, 0xffffe800)

        w16(0x02129050, 0)
        w16(0x02128768, 0)
w16(0x216E468, 1) -- 瞬きをさせない
end)

w32(0x04000350, 0xffffffff) -- 上画面の背景を消す
end

local r = CntOnce(210)
local time = 0
function loop()
    if r() then
        print("GO!!")
        GO()
    end
    time = time + 1
    CLS()
    printf("time: %f", time/60)
end

lib.irume.start(function()
    local head = 0x03EC8A00
    local as = {}
    local prev = {}
    local ps = {}
    local tone = 0xe
    for i = 0, 18 do
        as[i] = head + 0x40 * i
        prev[i] = 0
        ps[i] = 0x200
    end
    local _t = 0x2c
    local p1 = 0x1f
    local p2 = 0x18
    local vol = 0x16
    local r = RC(90)
    local ctone = 0x18
    local ctone_r = RC(120)
    local tones = {
0x0, 0x2, 0x4, 0x5, 0x7, 0xb, 0xc, 0xd, 0xe, 0xf, 0x10, 0x11, 0x12, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19,
    }
    local rl = RL(600)
    return function()
        if rl() and ctone_r() then
            ctone = tones[rand(1, #tones)]
        end
        for i, a in pairs(as) do
            w8(a+tone, ctone)
        end
    end
end)
```

## video25 メッシュ回転

```lua
local res = Nitro.read_MDL0(0x02168B54, 0)
local meshes = res.addrs_mesh
local num = #meshes
local v16 = MESH_LIB.VTX_16
local f16 = FixFloatConverter(3, 12)
local vdif = MESH_LIB.VTX_DIFF
-- 3, x: 縦, y: 奥行, z: 横
-- 4, x: 奥行, y: 縦, z: 横
-- 5, x: 縦, y: 奥行, z: 横
-- 6, x: 縦, y: 奥行, z: 横
-- 7, x: 奥行, y: 縦, z: 横
-- 8, x: 奥行, y: 縦, z: 横
-- 9, x: 奥行, y: 縦, z: 横
-- 10, x: 奥行, y: 縦, z: 横
-- 11, x: 奥行, y: 横, z: 縦
-- 12, x: 縦, y: 奥行, z: 横
local types = {
1,2,1,1,2,2,2,2,2,1
}
local updaters = {}

for i, mesh in pairs(pick(meshes, {
range(3, 12)
})) do
local B = Nitro.Bound3D()
local poses = {}

Nitro.filter_mesh(mesh.begin, mesh.iend, function(addr, info)
    if info.name == MESH_COMMANDS.VTX_16 then
        assert(addr%2==0)
        local pos = v16.read(addr)
        B:push(pos.x, pos.y, pos.z)
        if assert(types[i]) == 1 then
            table.insert(poses, {
                x = {addr+0, pos.x},
                y = {addr+4, pos.z},
            })
        else
            table.insert(poses, {
                x = {addr+4, pos.z},
                y = {addr+2, pos.y},
            })
        end
    end
end)
local _update
if assert(types[i]) == 1 then
_update = function(sin, cos)
    for _, p in pairs(poses) do
        local x = B:xinv(p.x[2]) - 0.5
        local y = B:zinv(p.y[2]) - 0.5
        local _x, _y
        _x = x*sin + y*cos
        _y = x*cos - y*sin
        w16(p.x[1], f16:toi(B:xlerp(_x+0.5)))
        w16(p.y[1], f16:toi(B:zlerp(_y+0.5)))
    end
end
else
_update = function(sin, cos)
    for _, p in pairs(poses) do
        local x = B:zinv(p.x[2]) - 0.5
        local y = B:yinv(p.y[2]) - 0.5
        local _x, _y
        _x = x*sin + y*cos
        _y = x*cos - y*sin
        w16(p.x[1], f16:toi(B:zlerp(_x+0.5)))
        w16(p.y[1], f16:toi(B:ylerp(_y+0.5)))
    end
end
end

table.insert(updaters, _update)

end

local c = Cnt(60)
local r = RC(3)

function loop()
    if c() and r() then
        c:N(math.max(round(c.n*0.9), 8))
    end
    local x = c.i*2*math.pi/c.n
    local sin = math.sin(x)
    local cos = math.cos(x)
    for _, f in pairs(updaters) do f(sin, cos) end
end


lib.irume.start(function()
    local head = 0x03EC8A00
    local as = {}
    local ps = {}
    for i = 0, 18 do
        as[i] = head + 0x40 * i
        ps[i] = 0
    end
    local _t = 0x2c
    local p1 = 0x1f
    local p2 = 0x18
    local vol = 0x16
    local m = lib.at(head)
    return function()
        for i, a in pairs(as) do
            m:with(a+_t):Tadd8(1, -1)
            ps[i] = (ps[i]+4)%0x80
            w16(a+p2, ps[i]-0x40)
        end
    end
end)

```

## video25 もちもち その1

```lua

local res = Nitro.read_MDL0(0x02168B54, 0)
local meshes = res.addrs_mesh
local num = #meshes
local v16 = MESH_LIB.VTX_16
local f16 = FixFloatConverter(3, 12)
local vdif = MESH_LIB.VTX_DIFF
-- 3, x: 縦, y: 奥行, z: 横
-- 4, x: 奥行, y: 縦, z: 横
-- 5, x: 縦, y: 奥行, z: 横
-- 6, x: 縦, y: 奥行, z: 横
-- 7, x: 奥行, y: 縦, z: 横
-- 8, x: 奥行, y: 縦, z: 横
-- 9, x: 奥行, y: 縦, z: 横
-- 10, x: 奥行, y: 縦, z: 横
-- 11, x: 奥行, y: 横, z: 縦
-- 12, x: 縦, y: 奥行, z: 横
local types = {
1,2,1,1,2,2,2,2,2,1
}
local updaters = {}

for i, mesh in pairs(pick(meshes, {
range(3, 12)
})) do
local B = Nitro.Bound3D()
local poses = {}

Nitro.filter_mesh(mesh.begin, mesh.iend, function(addr, info)
    if info.name == MESH_COMMANDS.VTX_16 then
        assert(addr%2==0)
        local pos = v16.read(addr)
        B:push(pos.x, pos.y, pos.z)
        if assert(types[i]) == 1 then
            table.insert(poses, {
                x = {addr+0, pos.x},
                y = {addr+4, pos.z},
            })
        else
            table.insert(poses, {
                x = {addr+4, pos.z},
                y = {addr+2, pos.y},
            })
        end
    end
end)
local _update
if assert(types[i]) == 1 then
_update = function(sin, cos)
    for _, p in pairs(poses) do
        local y = p.y[2]
        local _y = y*(1+sin)
        -- w16(p.y[1], f16:toi(B:zlerp(_y+0.5)))
        w16(p.y[1], f16:toi(_y))
        local x = p.x[2]
        local _x = x*(1+cos)
        w16(p.x[1], f16:toi(_x))
    end
end
else
_update = function(sin, cos)
    for _, p in pairs(poses) do
        local x = p.x[2]
        local _x = x*(1+cos)
        w16(p.x[1], f16:toi(_x))
        local y = p.y[2]
        local _y = y*(1+sin)
        -- w16(p.y[1], f16:toi(B:ylerp(_y+0.5)))
        w16(p.y[1], f16:toi(_y))
    end
end
end

table.insert(updaters, _update)

end

local c = Cnt(60)
local r = RC(3)

function loop()
    if c() and r() then
        c:N(math.max(round(c.n*0.9), 8))
    end
    local x = c.i*2*math.pi/c.n
    local sin = math.sin(x)
    local cos = math.cos(x)
    for _, f in pairs(updaters) do f(sin, cos) end
end


lib.irume.start(function()
    local head = 0x03EC8A00
    local as = {}
    local ps = {}
    for i = 0, 18 do
        as[i] = head + 0x40 * i
        ps[i] = 0
    end
    local _t = 0x2c
    local p1 = 0x1f
    local p2 = 0x18
    local vol = 0x16
    local m = lib.at(head)

    local c = Cnt(180)
    local r = RC(3)
    local cc = Cnt(6)
    return function()
        if c() and r() then
            c:N(math.max(round(c.n*0.9), 8))
        end
        cc()
        local x = c.i*2*math.pi/c.n
        local sin = round(math.sin(x) * 4)
        for i, a in pairs(as) do
            if sin >= 1 then
                if cc.i <= sin then
                m:with(a+_t):Tadd8(1, 1)
                end
            else
                m:with(a+_t):Tadd8(1, sin)
            end
            ps[i] = (ps[i]+4)%0x80
            w16(a+p2, ps[i]-0x40)
        end
    end
end)

```

## video25 でっぷり

```lua

local res = Nitro.read_MDL0(0x02168B54, 0)
local meshes = res.addrs_mesh
local num = #meshes
local v16 = MESH_LIB.VTX_16
local f16 = FixFloatConverter(3, 12)
local vdif = MESH_LIB.VTX_DIFF
-- 3, x: 縦, y: 奥行, z: 横
-- 4, x: 奥行, y: 縦, z: 横
-- 5, x: 縦, y: 奥行, z: 横
-- 6, x: 縦, y: 奥行, z: 横
-- 7, x: 奥行, y: 縦, z: 横
-- 8, x: 奥行, y: 縦, z: 横
-- 9, x: 奥行, y: 縦, z: 横
-- 10, x: 奥行, y: 縦, z: 横
-- 11, x: 奥行, y: 横, z: 縦
-- 12, x: 縦, y: 奥行, z: 横
local types = {
1,2,1,1,2,2,2,2,2,1
}
local updaters = {}

for i, mesh in pairs(pick(meshes, {
range(3, 12)
})) do
local B = Nitro.Bound3D()
local poses = {}

Nitro.filter_mesh(mesh.begin, mesh.iend, function(addr, info)
    if info.name == MESH_COMMANDS.VTX_16 then
        assert(addr%2==0)
        local pos = v16.read(addr)
        B:push(pos.x, pos.y, pos.z)
        if assert(types[i]) == 1 then
            table.insert(poses, {
                x = {addr+0, pos.x},
                y = {addr+4, pos.z},
            })
        else
            table.insert(poses, {
                x = {addr+4, pos.z},
                y = {addr+2, pos.y},
            })
        end
    end
end)
local _update
if assert(types[i]) == 1 then
_update = function(sin, cos)
    for _, p in pairs(poses) do
        local y = p.y[2]
        local _y = y*2
        -- w16(p.y[1], f16:toi(B:zlerp(_y+0.5)))
        w16(p.y[1], f16:toi(_y))
        -- local x = p.x[2]
        -- local _x = x*2
        -- w16(p.x[1], f16:toi(_x))
    end
end
else
_update = function(sin, cos)
    for _, p in pairs(poses) do
        local x = p.x[2]
        local _x = x*2
        w16(p.x[1], f16:toi(_x))
        -- local y = p.y[2]
        -- local _y = y*(1+sin)
        -- -- w16(p.y[1], f16:toi(B:ylerp(_y+0.5)))
        -- w16(p.y[1], f16:toi(_y))
    end
end
end

table.insert(updaters, _update)

end

local c = Cnt(60)
local r = RC(3)

function loop()
    if c() and r() then
        c:N(math.max(round(c.n*0.9), 8))
    end
    local x = c.i*2*math.pi/c.n
    local sin = math.sin(x)
    local cos = math.cos(x)
    for _, f in pairs(updaters) do f(sin, cos) end
end


lib.irume.start(function()
    local head = 0x03EC8A00
    local as = {}
    local ps = {}
    for i = 0, 18 do
        as[i] = head + 0x40 * i
        ps[i] = 0
    end
    local _t = 0x2c
    local p1 = 0x1f
    local p2 = 0x18
    local vol = 0x16
    local m = lib.at(head)

    local c = Cnt(180)
    local r = RC(3)
    local cc = Cnt(6)
    return function()
        if c() and r() then
            c:N(math.max(round(c.n*0.9), 8))
        end
        cc()
        local x = c.i*2*math.pi/c.n
        local sin = round(math.sin(x)*2)+2
        for i, a in pairs(as) do
            if sin >= 1 then
                if cc.i <= sin then
                m:with(a+_t):Tadd8(1, 1)
                end
            else
                m:with(a+_t):Tadd8(1, sin)
            end
            ps[i] = (ps[i]+4)%0x80
            w16(a+p2, ps[i]-0x240)
        end
    end
end)
```

