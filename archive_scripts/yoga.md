
# どこでもヨガ


## video9のバグ(完全呼吸法の連呼、ほか)

```lua
-- ボイス
-- 0x02131220, 0x02131A1F (0x800)

-- 0x02223910の値を大きくすると、ボイスを少しすっ飛ばせる
-- (終わり: 197E、ただし、終了タイマーは別っぽい)

CLS()

local update_voice = (function()
    local c = RC(40)
    local playing = false
    local i = 0

    local c2 = RC(60)
    local m = lib.at(0x02223910)

    local go = function()
        return DS.key.get("Select")
        -- return c()
    end
    local stop = function()
        return not DS.key.get("Select")
    end
    local rl = RL(420)
    local active = false

    return function()
        if not rl() then return end
        if not active then
            active = true
            print("Voice Active")
        end
        if c2() and (not DS.key.get("Left")) then
            m:add32(0x80)
        end
        if (not playing) and go() then
            playing = true
            i = 0
        end
        if not playing then return end
        i = i + 1
        local d = DATA_kanzenn[i]
        if stop() then playing = false
        elseif d then lib.warr(0x02131220, DATA_kanzenn[i])
        else playing = false
        end
    end
end)()

local update_polygons = (function()
    local vs8 = {
        {0x02A9CF27, RC(30), {0x22, 0x23, 0x10, 0x33, 0x50, 0x60, 0x70}},
        {0x02A9CED9, RC(20), {0x22, 0x11, 0x60}},
        {0x02AB2070, RC(20), {0x22, 0x11}},
    }
    local vs32 = {
        {0x02A9C674, RC(50), {0x23212223, 0x11111111}},
    }
    local r = Cnt(400)
    local rl = RL(500)
    return function()
        if not rl() then
            w8(0x02A9CF27, 0x10)
            w8(0x02A9CED9, 0x11)
            return
        end
        for _, v in pairs(vs8) do
            if v[2]() then
                w8(v[1], v[3][rand(1, #v[3])])
            end
        end
        for _, v in pairs(vs32) do
            if v[2]() then
                w32(v[1], v[3][rand(1, #v[3])])
            end
        end
        if r() then
            print("POLYGON SPPEDUP")
            for _, v in pairs(vs8) do v[2]:N(math.max(v[2].n - 10), 5) end
            for _, v in pairs(vs32) do v[2]:N(math.max(v[2].n - 10), 5) end
        end
    end
end)()

local update_image = (function()
    local head1 = 0x0640e540
    local head2 = 0x06412d40
    local bound = 0x4780

    local vs1 = {}
    local vs2 = {}
    for i = 0, bound-1, 4 do
        vs1[i] = r32(head1 + i)
        vs2[i] = r32(head2 + i)
    end
    local vs = {vs1, vs2}

    local c = Cnt(2, 2)
    local rl = CntOnce(240)
    rl.active = false

    local mode = 1
    local mode_r = RC(10)
    local function filter(v)
        if mode == 1 then return v
        elseif mode == 2 then return v | 0x33333333
        elseif mode == 3 then return v | 0x77777777
        elseif mode == 4 then return v & 0x77777777
        elseif mode == 5 then return v & 0x99999999
        elseif mode == 6 then return v ~ 0xffffffff
        elseif mode == 7 then return v | 0xf0f0f0f0
        elseif mode == 8 then return v ~ 0xc0c0c0c0
        else return v
        end
    end

    local color_active = false

    local imode = 0
    local imode_r = RC(10)
    local imode_rl = RL(90)
    imode_rl.active = false
    local imode_d = 0x200

    return function()
        if (not color_active) and DS.key.get("L") then
            print("COLOR ACTIVE")
            color_active = true
            rl.active = true
            imode_rl.active = true
        end
        if color_active and mode_r() then
            mode = rand(1, 8)
        end
        if imode_rl() and imode_r() then
            imode = (imode + 1) % 2
            imode_d = 0x100 * rand(-0x20, 0x20)
        end
        local j = c:next()
        for i = 0, bound-1, 4 do
            local _j = j + 1
            if imode == 1 and i >= (bound >> 1) + imode_d then
                _j = (_j % 2) + 1
            end
            w32(head1 + i, filter(vs[_j][i]))
            w32(head2 + i, filter(vs[_j][i]))
        end
        if rl() then
            print("IMAGE SPEEDUP")
            c.n0 = 1
            c.i0 = 0
        end
    end
end)()

function loop()
    update_voice()
    update_polygons()
    update_image()
end
```


- モデル高さ: 0x02248438
- モデル厚さ: 0x0224843C
- モデル太さ: 0x022484B0
- モデル色: 0x0224844A (2byte)
    - 4AがR値, 4Bの先頭4byteがB, 後半4byteがG
- モデル回転:
    - 224842C (2byte LE signed)
    - 2248428 (2byte LE signed)
    - 2248424 (2byte LE signed)
