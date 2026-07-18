
# のだめカンタービレ


サウンド: `0x03EB8670`あたり

## 先輩アゴ化

```lua
-- 立ち絵以外のUIを消す
lib.fill_in(0x06440000, 0x06447fff)

for i = 0x06412400, 0x064127ff, 4 do
    w32(i, r32(i - 0x400))
end
for i = 0x06412000, 0x064123ff, 4 do
    w32(i, r32(i - 0x1000))
end

---@param x int
---@param y int
---@param W int
---@param N int
---@param L int
local function pos_Morton(x, y, W, N, L)
    local block_lines = N // W
    local a1, a2 = y // block_lines, y % block_lines
    local b1, b2 = x // W, x % W
    return (
        a1 * L
        + b1 * N
        + a2 * W
        + b2
    )
end

local function change_pos1(x, y)
    return pos_Morton(x, y, 0x08, 0x20, 0x100) + 0x06410c00
end
local function change_pos2(x, y)
    return pos_Morton(x, y, 0x08, 0x20, 0x100) + 0x06411000
end

local function change_pos(x, y)
    if within(y, 0, 15) then return change_pos1(x, y)
    elseif within(y, 16, 31) then return change_pos2(x, y-16)
    else error("out of bound")
    end
end

local orig = {}
for i = 0x06410c00, 0x06411fff do
    orig[i] = r8(i)
end
local vs = {}
for y = 0, 31 do
    for x = 0, 0x3f do
        vs[change_pos(x, y)] = orig[change_pos(x, math.floor(y * 0.5))]
    end
end
for i = 0x06410c00, 0x06410fff, 4 do
    local _v = 0
    for j = 0, 3 do
        _v = _v | ((vs[i+j] or r8(i+j)) << (8*j))
    end
    w32(i, _v)
end
for i = 0x06411000, 0x064113ff, 4 do
    local _v = 0
    for j = 0, 3 do
        _v = _v | ((vs[i+j] or r8(i+j)) << (8*j))
    end
    w32(i, _v)
end

-- lib.fill_in(0x06410c00, 0x06410fff)

--服の位置を調整
for i = 0x06412800, 0x064129ff, 4 do
    w32(i, r32(i - 0x1200))
end
for i = 0x06411c00, 0x06411fff, 4 do
    w32(i, r32(i - 0x0400))
end
for i = 0x06411800, 0x06411bff, 4 do
    w32(i, r32(i - 0x1000))
end
for i = 0x06410800, 0x06410bff, 4 do
    w32(i, 0)
end
for i = 0x06411400, 0x064117ff, 4 do
    w32(i, 0)
end
for i = 0x0640f000, 0x0640f1ff, 4 do
    w32(i, r32(i + 0x200))
end
for i = 0x0640f300, 0x0640f3ff, 4 do
    w32(i, r32(i - 0x100))
end
for i = 0x0640f200, 0x0640f2ff, 4 do
    w32(i, 0)
end
```

タイトル画面のイルーム

```lua
lib.irume.start(function()
    local head = 0x03eb8660
    local as = {}
    for i = 0, 3 do
        as[i] = head + 0x40*i
    end
    local r = RC(30)
    local p1 = 0x13
    local p2 = 0x0c
    local v = 0x0a
    local voice = 0x03EB8766
    local voice_start_m = lib.at(0x03EB8788)
    local voice_start_f = false
    local voice_rl = RL(190)
    return function()
        if voice_start_f then
            voice_rl()
        else
            voice_start_f = voice_start_m:r8() == 0xed
        end
        for _, a in pairs(as) do
            if r() then
                w8(a + p1, stou8(rand(-8, 8)))
            end
            if r() then
                w8(a + p2, rand(0, 0xff))
            end
            if voice_start_f and (not voice_rl.fired) then
                w16(a + v, 0xff90)
            elseif r() then
                w16(a + v, rand(0, 0x40) << 8)
            end
        end
        w16(head + 0x40*4 + v, 0x7FFF)
        w16(voice, 0xfafa)
    end
end)
```

千秋ポリゴン & 奏者ぐっちゃぐちゃ

