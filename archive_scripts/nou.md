
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