- モデル位置:
    - x: 2248414 (4byte LE signed)
    - y: 2248418 (4byte LE signed)
    - z: 224841C (4byte LE signed)

```
もしかしたら22484DCや84E0, 8524も何かあるかも

-- マットの位置がずれる
-- 0x020E2418,
-- 0x020E241C,
-- 0x020E2420,
-- 0x020E2424,
```


## video9の英雄のおしりさんバグ

```lua
CLS()

local update_voice = (function()
    local c = RC(40)
    local playing = false
    local i = 0

    local c2 = RC(60)
    local m = lib.at(0x02223910)

    local go = function()
        local select = DS.key.get("Select")
        local a = DS.key.get("A")
        local b = DS.key.get("B")
        if a then
            return 2 -- siri
        elseif b then
            return 1 -- mune
        elseif select then
            return rand(1, 2)
        else return nil
        end
        -- return c()
    end
    local first_oshiri_active = false
    local stop = function()
        return not (
            first_oshiri_active or
            DS.key.get("Select") or
            DS.key.get("A") or
            DS.key.get("B")
        )
    end
    local rl = RL(150)
    local active = false

    local vvvs = {DATA_mune, DATA_oshiri}
    local current = nil

    local first_oshiri_start = CntOnce(36)
    local first_oshiri_end = CntOnce(36 + 25)

    local start_m = lib.at(0x020e1890)
    local started = false

    return function()
        if not started then
            if start_m:r8() ~= 0 then
                print("STARTED")
                started = true
            else return
            end
        end
        if rl() and (not active) then
            active = true
            print("Voice Active")
        end
        if rl.fired and c2() and (not DS.key.get("Left")) then
            m:add32(0x80)
        end
        if first_oshiri_start() then
            print("OSHIRI START")
            first_oshiri_active = true
            playing = true
            current = vvvs[2]
            i = 0
        end
        if (not playing) then
            local _go = go()
            if _go then
                playing = true
                current = vvvs[_go]
                i = 0
            end
        end
        if first_oshiri_end() then
            print("OSHIRI END")
            first_oshiri_active = false
            playing = false
        end
        if not playing then return end
        i = i + 1
        local d = current[i]
        if stop() then playing = false
        elseif d then lib.warr(0x02131220, d)
        else playing = false
        end
    end
end)()



local m = lib.at(0x02248418)

local i = 0
local span = 20
local max = 0x2000

local m2 = lib.at(0x0224842c)
local v2 = 0
local rl2 = RL(240)

local m3 = lib.at(0x02248428)
local v3 = 0
local rl3 = RL(240)

function loop()
    update_voice()
    i = (i + 1) % span
    local x = i * 2 / span - 1
    m:w32(stou32(math.round(max * (1 - x*x))))
    v3 = (v3 + 0x400) % 0x10000
    m3:w16(v3)

    -- if rl2() then
        -- v2 = (v2 + 0x300) % 0x10000
        -- m2:w16(v2)

    -- end
end


lib.irume.start(function()
    local prev = {}
    return function()
        for i = 0x03e18bc0, 0x03e18e6f do
            local v = r8(i)
            if (not prev[i]) then
                prev[i] = {v = v, c = 0}
            else
                if prev[i].v ~= v then
                    prev[i].c = prev[i].c + 1
                    if prev[i].c >= 10 then
                        prev[i].c = 0
                        v = v - 0x20
                        w8(i, v)
                        for j = 1, 10 do
                            w8(i+j, rand(0, 0xff))
                        end
                    end
                    prev[i].v = v
                else
                    prev[i] = nil
                end
            end
        end
    end
end)

```

## video9のろくろ回し&バネのように伸び縮み

```lua
-- 太さ: 0400 -- 2000 (bound 0x1000)

CLS()

local norm = 0x2000
local v = norm
local a = 0x022484B0
local min = 0x0400
local max = 0x8000
local d = 0x20
local coeff = 1000
local back_v = 0

local speed = 0.05

local m = lib.at(0x02248428)

function loop()
    if DS.key.get("L") then
        speed = lerp(speed, 0.1, 0.1)
    else
        speed = lerp(speed, 0.05, 0.1)
    end
    if DS.key.get("A") then
        v = ilerp(v, min, speed)
        back_v = 0
    elseif DS.key.get("B") then
        v = ilerp(v, max, speed)
        back_v = 0
    else
        back_v = back_v * 0.9 - math.log(v / norm, 10) * coeff
        v = v + back_v
    end
    if v < 0 then
        print("V ZERO!!")
        v = 10
    end
    w32(a, math.round(v))
    w32(0x02248438, math.round(v))
    m:add16(0x1800)
end
print("OK")
```

## video12 ブルブル震える