```lua

local chiaki = (function()
    local addrs = {}
    for i = 0x26810C0, 0x2681110, 0x10 do
        addrs[#addrs+1] = i + 0xf
        addrs[#addrs+1] = i + 0xa
        addrs[#addrs+1] = i + 0x5
        addrs[#addrs+1] = i + 0x0
    end
    addrs[#addrs+1] = 0x26810BB
    addrs[#addrs+1] = 0x26810B7

    local r = RC(20)
    return function()
        for _, a in pairs(addrs) do
            if r() then
                w8(a, rand(1, 0x1f))
            end
        end
    end
end)()

local players1 = (function()
    local r = RC(30)
    local vs = {
        0x60111111,
        0x60333333,
        0x28111111,
        0x28332221,
        0x28313134,
        0x21313134,
        0x45FF3232,
        0x32343222
    }
    return function()
        if r() then
            w32(0x0267B3F4, vs[rand(1, #vs)])
        end
    end
end)()

267F970
2679D70
267A0C0

local players2 = (function()
    local f = false
    local r = RC(30)
    return function()
        if r() then
            f = not f
            local v = f and 0x33333333 or 0x11111111
            w32(0x0267C938, v)
            w32(0x0267C93C, v)
        end
    end
end)()

function loop()
    chiaki()
    players1()
    players2()
end

-- そのときのイルーム
lib.irume.start(function()
    local head = 0x03eb8660
    local as = {}
    local vib = {}
    local vol = {}
    for i = 0, 10 do
        as[i] = head + 0x40*i
        vib[i] = 0
        vol[i] = 0x7f
    end
    local m = lib.at(head)
    local r = RC(90)
    local rl = RL(2000)
    local vol_r = RC(40)
    return function()
        rl()
        for i, a in pairs(as) do
            w8(a + 0x13, stou8(rand(-1, 1)))
            m:with(a + 0x20):Tadd8(1, rand(-4, 4), 1)
            if rl.fired then
                w8(a + 0x13, stou8(rand(-4, 4)))
                w8(a + 0xB, vol[i])
                if vol_r() then
                    vol[i] = rand(1, 0x7f)
                end
                if vib[i] == 0 and r() then
                    vib[i] = rand(30, 90)
                end
                if vib[i] > 0 then
                    vib[i] = vib[i] - 1
                    w8(a + 0x1a, rand(0, 0xff)) -- ビブラート
                else w8(a + 0x1a, 0)
                end
            end
        end
    end
end)


```


## 雑メモ

```plaintext

奏者が消える
(nen)0x02A794FC -- 0x02A797A0 (0xe0)
0x0267C279 -- 0x0267C4AF (0x16)
(nen)0x029E2069 -- 0x029E2534 (0x49)

267C0D0 -> 奏者テクスチャかいめつ
C390 -> 右側が黒い壁になる
B3F4 -> 赤くなったりのびたり


(千秋の色がおかしくなる)
(nen)0x027CD94B -- 0x027CE68F (0x2a)
(nen)0x026C2987 -- 0x026C34D9 (0xb6)
0x02682D31 -- 0x026834B2 (0x2b)

顔
2683870

巨頭
for i = 0x2683870, 0x0268388F, 4 do
    w32(i, 0x11111111)
end
-- or
for i = 0x2683A30, 0x02683A47, 4 do
    w32(i, 0x11111111)
end
-- or
for i = 0x2681A78, 0x02681A8F, 4 do
    w32(i, 0x11111111)
end

w32(0x026810DC, 0x07660500) -- 体が半分に折りたたまれる
```

## ツール

### ボタンでタッチ操作ができるようにする

```lua
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

CLS()

local _i = 0
local c = Cnt(2)
local touching = false

local b_hor = 0
local b_ver = 0

function loop()
    CLS()
    local mouse = input.get()["WMouse L"]
    if mouse then
        local mouse_pos = input.getmouse()
        local _x = math.min(math.max(mouse_pos["X"], 0), 255)
        local _y = math.min(math.max(mouse_pos["Y"], 0) // 2, 191)
        print(string.format("MOUSE OVERRIDE (%d, %d)", _x, _y))
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
        print("A")
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
    if b_ver == 1 then print("UP") _y = do_up(i) _x = cx + rand(-3, 3)
    elseif b_ver == -1 then print("DOWN") _y = do_down(i) _x = cx + rand(-3, 3)
    end
    if b_hor == -1 then print("LEFT") _x = do_left(i)
    elseif b_hor == 1 then print("RIGHT") _x = do_right(i)
    end
    print(string.format("(x, y) = (%d, %d)", _x, _y))
    joypad.set({
        ["Touch"] = true,
    })
    joypad.setanalog({
        ["Touch X"] = _x,
        ["Touch Y"] = _y,
    })
end

```


