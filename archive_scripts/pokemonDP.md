
# ポケモン パール

```lua
-- コンテストでこんこんズの3体が乱入したらのネタ
local create_update = function(base, orig_heart_num, is_korink)
    local started = false
    local first_heart_end = false
    local rl = RL(180)
    local kor_cooltime = RL(1) -- 1ならハート0
    return function()
        if not started then
            if r8(base+4) == orig_heart_num then
                started = true
                print("STARTED")
            else return
            end
        end
        if first_heart_end then
            if is_korink and kor_cooltime() then w8(base+1, 1)
            elseif rl() then w8(base+1, 0)
            end
        else
            if r8(base+1) == 0 then
                first_heart_end = true
                print("FIRST HEART END")
            end
        end
        w8(base+2, 0x50)
        w8(base+3, 0x1)
        w8(base+4, 0x50)
    end
end

-- local mohu_update = create_update(0x022D7070, 8)
-- local marou_update = create_update(0x022D70F0, 7)
local taruo_update = create_update(0x022D7070, 3, true)

-- モフリアス,たるおstate
-- 風車 22C17BC, 18C0, 19C4, 1AC8, 1BCC, 1CD0
-- 風車1のx,y座標は22C1798, 179C
-- まろうこんstate
-- 風車 22C183C, 1940, 1A44, 1B48, 1C4C, 1D50

-- まろうこんのstateで試したときのメモ
-- 22B4437: ハートの個数
-- 22B4436を05にするとけっこうハートが得られる(NPC用のプリセットを呼び出してる?)
-- 22D7046 -> 赤とピンクの合計 (ハートが現れる度にその直後のアドレス(7047)が1ずつ大きくなっていくのが目印)
-- 22D7048 -> 赤の個数

function loop()
    taruo_update()
end
```

```lua
-- まろうこん用グラ壊し
local function pos(x, y)
    return lib.pos.Morton(x, y, 4, 0x20, 0x40) + 0x06600000
end

local color_map = {
[0x3] = 0xc, -- フチ
[0x4] = 0xd, -- body => d
[0x6] = 0xc, -- テカリ
[0x7] = 0xb, -- テカリ外
}

lib.image.filterObj_HalfByte()
:width(16):height(16):addr(pos):save()
:reverse()
:go(function(x, y, vs)
    if vs[y][x] == 0 then return end
    return assert(color_map[vs[y][x]])
end)


-- 下画面
-- 6200000～6201fffまでは
-- Morton(4, 0x20, 0x400)
-- 6202000から
-- Morton(4, 0x20, 0x400)
-- 縦に8block

-- 1block: 8x8 横に32block

local function pos(x, y)
    if y < 64 then
        return lib.pos.Morton(x, y, 4, 0x20, 0x400) + 0x06200000
    end
    y = y - 64
    return  lib.pos.Morton(x, y, 4, 0x20, 0x400) + 0x06202000
end

lib.image.filterObj()
:width(256):height(128)
:go(function(x, y)
    return pos(x, y), r8(pos(x, y)) ~ 0xff
end)

lib.fill_in(0x06000000, 0x060fffff)


-- 赤い花にする
for i = 0x06400000, 0x064003ff, 4 do
    local v = r32(i)
    local _v = 0
    for j = 0, 7 do
        local a = (v >> (j*4)) & 0xf
        _v = _v | ((a == 0 and 0 or 3) << (j*4))
    end
    w32(i, _v)
end
```

```lua
-- たるお用花カッターなどの動き

local addrs = {
0x22C17BC,
0x22C18C0,
0x22C19C4,
0x22C1AC8,
0x22C1BCC,
0x22C1CD0,
}
---@param x number `[0, 1]`
---@return number
local function ease_in_out(x)
    if x < 0.5 then
        x = x * x
        x = x * x
        return math.clamp(8 * x, 0, 1.0)
    end
    x = -2 * x + 2
    x = x * x
    x = x * x
    return math.clamp(1 - x / 2, 0, 1.0)
end
local poses = {
    {0x68000, 0x43000, -1, -1},
    {0x90000, 0x45000, 1, -1},
    {0x63000, 0x58000, -2, 0},
    {0x98000, 0x58000, 2, 0},
    {0x70000, 0x68000, -1, 1},
    {0x90000, 0x68000, 1, 1},
}

local vs = {}
for i, a in pairs(addrs) do
    local px, py = poses[i][1], poses[i][2]
    local sclx, scly = poses[i][3], poses[i][4]
    local ax, ay = a - 0x24, a - 0x20
    local __v = ValueUpdater(30, 0, 1000, "isin")
    :calc(function(obj)
        if obj.i == 0 and rand(1, 4) == 1 then
            obj.n = rand(20, 60)
        end
        return obj:isin()
    end)
    :with_x(function(obj) return ease_in_out(obj:x_orig()) end)
    :write(function(v)
        local _vx = round(sclx * (v / 1000.0) * 0x18000)
        local _vy = round(scly * (v / 1000.0) * 0x18000)
        w32(ax, px + _vx)
        w32(ay, py + _vy)
    end)
    __v.i = rand(0, 28)
    vs[#vs+1] = __v
end
local ds = {
0x1000,
-0x1000,
0x1000,
-0x1000,
0x1000,
-0x1000,
}
local r = RC(40)

local update_korink_move = (function()
    local v = ValueUpdater(30, -0x1, 0x1, VUO.addrand(-2, 2))
    :init(0)
    :w32(0x04000010)
    return function() v() end
end)()

function loop()
    update_korink_move()
    for _, v in pairs(vs) do v() end
    for i, a in pairs(addrs) do
        if r() then
            while true do
                ds[i] = rand(-0x4, 0x2) * 0x800
                if ds[i] ~= 0 then break end
            end
        end
        add16(a, ds[i])
    end
end
```