```lua
local function found(v)
    local v1 = (v >> 0) & 0xff
    local v2 = (v >> 8) & 0xff
    local v3 = (v >> 16) & 0xff
    local v4 = (v >> 24) & 0xff
    return (
        v1 == 0x38
    ) and (
        v2 == 0x3A or v2 == 0x3B
    ) and (
        v3 == 0
    ) and within(v4, 1, 0x20)
    -- ) and within(v4, 1, 2)
end

---@type {addr: int, i: int, n: int, scale: int, live: bool}[]
local addrs = {}

local function get_n()
    return rand(2, 20)
end
local function scale()
    return rand(-0x40, 0x40) * 0x4
end

local function main(begin, inclusiveEnd)
    local i = begin
    while i <= inclusiveEnd do
        local v = r32(i)
        i = i + 4
        if found(v) then
            for j = 1, 3 do
                if not addrs[i] then
                    local n = get_n()
                    addrs[i] = {
                        addr = i,
                        n = n,
                        i = rand(0, n-1),
                        scale = scale(),
                        live = true,
                    }
                else
                    addrs[i].live = true
                end
                -- add32(i, rand(-4, 4) * 0x100)
                -- add32(i, rand(4, 4) * 0x1000)
                i = i + 4
            end
        end
    end
end
function update_value()
    for _, v in pairs(addrs) do
        if v.live then
            v.i = (v.i + 1) % v.n
            if v.i == 0 and rand(1, 2) == 1 then
                v.n = get_n()
                v.scale = scale()
            end
            local d = math.icos(v.i / v.n, v.scale)
            add32(v.addr, d)
            v.live = false
        end
    end
end
-- 2292030
-- 228E000

local update_voice = (function()
    local head = 0x02131220
    local width = 0x800
    local cnt = 0
    local vvs = {}
    ---@param scl number
    return function(scl)
        local vs = {}
        if r16(head) ~= 0 or r16(head+2) ~= 0 then
            for i = 0, width-1, 2 do
                vvs[#vvs+1] = r16(head+i)
            end
            cnt = cnt + 1
        end
        for i = 0, width-1, 2 do
            local _i = (cnt-1)*(width//2) + math.round((i//2) * scl)
            vs[head+i] = vvs[_i] or 0
        end
        for a, v in pairs(vs) do
            w16(a, v)
        end
    end
end)()

local max_scale = 0.75
local min_scale = 0.5
local c = Cnt(20)

local function get_scale2()
    return (math.sin(c:next() * 2 * math.pi / c.n) + 1.0) * (max_scale - min_scale) + min_scale
end

function loop()
    main(0x02310000, 0x02313FFF)
    -- main(0x02313000, 0x02313fff)
    -- main(0x02313000, 0x02313fff)
    update_value()
    update_voice(get_scale2())
end
```

## video12 手を上げ続ける & 途中で揺れたりジャンプしたり

```lua
---@param obj ValueUpdaterObj
local function calc(obj)
    return obj:isin()
end

local d = 0x1800
local vs = {
ValueUpdater(60, -0x1000+d, 0x1000+d, calc)
:w32(0x02313AA4),
ValueUpdater(60, -0x1000, 0x1000, calc)
:w32(0x02313AB4),
-- ValueUpdater(60, -0x4000, 0x4000, calc)
-- :w32(0x02313B14),
}

local m = lib.at(0x02310D56)

local mc = Cnt(30)

local v = ValueUpdater(45, -0x1000, 0x1000, calc)
:w16(0x0224842c)

local r = RL(440)

local update_voice = (function()
    local head = 0x02131220
    local width = 0x800
    ---@param scale number
    return function(scale)
        local vs = {}
        for i = 0, width-1, 2 do
            local _i = head + (math.round(i * scale) % width)
            vs[head + i] = r16(_i)
            -- w16(head + i, r16(_i))
        end
        for a, v in pairs(vs) do
            w16(a, v)
        end
    end
end)()

local max_scale = 1.1
local min_scale = 1.0
local c = Cnt(20)

local function get_scale()
    return min_scale + c:next() * (max_scale - min_scale) / c.n
end
local function get_scale2()
    return (math.sin(c:next() * 2 * math.pi / c.n) + 1.0) * (max_scale - min_scale) + min_scale
end

local y_v_r = RL(990)
local y_v = ValueUpdater(27, 0, 0x2000)
:calc(function(obj)
    local x = 2*obj:x() - 1
    return obj:lerp(clamp(1 - x*x, 0, 1))
end)
:w32(0x02248418)

local ready = true
local ready_m = lib.at(0x0224845E)

function loop()
    if not ready then
        if ready_m:r8() == 0x8 then
            ready = true
        end
        return
    end
    -- for _, v in pairs(vs) do v() end
    if mc() then m:w8(3) end
    w8(0x02313AAc, 0x11)
    add16(0x02248428, 0x80)
    -- if r() then v() end
    update_voice(0.8)
    if y_v_r() then y_v()
    elseif r() then v()
    end
end

-- 2313AA4
-- 2313B14
```