## video8でおならソングの波形データを取得

```lua
local filepath = "C:/Users/" .. os.getenv("USERNAME") .. "/myworkdir/Bizhawk_cheats/out.txt"

local span = 60

CLS()
print("OUT: ".. filepath)

-- 波形データっぽい場所
-- おならソングの時:
-- 0x0228E228, 0x0228E727 (500)
-- 0x0228E778, 0x0228EC43 (4cc)
-- 0x0228ED74, 0x0228EFF3 (280)
-- 0x0228F28C, 0x0229068B (1400)
-- コンサートのとき
-- 0x02277354, 0x02278753 (1400)

-- おならソングの波形データの場所
local kyoku_broken_head = 0x0228F28C
local kyoku_broken_width = 0x1400

-- コンサートのバックコーラスのアドレスは以下：
-- local kyoku_broken_head = 0x02277354
-- local kyoku_broken_width = 0x1400

local _i = 0
cache = {}

local pitch = 0x80
local recording = false
local finished = false

function loop()
    if finished then return end
    if recording then
        _i = _i + 1
        if not DS.key.get("Select") then
            print("RECORD FINISH")
            finished = true
            local file = io.open(filepath, "w")
            local text = "local DATA = {\n" .. table.concat(cache, "\n") .. "\n}"
            file:write(text)
            file:flush()
            file:close()
        else
            local d = {}
            for i = 0, kyoku_broken_width-1,4 do
                local _v = r32(kyoku_broken_head+i)
                for j = 0, 3 do
                    local __v = (_v >> (j*8)) & 0xff
                    d[i+j+1] = string.format("%02X", __v)
                end
            end
            -- cache[_i] = d
            local s = table.concat(d, "")
            cache[_i] = "lib.htob(\"" .. s .. "\"),"
        end
    elseif DS.key.get("Select") then
        print("RECORD START")
        recording = true
    end
end
```

## video8(スコア急激変更 & ボイスバグ)

```lua
-- のだめ、ボタンで操作
nodame = require "misc/nodame"
nodame.setup_touching(true)

lib.irume.start(function()
    local back_mus1 = (function()
        local a = 0x03EB8E84
        local r = RC(60)
        --3EB8E84を1から2にしたり戻したり
        return function()
            if r() then
                local f = r8(a) == 1
                w8(a, f and 2 or 1)
                r:N(f and 30 or 60)
            end
        end
    end)()
    local back_mus2 = (function()
        local a = 0x03EB8E91
        local r = RC(30)
        return function()
            if r() then
                w8(a, rand(0x12, 0x80))
            end
        end
    end)()

    local head = 0x03eb8660
    local as = {}
    local ps = {}
    for i = 0, 18 do
        as[i] = head + 0x40 * i
        ps[i] = 0
    end
    local voice1 = 0x03eb8960
    local voice2 = 0x03eb8660
    local r = RC(30)
    local v = 0
    local v2 = 0
    local m = lib.at(head)
    local voice2_ready = RL(1200)
    return function()
        back_mus1()
        back_mus2()
        for i, a in pairs(as) do
            if r() then
                ps[i] = stou8(rand(-12, 12))
            end
            w8(a + 0x13, ps[i])
            w8(a + 0x16, rand(0, 0xff))
            m:with(a + 0x20):Tadd8(1, rand(-6, 6), 1)
        end
        if r() then
            v = stou8(rand(-0x10, 0x30))
        end
        if r() then
            v2 = rand(0, 0x30)
        end
        w16(voice1 + 0x06, (v << 8) | v)
        w8(voice1 + 0x1a, v2)
        w8(voice1 + 0x1b, v2)

        if voice2_ready() then
        w16(voice2 + 0x06, (v << 8) | v)
        w8(voice2 + 0x1a, v2)
        w8(voice2 + 0x1b, v2)
        end
    end
end)


local update_score = (function()
    local vs = {
        -- 0,0,0,
        0x700000
    }
    local c = Cnt(10, #vs)
    local cool = 0

    -- スコア変動
    return function()
        if r8(0x0206D228) ~= 0 then
            cool = 10
        end
        if cool > 0 then cool = cool - 1 end
        w32(0x0206D204, cool == 0 and 0x700000 or 0)
    end
end)()

local players1 = (function()
    local r = RC(10)
    local vs = {
        0x60111111,
        0x60333333,
        0x28111111,
        0x28332221,
        0x28313134,
        0x21313134,
        0x45FF3232,
        0x32343222
    }
    return function()
        if r() then
            w32(0x0267B3F4, vs[rand(1, #vs)])
        end
    end
end)()

local players2 = (function()
    local f = false
    local r = RC(10)
    return function()
        if r() then
            f = not f
            local v = f and 0x33333333 or 0x11111111
            w32(0x0267C938, v)
            w32(0x0267C93C, v)
        end
    end
end)()

local players3 = (function()
    local r = RC(10)
    local f = false
    local rf = RC(90)
    local a = 0x267A0C0
    return function()
        if rf() then
            f = not f
            if not f then
                w32(a, 0x06E37840)
            end
        end
        if f then
            w32(a, rand(0, 0xffffffff))
        else
            if r() then
                w32(a, 0x06E37800 | rand(0, 0xff))
            end
        end
    end
end)()

local active = false
local active_r = RC(90)

local chiaki = (function()
    local addrs = {}
    for i = 0x26810C0, 0x2681110, 0x10 do
        addrs[#addrs+1] = i + 0xf
        addrs[#addrs+1] = i + 0xa
        addrs[#addrs+1] = i + 0x5
        addrs[#addrs+1] = i + 0x0
    end
    addrs[#addrs+1] = 0x26810BB
    addrs[#addrs+1] = 0x26810B7

    local r = RC(20)
    return function()
        for _, a in pairs(addrs) do
            if r() then
                w8(a, rand(1, 0x1f))
            end
        end
    end
end)()

local update_voice = (function()
    local rl = RL(1200)
    local r = RC(60)
    local r2 = RC(45)
    local c = Cnt(90)
    local active = false
    local i = 0

    local data = {
        DATA_boo,
        DATA_detaa,
        DATA_onaradamon,
        DATA_hey,
        DATA_genkinidasou,
    }
    local data_n = #data
    local cdata

    local head = 0x02277354
    local bound = 0x1400

    return function()
        if not rl() then return end
        if r() or c() then
            cdata = data[rand(1, data_n)]
            n = #cdata
            c.i = 0
            active = true
            i = 0
        end
        if active then
            i = i + 1
            if i <= n then
                lib.fill_in_arr(head, head + bound - 1, cdata[i])
            else active = false
            end
            active = not r2()
        end
    end
end)()

chiaki_ready = false
function loop()
    if active_r() then active = not active end
    if active then
        players1()
        players2()
    else
        -- 元に戻す
        w32(0x0267B3F4, 0x28222822)
        w32(0x0267C938, 0x26222822)
        w32(0x0267C93C, 0x06c4075a)
    end
    players3()
    if chiaki_ready then
        chiaki()
    end
    update_score()
    update_voice()
end
```

## video8千秋バグver2 ()


## video8 のだめの方のバグ

```lua


-- ※ピアノ&オケバージョン。独奏はまた別のアドレス

-- のだめ顔パカパカ
local pakapaka = (function()
    local i = 0
    return function()
        i = i + 1
        local v = math.floor(math.sin(i * math.pi / 10) * 2)
        w8(0x02684CF0, 0x50 + v)
    end
end)()

local guruguru = (function()
    local p1 = RL(600)
    local p2 = RL(1200)
    local p3 = RL(3000)
    local mode = 0
    local a = 0x02684B88
    local r = RC(90)
    local cnt = 0
    local v = 0
    return function()
        p1() p2() p3()
        if p3.fired then
            if mode ~= 3 then
                print("MODE 3")
                mode = 3
            end
            if cnt > 0 then
                cnt = cnt - 1
                w8(a, v)
            elseif r() then
                cnt = rand(90, 120)
                v = rand(3, 4)
                w8(a, v)
            else
                w8(a, 0x02)
            end
        elseif p2.fired then
            if mode ~= 2 then
                print("MODE 2")
                mode = 2
            end
            w8(a, 0x02)
        elseif p1.fired then
            if mode ~= 1 then
                print("MODE 1")
                mode = 1
            end
            w8(a, 0x04)
        else
            w8(a, 0x03)
        end
    end
end)()

local ashi = (function()
    local a = 0x02684BE2
    local c = Cnt(30, 2)
    local ready = RL(300)
    local ready2 = RL(1200)
    local v = false
    local vr = RC(60)
    return function()
        c()
        if not ready() then return end
        if vr() then v = not v end
        if ready2() then
            w8(a, v and 0x21 or 0x22)
        else
            w8(a, c.i == 0 and 0x21 or 0x22)
        end
    end
end)()

local update_score = (function()
    local vs = {
        -- 0,0,0,
        0x700000
    }
    local c = Cnt(10, #vs)
    local cool = 0
    local rl = RL(1700)

    -- スコア変動
    return function()
        if not rl() then return end
        if r8(0x0206D228) ~= 0 then
            cool = 10
        end
        if cool > 0 then cool = cool - 1 end
        w32(0x0206D204, cool == 0 and 0x700000 or 0)
    end
end)()

function loop()
    update_score()
    pakapaka()
    guruguru()
    ashi()
end


lib.irume.start(function()
    local head = 0x03eb8660
    local as = {}
    local ps = {}
    for i = 0, 18 do
        as[i] = head + 0x40 * i
        ps[i] = 0
    end
    local voice1 = 0x03eb8960
    local voice2 = 0x03eb8660
    local r = RC(30)
    local rp = RC(10)
    local v = 0
    local v2 = 0
    local m = lib.at(head)
    return function()
        for i, a in pairs(as) do
            if rp() then
                ps[i] = stou8(rand(-12, 12))
            end
            w8(a + 0x13, ps[i])
            w8(a + 0x16, rand(0, 0xff))
            m:with(a + 0x20):Tadd8(1, rand(-6, 6), 1)
        end
        if r() then
            if rand(1, 2) == 1 then
                v = stou8(rand(-0xc, -0x1))
            else
                v = stou8(rand(-0xc, 0x20))
            end
        end
        if r() then
            v2 = rand(0, 0x10)
        end
        w16(voice1 + 0x06, (v << 8) | v)
        w8(voice1 + 0x1a, v2)
        w8(voice1 + 0x1b, v2)

        w16(voice2 + 0x06, (v << 8) | v)
        w8(voice2 + 0x19, rand(0, 0xff))
        w8(voice2 + 0x1a, v2)
        w8(voice2 + 0x1b, v2)
    end
end)
```


## Arm7領域で波形っぽいデータの場所を探そうとした処理(失敗。)

※見つからなかった。多分そういうデータ自体がないものと思われる。

```lua

addrs = {}
local c = Cnt(30)

local _NUM = 8

local function setup()
    for i = 0x03000000, 0x03ffffff, 4 do
        addrs[i] = r32(i)
    end
end
setup()

local function check(a)
    local vs = {}
    for i = 1, _NUM do
        local _a = a+(i-1)*4
        if addrs[_a] == nil then
            return false
        end
        local v = r32(_a)
        if addrs[_a] == v then
            return false
        end
        addrs[_a] = v
    end
    return true
end

function loop()
    if not c() then return end
    CLS()
    local count = 0
    local checked = {}
    for a, v in pairs(addrs) do
        local any_checked = false
        for i = 1, _NUM do
            local _a = a + (i-1)*4
            if checked[_a] then
                any_checked = true
                break
            end
        end
        if not any_checked then
            for i = 1, _NUM do
                local _a = a + (i-1)*4
                checked[_a] = true
            end
            if not check(a) then
                for i = 1, _NUM do
                    local _a = a + (i-1)*4
                    addrs[_a] = nil
                end
            else
                count = count + 1
            end
        end
    end
    local num = math.min(count, 30)
    local _count = 0
    for a, v in pairs(addrs) do
        _count = _count + 1
        print(string.format("0x%08X", a))
        if _count == num then break end
    end
    print("count: " .. tostring(count))
end
```

## video9 プリごろ太バグ & 漫画バグ

```lua


local kyoku_broken_head = 0x0228F28C
local kyoku_broken_width = 0x1400

local kyoku_broken_scale = 2
assert(kyoku_broken_width % kyoku_broken_scale == 0)
local kyoku_broken_hwidth = kyoku_broken_width // kyoku_broken_scale

local function round(x) return math.floor(x + 0.5) end

local function kyoku_broken1(scale)
    for i = 0, kyoku_broken_width-1, 2 do
        local _i = kyoku_broken_head + (round(i * scale) % kyoku_broken_width)
        w16(kyoku_broken_head + i, r16(_i))
        -- ここの書き込みがなぜか指揮者礼のときに使える
    end
end

-- 2パターンを両方採用
-- local max_scale = 1.05
-- local min_scale = 1.0
-- local c = Cnt(40)
local max_scale = 1.1
local min_scale = 1.0
local c = Cnt(20)

local function get_scale()
    return min_scale + c:next() * (max_scale - min_scale) / c.n
end
local function get_scale2()
    return (math.sin(c:next() * 2 * math.pi / c.n) + 1.0) * (max_scale - min_scale) + min_scale
end

local key_e = Cnt(2, 2)
local key_e2 = Cnt(2, 2)
local prev = false
local prev2 = false
local first = true
function loop()
    kyoku_broken1(get_scale2())
end


-- =============================

-- page 1
local W = 0x80

local function change_pos(x, y)
    return lib.pos.Morton(x, y, 0x04, 0x20, 0x400) + 0x06214000
end

local ys = 0x68
local ys2 = 0x44

lib.image.filterObj()
:width(W)
:bound(0x6000)
:go(function(x, y)
    if within(x, 0x08, 0x20) and y >= ys then
        local _y = math.round((y - ys) * 0.1) + ys
        return change_pos(x, y), r8(change_pos(x, _y))
    end
    if within(x, 0x5e, 0x70) and y >= ys2 then
        local _y = math.round((y - ys2) * 0.2) + ys2
        return change_pos(x, y), r8(change_pos(x, _y))
    end
end)

-- =============================


-- page 2
local W = 0x80

local function change_pos(x, y)
    return lib.pos.Morton(x, y, 0x04, 0x20, 0x400) + 0x06228000
end

local ys2 = 0x44

lib.image.filterObj()
:width(W)
:bound(0x6000)
:go(function(x, y)
    if within(x, 0x16, 0x23) and within(y, 0x6e, 0x7f) then
        local _y = -(y - 0x6e) + 0x7f
        return change_pos(x, y), r8(change_pos(x, _y))
    end
    if within(x, 0x50, 0x70) and y >= ys2 then
        local _y = math.round((y - ys2) * 0.2) + ys2
        return change_pos(x, y), r8(change_pos(x, _y))
    end
end)

-- =============================



-- page 3
local W = 0x80

local function change_pos(x, y)
    return lib.pos.Morton(x, y, 0x04, 0x20, 0x400) + 0x06234000
end

local xs = 0x48
local xe = 0x73
local ys = 0x54
local ye = 0xb3

lib.image.filterObj()
:width(W)
:bound(0x6000)
:go(function(x, y)
    local _x = math.round((x / W) * (xe-xs)) + xs
    local _y = math.round((y / 0xc0) * (ye-ys)) + ys
    return change_pos(x, y), r8(change_pos(_x, _y))
end)

-- =============================


-- page 4
local W = 0x80

local function change_pos(x, y)
    return lib.pos.Morton(x, y, 0x04, 0x20, 0x400) + 0x06248000
end

local ys = 0x54
local ye = 0x88

lib.image.filterObj()
:width(W)
:bound(0x6000)
:go(function(x, y)
    local _x = x % 0x20
    local _y = (y+0x10) % (ye - ys) + ys
    return change_pos(x, y), r8(change_pos(_x, _y))
end)

```


- `2289ABD`: 千秋のおじぎモーションの速度を早める(ただし想定のindexを超えるとフリーズする)
- `2289C0C`: 胴が横に伸びる
- `2289C0A`: 胴が縦に伸びる
- `2289C10`: 胴が後ろに伸びる
- `2289C38`: 首が縦に伸びる
- `2289C3C`: 首が横に伸びる
- `2289C40`: 首が後ろに伸びる


## video10 おじぎ中の千秋の首をミルみたく回転させる

```lua
local m1 = lib.at(0x02289C38)
local m2 = lib.at(0x02289C3C)
local m3 = lib.at(0x02289C40)
local i = 0
local max1 = 0x040000
local min1 = -0x10000

local span = 60

local scale = 0x40000

function loop()
    local v
    i = (i + 1) % span
    v = math.cos(i * 2 * math.pi / span) * scale
    m2:w32(stou32(v))
    v = math.sin(i * 2 * math.pi / span) * scale
    m3:w32(stou32(v))
end
```
