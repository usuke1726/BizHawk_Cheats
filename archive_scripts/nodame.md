
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

## video11 千秋ぐにぐに


```lua
-- 試行錯誤 その1
CLS()

local begin = 0x0228AF90
local inclusiveEnd = 0x02291Bff

local function found(v)
    return v & 0xffffff == 0x3a38 and within((v >> 24) & 0xff, 0, 0x2f)
end
local addrs = {}

local first = true

local span = 33
local is_guni_r = RC(30)
local is_guni = false
local scale = 0x300
local scale_r = RC(90)

local flags = {}

local _i = 0
local prev_key = false

function loop()
    if is_guni_r() then is_guni = not is_guni end
    if scale_r() then scale = rand(1,9) * 0x100 end
    _i = (_i + 1) % span
    scale = 0x900
    local __v = math.round(math.cos(_i*2*math.pi / span) * scale)
    local i = begin
    while i <= inclusiveEnd do
        local v = r32(i)
        i = i + 4
        if found(v) then
            if first then addrs[#addrs+1] = i-4 end
            for j = 1, 4 do
                -- if not flags[i+j] then
                --     flags[i+j] = rand(1,2) == 1
                -- end
                -- if is_guni_r() then
                --     flags[i+j] = not flags[i+j]
                -- end
                -- local _f = flags[i+j] and 1 or -1
                -- add32(i, __v * _f + rand(-2, 2)*0x100)
                local _f = within(i & 0xff, 0x40, 0x7f) and 1 or -1

                if j == 2 then
                    add32(i, __v * 8 * _f)
                end
                i = i + 4
            end
        end
    end
    if first then
        _HEXP(addrs[1])
        _HEXP(addrs[#addrs])
    end
    first = false
end
```

```lua
-- 試行錯誤 その2
CLS()

local begin = 0x0228AF90
local inclusiveEnd = 0x02291Bff

local function found(v)
    return v & 0xffffff == 0x3a38 and within((v >> 24) & 0xff, 0, 0x2f)
end
local addrs = {}

local first = true

local span = 33
local is_guni_r = RC(10)
local is_guni = false
local scale = 0x300
local scale_r = RC(90)

local flags = {}

local _i = 0
local prev_key = false

local backup = lib.range(begin, inclusiveEnd):save()

function loop()
    if is_guni_r() then backup:rollback() end
    if scale_r() then scale = rand(1,9) * 0x100 end
    _i = (_i + 1) % span
    scale = 0x900
    local __v = math.round(math.cos(_i*2*math.pi / span) * scale)
    local i = begin
    while i <= inclusiveEnd do
        local v = r32(i)
        i = i + 4
        if found(v) then
            if first then addrs[#addrs+1] = i-4 end
            for j = 1, 3 do
                add32(i, rand(-3, 3) * 0x800)
                i = i + 4
            end
        end
    end
    if first then
        _HEXP(addrs[1])
        _HEXP(addrs[#addrs])
    end
    first = false
end
```


```lua
-- のだめイルーム(video11時点では未使用。12以降、いつか使う。) => 15で使用済。
lib.irume.start(function()
    local head = 0x03eb8660
    local as = {}
    local poses = {}
    local pps = {}
    for i = -1, 15 do
        as[i] = head + 0x40*i
    end
    local r = RC(120)
    return function()
        for i, a in pairs(as) do
            if not poses[i] or r() then
                poses[i] = r32(a + 0x28)
            end
            w32(a + 0x28, poses[i])
        end
    end
end)
```

## FAT調査

```lua
-- nodame
-- FNT 08AA00
-- FNT size A3
-- FAT 08AC00
-- FAT size E8

-- ID: 5: JacketPic => 00EE0300 9C8E0400

-- lib.fill_in(0x03EE00, 0x048E9C, 0, ROM_DOMAIN_NAME)
-- lib.fill_in(0x03EE90, 0x040E9C, 0, ROM_DOMAIN_NAME)

-- w8r(0x48939, 0xff) -- 立ち絵千秋の顔が真っ赤に
-- w8r(0x48E72, 0x14) -- ローマの謝肉祭が「マリオ」?になる


-- lib.fill_in(0x051200, 0x058F27, 0, ROM_DOMAIN_NAME)

for i = 3, 4 do
    local a = 0x8ac50 + i*8
    local start = r32r(a)
    local iend = r32r(a + 4)
    print(string.format("0x%08X -- 0x%08X", start, iend))
    lib.fill_in(start, math.min(iend-1, start + 0x100000), 0, ROM_DOMAIN_NAME)
end

-- 関係あり?
-- 00280600 7C370600 (MusData.bin)
```

## video16 のだめ `3B 38` 領域テスト (動画では不使用)

```
雑多メモ

-- 2680FC6 -- Fを1とかでうめる
-- 26774E0からも波形データ?
-- 267A3F8あたり: ピアノのテクスチャ
-- のだめのテクスチャ: 2684CC4
-- テクスチャ横位置? 2684CD4 -> FFFFF2FF 付近
-- テクスチャ縦位置? 2684CD4 -> 1000 付近

-- 22D6450 -> アニメーション関連
-- 22B21C0 -> アニメーション関連

-- 229A328 右腕のアニメーションの一部?

-- 2284B70 -> 2700: ずっとこっち見る, 270f: 地面に横たわる

-- 2284B9B, C: FFFFにすると左手が回転しながらすっ飛ぶ(Cの方を00にしてもう一度FFにすると、もう一回飛ぶ)
-- 2284BCE: 0Eにすると右腕が回転しながらすっ飛ぶ(03にしてもう一度設定すると、もう一回飛ぶ。あと、0Eでなく0Fにすると速くなる)
-- 2284BFC (00 -- 1B) 足の向きが狂う

-- 228F3C0 -> 38 3Bゾーン?

2684b70
```

```lua
-- 228F6E0付近？

local function found(v)
    local _v = v & 0xffffff
    if _v == 0x3b38 then return true end
    if _v == 0x3a38 then return true end
    return false
end

local c = Cnt(30)
local r = RC(5)
local r2 = RC(10)

local origs = {}
local scale = 0x2000

function loop()
    c()
    if c.fired and r() then
        c:N(rand(10, 60))
        r:N(math.round(100 / c.n))
        scale = rand(0x2, 0x16) * 0x200
    end
    local _v = math.round((math.cos01(c.i / c.n) - 0.5) * scale)
    local i = 0x0228F000
    while i <= 0x0229FFFF do
        local v = r32(i)
        i = i + 4
        if found(v) then
            for j = 1, 3 do
                if not origs[i] then
                    origs[i] = r32(i)
                end
                if r2() then
                    w32(i, origs[i])
                else
                add32(i, _v * rand(1, 2))
                end
                -- add32(i, rand(-5, 5) * 0x100)
                i = i + 4
            end
        end
    end
end
```

## video16 のだめ荒ぶり

```lua
local function found(v)
    local _v = v & 0xffffff
    if _v == 0x3b38 then return true end
    if _v == 0x3a38 then return true end
    return false
end

local vus = {}
local origs = {}

local function utos32(v)
    if v < 0x80000000 then
        return v
    end
    return v - 0x100000000
end

local function setup(is_first)
    vus = {}
    local r = RC(is_first and 8 or 2)
    local i = 0x0228F000
    local modes = {"lerp", "pingpong", "isin"}
    while i <= 0x0229FFFF do
        local v = r32(i)
        i = i + 4
        if found(v) then
            for j = 1, 3 do
                if not origs[i] then
                    origs[i] = utos32(r32(i))
                end
                if not r() then
                    v = origs[i]
                    local d = rand(1, 0x20) * 0x1000
                    local mode = modes[rand(1, #modes)]
                    local n = rand(10, 40)
                    vus[i] = ValueUpdater(n, v - d, v + d, mode):w32(i)
                end
            end
        end
    end
end


setup(true)

local r = RC(60)

local update_sound = (function()
    local kyoku_broken_head = 0x022774E0
    local kyoku_broken_width = 0x1400

    local function kyoku_broken(scale)
        local vs = {}
        for i = 0, kyoku_broken_width-1, 2 do
            local _i = kyoku_broken_head + (math.round(i * scale) % kyoku_broken_width)
            vs[kyoku_broken_head + i] = r16(_i)
        end
        for a, v in pairs(vs) do
            w16(a, v)
        end
    end
    local c = Cnt(120)
    return function()
        local x = c:next() / c.n
        local scale = -x * x * x * 0.5 + 1.0
        kyoku_broken(scale)
    end
end)()

function loop()
    update_sound()
end


function loop()
    update_sound()
    for _, v in pairs(vus) do
        v()
    end
    if r() then setup() end
end
```

## video16 カンタービレボイスを連呼 & 服を顔テクスチャに & animation荒ぶり

```lua
local update_animation = (function()
    local rl = RL(480)
    local r = RC(60)
    local is_first = true
    return function()
        rl()
        if (not is_first) and (not r()) then return end
        for i = 0x2298150, 0x229ffff, 4 do
            local v = rand(-0x50, 0x50)
            if rl.fired then v = v * 0x10 end
            add32(i, v)
        end
        is_first = false
    end
end)()

-- テクスチャ横位置? 2684CD4 -> FFFFF2FF 付近
-- テクスチャ縦位置? 2684CD8 -> 1000 付近
local update_texture = (function()
    local v = ValueUpdater(1, -0xe00, -0x800)
    :calc(function(obj)
        return obj.v + rand(-0x10, 0x10) * 0x20
    end)
    :w32(0x02684CD4)
    local v2 = ValueUpdater(1, 0xf00, 0x1100)
    :calc(function(obj)
        return obj.v + rand(-0x10, 0x10) * 0x10
    end)
    :w32(0x02684CD8)
    return function()
        v()
        v2()
    end
end)()

local update_muki = (function()
    local r = RC(30)
    local f = false
    return function()
        if r() then f = not f end
        w8(0x02284B60, f and 0x27 or 0x26)
    end
end)()

function loop()
    update_animation()
    update_texture()
    update_muki()
end

lib.irume.start(function()
    local head = 0x03eb8660
    local as = {}
    local poses = {}
    local pps = {}
    for i = -1, 15 do
        as[i] = head + 0x40*i
    end
    local r = RC(120)
    local voice = 0x03EB86EC + 0x00
    local vr = RC(10)
    local vrl = RL(240)
    -- voice start? 15081802, 1B081802, 21081802
    return function()
        for i, a in pairs(as) do
            if not poses[i] or r() then
                poses[i] = r32(a + 0x28)
            end
            w32(a + 0x28, poses[i])
        end
        if vrl() and vr() then
        w16(voice, rand(-4, 2) * 0x100)
        end
    end
end)
```

## video16 股おっぴろげ & こっち見る

```lua
w16(0x2284B70, 0x0027)
-- 途中から0f
w8(0x2284BFC, 0x02) -- 02, 06, (0a), (0f), 13
local c = CntOnce(701)
function loop()
    if c() then
        print("DONE")
        w8(0x2284BFC, 0x0f)
    end
end
```

## video16 上昇ハットリ & 腕が回転しながらすっ飛ぶ

```lua
arm_start = false

local update_arms = (function()
    local left_i = 0
    local left_c = {
        RC(60),
        Cnt(120),
    }
    local right_i = 1
    local right_v = 4
    local right_c = {
        RC(60),
        Cnt(120),
    }

-- 2284B9B, C: FFFFにすると左手が回転しながらすっ飛ぶ(Cの方を00にしてもう一度FFにすると、もう一回飛ぶ)

-- 2284BCE: 0Eにすると右腕が回転しながらすっ飛ぶ(03にしてもう一度設定すると、もう一回飛ぶ。あと、0Eでなく0Fにすると速くなる)
    return function()
        if not arm_start then
            w8(0x02284B9B, 0x05)
            w8(0x02284B9C, 0x03)
            w8(0x02284BCE, 0x03)
            return
        end
        if left_c[left_i+1]() then
            left_i = (left_i + 1) % 2
        end
        w8(0x02284B9B, 0xff)
        w8(0x02284B9C, left_i == 0 and 0 or 0xff)
        if right_c[right_i+1]() then
            right_i = (right_i + 1) % 2
            right_v = rand(1, 4)
        end
        w8(0x2284BCE, right_i == 0 and 3 or (right_v == 1 and 0x0f or 0x0e))
    end
end)()

-- 2284BFC (00 -- 1B)
local update_leg = (function()
    local r = RC(10)
    local prev = -1
    return function()
        if not r() then return end
        while true do
            local v = rand(0, 0x1b)
            if prev ~= v then
                prev = v
                break
            end
        end
        w8(0x2284BFC, prev)
    end
end)()


local update_sound = (function()
    local kyoku_broken_head = 0x022774E0
    local kyoku_broken_width = 0x1400

    local function kyoku_broken(scale)
        local vs = {}
        for i = 0, kyoku_broken_width-1, 2 do
            local _i = kyoku_broken_head + (math.round(i * scale) % kyoku_broken_width)
            vs[kyoku_broken_head + i] = r16(_i)
        end
        for a, v in pairs(vs) do
            w16(a, v)
        end
    end
    local c = Cnt(30)
    return function()
        if not arm_start then return end
        local x = c:next() / c.n
        local scale = x * x * x * 0.3 + 1.0
        kyoku_broken(scale)
    end
end)()

function loop()
    update_arms()
    update_sound()
    -- update_leg()
end
```

## video16 レジェンドオブSオケの漫画シーンのバグ

```plaintext
改変テキスト(文字コードはSJIS)

こいつに合わせられるのはオレ様ぐらい
だ！Ｓオケメンバーがオレ様ぐらいだ！
みんなはオレ様ぐらいめくそ！？歌い上
げるオレ様！「キモー」オレ様！笑いに
合わせられる僕ってやっぱすごい！
天使はオレか♡フォーリンラブ♡

♡: 8740
\n: 0a
・: A5(･)
☆: 8199

レジェンド･オブ･機長ーォ、あと一曲！

峰る青春の喜びと 龍太郎☆龍太郎
```

```lua
-- No. 1

local lines = {
"82b182a282c282c98d8782ed82b982e782ea82e982cc82cd8349838c976c82ae82e782a2",
"82be814982728349835083818393836f815b82aa8349838c976c82ae82e782a282be8149",
"82dd82f182c882cd8349838c976c82ae82e782a282df82ad82bb8149814889cc82a28fe3",
"82b082e98349838c976c81498175834c8382815b81768349838c976c81498fce82a282c9",
-- "8d8782ed82b982e782ea82e98b4092b7815b8348814182a082c688ea8bc88149",
"8d8782ed82b982e782ea82e9966c82c182c482e282c182cf82b782b282a28149",
"93568e6782cd8349838c82a9874083748348815b838a8393838983758740",
}
lib.warr(0x0263EA76, lib.htob(table.concat(lines, "0a")))

lib.warr(0x02232DFD, lib.htob("838c8357834683938368a583498375a58b4092b7815b8348814182a082c688ea8bc88149")) -- タイトル(「レジェンド･オブ･機長ーォ、あと一曲！」)

lib.warr(0x0223AEC4, lib.htob("95f482e990c28f7482cc8aec82d182c62097b491be9859819997b491be9859")) -- 作曲者


-- ==============================
-- No. 2
-- ==============================

local kyoku_broken_head = 0x0228F28C
local kyoku_broken_width = 0x1400

local function kyoku_broken1(scale)
    local vs = {}
    for i = 0, kyoku_broken_width-1, 2 do
        local _i = kyoku_broken_head + (math.round(i * scale) % kyoku_broken_width)
        vs[kyoku_broken_head + i] = r16(_i)
    end
    for a, v in pairs(vs) do w16(a, v) end
end

local max_scale = 1.03
local min_scale = 1.0
local c = Cnt(20)

local function get_scale()
    if c() then
        min_scale = rand(98, 103) / 100
        max_scale = min_scale + rand(0, 30) / 1000
    end
    return (math.sin(c.i * 2 * math.pi / c.n) + 1.0) * (max_scale - min_scale) + min_scale
end

SET_LOOP("kyoku", function()
    kyoku_broken1(get_scale())
end)

-- ==============================
-- No. 3
-- ==============================


local W = 0x80
local H = 0xc0

local function change_pos(x, y)
    return lib.pos.Morton(x, y, 0x04, 0x20, 0x400) + 0x06214000
end

local vs = {}
for x = 0, W-1 do
    for y = 0, H-1 do
        local a = change_pos(x, y)
        vs[a] = r8(a)
    end
end

local update = (function()
    local v = ValueUpdater(20, -95, -65, "isin")
    ---@type VUO_calcEntry[]
    local v_modes = {"lerp", "isin", function(obj) return obj:lerp(1-obj:x()) end}
    local ys = 0
    local scl = 0.5
    local cx = Cnt(60)
    local x_span = 0x10
    local x_d = 0
    local x_ready = RL(10)
    return function()
        cx()
        v()
        if v.i == 0 then
            ys = rand(0, 0x30)
            scl = rand(20, 70) / 100
            if x_ready() then
                x_d = rand(0, 4)
                x_span = rand(0x5, 0x20)
            end
            -- scl = rand(2, 5)
            if rand(1, 2) == 1 then
            v.n = rand(10, 60)
            v:calc(v_modes[rand(1, #v_modes)])
            end
        end
        local theta = v.v / 180 * math.pi
        local A = {
            {math.sin(theta), math.cos(theta)},
            {math.cos(theta), -math.sin(theta)}
        }

lib.image.filterObj()
:width(W)
:height(H)
:go(function(x, y)
    local __x = x
    __x = (__x + cx.i) % W
    __x = (__x - 0x10) % 0x40 + 0x10
    __x = __x - (W//2)
    local __y = (H//2) - y
    local _x = math.round(A[1][1]*__x + A[1][2]*__y)
    local _y = math.round(A[2][1]*__x + A[2][2]*__y)
    _x = _x + (W//2)
    _y = -_y + (H//2)
    -- _y = _y - 0x10
    if _y > ys then
        -- _y = math.round((_y - ys) * scl) + ys + (_x % 0x10)
        _y = math.round((_y - ys) * scl) + ys + ((_x + x_d) % x_span)
    end
    return change_pos(x, y), vs[change_pos(_x, _y)] or 0
end)
    end
end)()


function loop()
    update()
end
```

## video19 荒ぶり


```lua

lib.find_all(0x02000000, 0x023fffff, ascii("JNT0"))

-- chiaki ver
-- local JNT_addrs = {
-- 0x022330DC,
-- 0x02233A84,
-- 0x0223459C,
-- 0x022358B0,
-- 0x02237414,
-- 0x0223876C,
-- 0x0223B614,
-- 0x0223F694,
-- 0x022455A8,
-- 0x02248B80,
-- 0x0224A2C4,
-- 0x0228ABF0,
-- }

-- nodame ver
local JNT_addrs = {
0x022330DC,
0x02233A84,
0x0223459C,
0x022358B0,
0x02237414,
0x0223876C,
0x0223B614,
0x0223F694,
0x0224548C,
0x02248D0C,
0x0224A450,
0x02265138,
0x0228EB14,
}

-- Nitro.read_JNT0(addrs[1], "nodame_JNT.txt")
local addrs = lib.array.flat(lib.array.map(JNT_addrs, function(a)
    local res = Nitro.read_JNT0(a, lib.path.dummy())
    return lib.array.flat({
        -- res.addrs_tr,
        -- res.addrs_scl,
        res.addrs_rot,
    })
end))

local origs = {}
for _, a in pairs(addrs) do
    origs[a] = r8(a)
    origs[a+1] = r8(a+1)
end

-- local r = RC(5)
local r = RC(20)
local r2 = RC(30)
SET_LOOP("MOVE", function()
    for _, a in pairs(addrs) do
        if r() then
            add8(a + rand(0,4), rand(-3, 3)*(0x10 << rand(0,3)))
        end
        if r2() then w8(a, origs[a]) end
        if r2() then w8(a+1, origs[a+1]) end
    end
end)

lib.irume.start(function()
    local head = 0x03eb8660
    local as = {}
    local p1 = 0x13
    local p2 = 0x06
    local vol = 0x0b
    local ps = {}
    for i = 0, 14 do
        as[i] = head + 0x40*i
        ps[i] = 0
    end
    local r = RC(10)
    local r2 = RC(60)
    local ok = false
    return function()
        if r2() then
            ok = not ok
        end
        for i, a in pairs(as) do
            w8(a+vol, 0x44)
            w8(a+vol+1, 0x44)
            if ok then
                ps[i] = (ps[i] + 1) % 0x40
                local v = ps[i]
                w16(a+p2, (v<<8) | v)
            elseif r() then
                local v = rand(0, 0x40)
                ps[i] = v
                w16(a+p2, (v<<8) | v)
            end
        end
    end
end)
```

## video20 ペラペラ千秋

```lua
local res = Nitro.read_MDL0(0x02280A2C, 0)
local mesh = res.addrs_mesh
assert(#mesh == 2)
Nitro.filter_mesh(mesh[1].begin, mesh[1].iend, function(addr, cmd, pnum, name)
    if name ~= MESH_COMMANDS.VTX_16 then return end
    assert(addr%2==0)
    local x, y, z = r16(addr+0), r16(addr+2), r16(addr+4)
    local _x, _y, _z
    _x = intToFixFloat(x, 3, 12)
    _y = intToFixFloat(y, 3, 12)
    _z = intToFixFloat(z, 3, 12)
    w16(addr+4, fixFloatToInt(invlerp(_z, -8, 2.1)*0.1, 3, 12))
end)
local vs = {}
Nitro.filter_mesh(mesh[2].begin, mesh[2].iend, function(addr, cmd, pnum, name)
    if name ~= MESH_COMMANDS.VTX_16 then return end
    assert(addr%2==0)
    local x, y, z = r16(addr+0), r16(addr+2), r16(addr+4)
    local _x, _y, _z
    _x = intToFixFloat(x, 3, 12)
    _y = intToFixFloat(y, 3, 12)
    _z = intToFixFloat(z, 3, 12)
    vs[addr+4] = _z
    -- w16(addr+4, fixFloatToInt(invlerp(_z, -8, 2.1)*0.1, 3, 12))
end)
local c = Cnt(31)
function loop()
    local i = c:next()
    for a, z in pairs(vs) do
        -- w16(a, fixFloatToInt(z * (1+0.3*math.sin01(i/c.n)) , 3, 12))
        w16(a, fixFloatToInt(z * (1+0.5*math.sin01(i/c.n)) , 3, 12))
    end
end

lib.irume.start(function()
    local head = 0x03eb8660
    local as = {}
    local p1 = 0x13
    local p2 = 0x06
    local vol = 0x0a
    -- local ps = {0x1111, 0x1129}
    -- local ps = {0xf8f8}
    -- local ps = {0xffff}
    -- local ps = {0xf8f8, 0xf9f9, 0xfafa, 0xfbfb, 0xfcfc, 0xfdfd, 0xfefe, 0xfdfd, 0xfcfc, 0xfbfb, 0xfafa, 0xf9f9}
    local ps = {0xf5f5, 0xf6f6, 0xf7f7, 0xf8f8, 0xf9f9, 0xfafa, 0xfbfb, 0xfafa, 0xf9f9, 0xf8f8, 0xf7f7, 0xf6f6}
    local _p = 0xf8f8
    local r = RC(10)
    local c = Cnt(3, #ps)
    for i = 0, 14 do
        as[i] = head + 0x40*i
    end
    return function()
        c()
        -- if r() then _p = rand(0xfb, 0xff) _p = (_p<<8)|_p end
        if r() then _p = rand(0x10a, 0x111) % 0x100 _p = (_p<<8)|_p end
        for i, a in pairs(as) do
            w8(a+vol, 0x20)
            w8(a+vol+1, 0x0)
            w16(a+p2, _p)
        end
        for i = 12, 12 do
            w8(as[i]+vol, 0x66)
            w8(as[i]+vol+1, 0x66)
            w8(as[i]+vol+2, 0x66)
            w16(as[i]+p2, ps[c.i+1])
            w8(as[i]+0x19, 0x06)
            w16(as[i]+0x1a, 0x6ff)
        end
    end
end)
```

## video20 ブロック状収縮拡大(謎の踊り)

```lua

local res = Nitro.read_MDL0(0x02280A2C, 0)
local mesh = res.addrs_mesh
local vs = {}
assert(#mesh == 2)
Nitro.filter_mesh(mesh[1].begin, mesh[1].iend, function(addr, cmd, pnum, name)
    if name ~= MESH_COMMANDS.VTX_16 then return end
    assert(addr%2==0)
    local x, y, z = r16(addr+0), r16(addr+2), r16(addr+4)
    local _x, _y, _z
    _x = intToFixFloat(x, 3, 12)
    _y = intToFixFloat(y, 3, 12)
    _z = intToFixFloat(z, 3, 12)
    w16(addr+0, fixFloatToInt(invlerp(_x, -8, 2.1)*2, 3, 12))
    -- w16(addr+2, fixFloatToInt(invlerp(_y, -8, 2.1)*2, 3, 12))
    vs[addr+2] = _y
    vs[addr+4] = _z
    -- w16(addr+4, fixFloatToInt(invlerp(_z, -8, 2.1)*2, 3, 12))
end)
Nitro.filter_mesh(mesh[2].begin, mesh[2].iend, function(addr, cmd, pnum, name)
    if name ~= MESH_COMMANDS.VTX_16 then return end
    assert(addr%2==0)
    local x, y, z = r16(addr+0), r16(addr+2), r16(addr+4)
    local _x, _y, _z
    _x = intToFixFloat(x, 3, 12)
    _y = intToFixFloat(y, 3, 12)
    _z = intToFixFloat(z, 3, 12)
    -- vs[addr+4] = _z
    w16(addr+0, fixFloatToInt(_x*3, 3, 12))
    w16(addr+2, fixFloatToInt(_y*3, 3, 12))
    w16(addr+4, fixFloatToInt(_z+0.5, 3, 12))
    -- w16(addr+4, fixFloatToInt(invlerp(_z, -8, 2.1)*0.1, 3, 12))
end)

local c = Cnt(31)
function loop()
    local i = c:next()
    local scl = 0.2+2.5*math.sin01(i/c.n)
    -- local scl = 0.2
    for a, z in pairs(vs) do
        w16(a, fixFloatToInt(invlerp(z, -8, 2.1)*scl, 3, 12))
    end
end

lib.irume.start(function()
    local head = 0x03eb8660
    local as = {}
    local p1 = 0x13
    local p2 = 0x06
    local vol = 0x0a
    local ps = {0x1111, 0x1129, 0x2222, 0x3333, 0xf5f5, 0xffff, 0xfbfb, 0xfcfc, 0x1212, 0x1919}
    local _p = 0xf8f8
    local _pv = 0x1111
    local r = RC(10)
    local r2 = RC(120)
    local c = Cnt(20)
    local poses = {}
    local vols = {}
    local vols_r = RC(60)
    for i = 0, 14 do
        as[i] = head + 0x40*i
        vols[i] = 0x20
    end
    return function()
        if c() then
            _pv = ps[rand(1, #ps)]
        end
        if r() then _p = rand(0xfb, 0xff) _p = (_p<<8)|_p end
        for i, a in pairs(as) do
            if vols_r() then vols[i] = rand(-2, 16)*0x20 end
            w16(a+vol, vols[i])
            w16(a+p2, _p)

            if not poses[i] or r2() then
                poses[i] = r32(a + 0x28)
            end
            w32(a + 0x28, poses[i])
        end
        for i = 12, 12 do
            w8(as[i]+vol, 0x66)
            w8(as[i]+vol+1, 0x66)
            w8(as[i]+vol+2, 0x66)
            -- w16(as[i]+p2, ps[c.i+1])
            w16(as[i]+p2, _pv)
            w8(as[i]+0x19, 0x06)
            w16(as[i]+0x1a, 0x6ff)
        end
    end
end)
```

## video23 リザルト 情けない顔「最高にキモモモモモ」

```lua
local addrs = {
0x02237934,
0x0223D514,
0x02265204,
}
local res = Nitro.read_MDL0(addrs[2], 0)
local meshes = res.addrs_mesh

local f16 = FixFloatConverter(3, 12)
local xmin, xmax = 10000000000, -10000000000
local ymin, ymax = 10000000000, -10000000000
local zmin, zmax = 10000000000, -10000000000
for _, mesh in pairs(meshes) do
    Nitro.filter_mesh(mesh.begin, mesh.iend, function(addr, cmd, pnum, name)
        if name == MESH_COMMANDS.VTX_16 then
        local x = f16:tof(r16(addr+0))
        local y = f16:tof(r16(addr+2))
        local z = f16:tof(r16(addr+4))
        xmin = math.min(xmin, x) xmax = math.max(xmax, x)
        ymin = math.min(ymin, y) ymax = math.max(ymax, y)
        zmin = math.min(zmin, z) zmax = math.max(zmax, z)
        end
    end)
    Nitro.filter_mesh(mesh.begin, mesh.iend, function(addr, cmd, pnum, name)
        if name == MESH_COMMANDS.VTX_16 then
        local x = f16:tof(r16(addr+0))
        local y = f16:tof(r16(addr+2))
        local z = f16:tof(r16(addr+4))
        -- y: 横
        -- z: 奥行
        -- x: 縦
        x = x - math.abs(invlerp(y, ymin, ymax)-0.5) * 2
        w16(addr+0, f16:toi(x))
        w16(addr+2, f16:toi(y))
        w16(addr+4, f16:toi(z))
        end
    end)
end

-- 「キモモモモモ」は「キモ」の瞬間にフリーズさせればよい
```

## video23 デブ化 & 情けない顔2

```lua
local f16 = FixFloatConverter(3, 12)
local res = Nitro.read_MDL0(0x02280A2C, 0)
local mesh = res.addrs_mesh
local xmin, xmax = 10000000, -10000000
local ymin, ymax = 10000000, -10000000
local zmin, zmax = 10000000, -10000000

xmin, xmax = 10000000, -10000000
ymin, ymax = 10000000, -10000000
zmin, zmax = 10000000, -10000000
Nitro.filter_mesh(mesh[1].begin, mesh[1].iend, function(addr, cmd, pnum, name)
    if name ~= MESH_COMMANDS.VTX_16 then return end
    assert(addr%2==0)
    local x, y, z = f16:tof(r16(addr+0)), f16:tof(r16(addr+2)), f16:tof(r16(addr+4))
    xmin = math.min(xmin, x) xmax = math.max(xmax, x)
    ymin = math.min(ymin, y) ymax = math.max(ymax, y)
    zmin = math.min(zmin, z) zmax = math.max(zmax, z)
end)
-- local t = Cnt(60)
Nitro.filter_mesh(mesh[1].begin, mesh[1].iend, function(addr, cmd, pnum, name)
    if name ~= MESH_COMMANDS.VTX_16 then return end
    local x, y, z = f16:tof(r16(addr+0)), f16:tof(r16(addr+2)), f16:tof(r16(addr+4))
    -- local dx = invlerp(x, xmin, xmax)
    -- local yx = invlerp(y, ymin, ymax)
    z=z*2
    y=y*2
    w16(addr+0, f16:toi(x))
    w16(addr+2, f16:toi(y))
    w16(addr+4, f16:toi(z))
end)

xmin, xmax = 10000000, -10000000
ymin, ymax = 10000000, -10000000
zmin, zmax = 10000000, -10000000

Nitro.filter_mesh(mesh[2].begin, mesh[2].iend, function(addr, cmd, pnum, name)
    if name ~= MESH_COMMANDS.VTX_16 then return end
    assert(addr%2==0)
    local x, y, z = f16:tof(r16(addr+0)), f16:tof(r16(addr+2)), f16:tof(r16(addr+4))
    xmin = math.min(xmin, x) xmax = math.max(xmax, x)
    ymin = math.min(ymin, y) ymax = math.max(ymax, y)
    zmin = math.min(zmin, z) zmax = math.max(zmax, z)
end)
Nitro.filter_mesh(mesh[2].begin, mesh[2].iend, function(addr, cmd, pnum, name)
    if name ~= MESH_COMMANDS.VTX_16 then return end
    local x, y, z = f16:tof(r16(addr+0)), f16:tof(r16(addr+2)), f16:tof(r16(addr+4))
    -- x: 高さ
    -- y: 横
    -- z: 奥行
    z = z - 0.5
    x = 3*x - 1 - math.abs(invlerp(y, ymin, ymax) - 0.5)*5
    y = 4*y
    -- vs[addr+4] = _z
    w16(addr+0, f16:toi(x))
    w16(addr+2, f16:toi(y))
    w16(addr+4, f16:toi(z))
    -- w16(addr+4, fixFloatToInt(invlerp(_z, -8, 2.1)*0.1, 3, 12))
end)

lib.irume.start(function()
    local head = 0x03eb8660
    local as = {}
    local p1 = 0x13
    local p2 = 0x06
    local vol = 0x0a
    local v = ValueUpdater(35, 0x08, 0x10, "isin")
    for i = 0, 16 do
        as[i] = head + 0x40*i
    end
    return function()
        v()
        local _v = (v.v<<8)|v.v
        for i, a in pairs(as) do
            w16(a+vol, 0x0100)
            w16(a+p2, _v)
        end
    end
end)
```

## video23 髪の毛伸ばす & 手を横にチョー広げる etc.

```lua

lib.irume.start(function()
    local head = 0x03eb8660
    local as = {}
    local p1 = 0x13
    local p2 = 0x06
    local vol = 0x0a
    for i = 0, 16 do
        as[i] = head + 0x40*i
    end
    local c = Cnt(2, 2)
    local r = RC(20)
    local d = 0x1000
    return function()
        if r() then
            d = rand(1, 20) * 0x400
        end
        c()
        local v = (c.i+1)*0x10
        v = (v<<8) | v
        if c.i == 1 then
            v = v + d
        end
        for i, a in pairs(as) do
            w16(a+vol, 0x80)
            w16(a+p2, v)
        end
    end
end)




w8(0x022812B5, 0x2b)
w32(0x022812BC, 0)
w8(0x022812BC, 0xb6)


local f16 = FixFloatConverter(3, 12)
local res = Nitro.read_MDL0(0x02280A2C, 0)
local mesh = res.addrs_mesh

local update_body = (function()
local xmin, xmax = 10000000, -10000000
local ymin, ymax = 10000000, -10000000
local zmin, zmax = 10000000, -10000000

---@type table<int, {y: number, z: number}>
local vs = {}
printf("MESH START: 0x%08X", mesh[1].begin)
Nitro.filter_mesh(mesh[1].begin, mesh[1].iend, function(addr, cmd, pnum, name)
    if name ~= MESH_COMMANDS.VTX_16 then return end
    assert(addr%2==0)
    local x, y, z = f16:tof(r16(addr+0)), f16:tof(r16(addr+2)), f16:tof(r16(addr+4))
    xmin = math.min(xmin, x) xmax = math.max(xmax, x)
    ymin = math.min(ymin, y) ymax = math.max(ymax, y)
    zmin = math.min(zmin, z) zmax = math.max(zmax, z)
end)
local t = Cnt(60)
Nitro.filter_mesh(mesh[1].begin, mesh[1].iend, function(addr, cmd, pnum, name)
    if name ~= MESH_COMMANDS.VTX_16 then return end
    local x, y, z = f16:tof(r16(addr+0)), f16:tof(r16(addr+2)), f16:tof(r16(addr+4))
    -- x: 高さ
    -- y: 横
    if within(invlerp(x, xmin, xmax), 0.4, 0.45) then
        -- y = y * 8
        -- local __x = x
        -- x = (x-3)*16 + 40
        x = x*16+40
        -- printf("%f -> %f", __x, x)
    end
        -- y = y+4
    y = y/2
    -- y = y * 4
    w16(addr+0, f16:toi(x))
    w16(addr+2, f16:toi(y))
    w16(addr+4, f16:toi(z))
end)
return function() end
end)()

local update_face = (function()
local xmin, xmax = 10000000, -10000000
local ymin, ymax = 10000000, -10000000
local zmin, zmax = 10000000, -10000000
---@type table<int, {y: number, z: number}>
local vs = {}

Nitro.filter_mesh(mesh[2].begin, mesh[2].iend, function(addr, cmd, pnum, name)
    if name ~= MESH_COMMANDS.VTX_16 then return end
    assert(addr%2==0)
    local x, y, z = f16:tof(r16(addr+0)), f16:tof(r16(addr+2)), f16:tof(r16(addr+4))
    xmin = math.min(xmin, x) xmax = math.max(xmax, x)
    ymin = math.min(ymin, y) ymax = math.max(ymax, y)
    zmin = math.min(zmin, z) zmax = math.max(zmax, z)
end)
Nitro.filter_mesh(mesh[2].begin, mesh[2].iend, function(addr, cmd, pnum, name)
    if name ~= MESH_COMMANDS.VTX_16 then return end
    local x, y, z = f16:tof(r16(addr+0)), f16:tof(r16(addr+2)), f16:tof(r16(addr+4))
    -- x: 高さ
    -- y: 横
    -- z: 奥行
    -- y = y * 4
    y=y/2
    -- if within(invlerp(x, xmin, xmax), 0.19, 0.2) and within(z, -1.2, -1.1) then
    if within(invlerp(x, xmin, xmax), 0, 0.5) then
        -- print("OK")
        local d = (1-invlerp(x, xmin, xmax))*0.2
        z = z - d*4
        x = x + d
    end
    w16(addr+0, f16:toi(x))
    w16(addr+2, f16:toi(y))
    w16(addr+4, f16:toi(z))
    -- w16(addr+4, fixFloatToInt(invlerp(_z, -8, 2.1)*0.1, 3, 12))
end)
return function() end
end)()




-- サビが始まる瞬間に実行↓
local addrs = {
0x022330DC,
0x02233A84,
0x0223459C,
0x022358B0,
0x02237414,
0x0223876C,
0x0223B614,
0x0223F694,
0x022455A8,
0x02248B80,
0x0224A2C4,
0x0228ABF0,
}
local ftr = FixFloatConverter(19, 12)

for _, addr in pairs(pick(addrs, {
-- range(1, 20)
range(0, 200)
})) do
local res = Nitro.read_JNT0(addr, 0)
local tr_x = {}
local tr_y = {}
local tr_z = {}
local rot = {}
---@param v {addr: int}?
---@param arr any
local function try_add(v, arr)
    if v then
        table.insert(arr, {addr = v.addr, v = r32(v.addr)})
    end
end
for _, tracks in pairs(res.tracks) do
for _, track in pairs(tracks) do
    try_add(track.CurveX_Const, tr_x)
    try_add(track.CurveY_Const, tr_y)
    try_add(track.CurveZ_Const, tr_z)
    try_add(track.CurveRot_Const, rot)
end
end
-- printf("tr_x: %d", #tr_x)
-- printf("tr_y: %d", #tr_y)
-- printf("tr_z: %d", #tr_z)
-- printf("rot: %d", #rot)

local ARR = pick(tr_y, {
range(1, 3000)
})
local min, max = 1000000000, -1000000000
for a, v in pairs(ARR) do
    local _v = ftr:tof(v.v)
    min = math.min(min, _v) max = math.max(max, _v)
end
for a, V in pairs(ARR) do
    local v = ftr:tof(V.v)
    if v == 0 then v = 0.01 end
    v = v * 512
    w32(V.addr, ftr:toi(v))
end

ARR = pick(tr_z, {
range(1, 3000)
})
min, max = 1000000000, -1000000000
for a, v in pairs(ARR) do
    local _v = ftr:tof(v.v)
    min = math.min(min, _v) max = math.max(max, _v)
end
for a, V in pairs(ARR) do
    local v = ftr:tof(V.v)
    if v == 0 then v = 0.01 end
    v = v * 128
    w32(V.addr, ftr:toi(v))
end

printf("%f -- %f", min, max)
end

-- b6

w8(0x022812B5, 0x2b)
w32(0x022812BC, 0)
local c = RC(5)
function loop()
    if not c() then return end
    w8(0x022812BC, rand(0,0xff))
end
```

## video23 千秋グルグル回転 (ボツ)

```lua
--千秋グルグル回転(地味なバグか？)

local f16 = FixFloatConverter(3, 12)
local res = Nitro.read_MDL0(0x02280A2C, 0)
-- local res = Nitro.read_MDL0(0x0223D514, 0)
local mesh = res.addrs_mesh


local update_body = (function()
local xmin, xmax = 10000000, -10000000
local ymin, ymax = 10000000, -10000000
local zmin, zmax = 10000000, -10000000

---@type table<int, {y: number, z: number}>
local vs = {}
Nitro.filter_mesh(mesh[1].begin, mesh[1].iend, function(addr, cmd, pnum, name)
    if name ~= MESH_COMMANDS.VTX_16 then return end
    assert(addr%2==0)
    local x, y, z = f16:tof(r16(addr+0)), f16:tof(r16(addr+2)), f16:tof(r16(addr+4))
    xmin = math.min(xmin, x) xmax = math.max(xmax, x)
    ymin = math.min(ymin, y) ymax = math.max(ymax, y)
    zmin = math.min(zmin, z) zmax = math.max(zmax, z)
end)
local t = Cnt(60)
Nitro.filter_mesh(mesh[1].begin, mesh[1].iend, function(addr, cmd, pnum, name)
    if name ~= MESH_COMMANDS.VTX_16 then return end
    local x, y, z = f16:tof(r16(addr+0)), f16:tof(r16(addr+2)), f16:tof(r16(addr+4))
    vs[addr+2] = {y = invlerp(y, ymin, ymax), z = invlerp(z, zmin, zmax)}
    -- local dx = invlerp(x, xmin, xmax)
    -- local yx = invlerp(y, ymin, ymax)
    -- x = lerp(xmin, xmax, ease(invlerp(x, xmin, xmax), "quad", "mid"))
    -- x: 高さ
    -- y: 横
    w16(addr+0, f16:toi(x))
    -- w16(addr+2, f16:toi(y))
    -- w16(addr+4, f16:toi(z))
end)
return function()
    local _x = t:next()/t.n
    local sin = math.sin(2*_x*math.pi)
    local cos = math.cos(2*_x*math.pi)
    for a, v in pairs(vs) do
        local y, z = v.y-0.5, v.z-0.5
        local y2 = y*sin + z*cos
        local z2 = y*cos - z*cos
        w16(a, f16:toi(lerp(ymin, ymax, y2)))
        w16(a+2, f16:toi(lerp(zmin, zmax, z2)))
    end
end
end)()

local update_face = (function()
local xmin, xmax = 10000000, -10000000
local ymin, ymax = 10000000, -10000000
local zmin, zmax = 10000000, -10000000
---@type table<int, {y: number, z: number}>
local vs = {}

Nitro.filter_mesh(mesh[2].begin, mesh[2].iend, function(addr, cmd, pnum, name)
    if name ~= MESH_COMMANDS.VTX_16 then return end
    assert(addr%2==0)
    local x, y, z = f16:tof(r16(addr+0)), f16:tof(r16(addr+2)), f16:tof(r16(addr+4))
    xmin = math.min(xmin, x) xmax = math.max(xmax, x)
    ymin = math.min(ymin, y) ymax = math.max(ymax, y)
    zmin = math.min(zmin, z) zmax = math.max(zmax, z)
end)
Nitro.filter_mesh(mesh[2].begin, mesh[2].iend, function(addr, cmd, pnum, name)
    if name ~= MESH_COMMANDS.VTX_16 then return end
    local x, y, z = f16:tof(r16(addr+0)), f16:tof(r16(addr+2)), f16:tof(r16(addr+4))
    -- x: 高さ
    -- y: 横
    -- z: 奥行
    local b = 0.0001
    local dy = math.abs(math.fmod(invlerp(y, ymin, ymax) + 0.0, b) - b/2)*5/b
    x = x * 3
    y = y * 3
    z = z - 5
    x = x - dy
    x = x - 3
    w16(addr+0, f16:toi(x))
    w16(addr+2, f16:toi(y))
    w16(addr+4, f16:toi(z))
    -- w16(addr+4, fixFloatToInt(invlerp(_z, -8, 2.1)*0.1, 3, 12))
end)
return function() end
end)()

function loop()
    update_body()
    update_face()
end
```

## video24 千秋静止


```lua

local addrs = {
0x0228ABF0, -- 千秋指揮アニメーション
}
CLS()
-- local ftr = FixFloatConverter(19, 12)

local samp_x_addrs = {}
local basis_mat = {}

for _, addr in pairs(addrs) do
local res = Nitro.read_JNT0(addr, "tmp.txt")
local anim = res.addrs_anim
for _, a in pairs(res.addrs_basis_mat) do
    table.insert(basis_mat, a)
end
printf("%d anims", #anim)
for i, a in pairs(anim) do
    assert(a%2==0)
    local track = assert(res.tracks[i][2])
    local s = ""
    local f = track.flags
    if not f.no_translation_channels then
        if f.translation_x_constant then
            local xaddr = track.CurveX_Const.addr
            printf("  - X Const 0x%08X", xaddr)
        else
            local xaddr = track.CurveX.sample_off + a
            printf("  - X Sampl 0x%08X (width: %d)", xaddr, track.CurveX.width)
            -- table.insert(samp_x_addrs, xaddr)
        end
        if not f.translation_y_constant then
            local xaddr = track.CurveY.sample_off + a
            -- printf("  - X Sampl 0x%08X (width: %d)", xaddr, track.CurveX.width)
            table.insert(samp_x_addrs, xaddr)
        end
        if not f.translation_z_constant then
            local xaddr = track.CurveZ.sample_off + a
            -- printf("  - X Sampl 0x%08X (width: %d)", xaddr, track.CurveX.width)
            -- table.insert(samp_x_addrs, xaddr)
        end
    end
    if not f.no_rotation_channel then
        if f.rotation_constant then
            printf("ROTCONST")
        else printf("ROTSAMP")
        end
    end
    -- printf("track [%d][1]: %s", i, s)
    -- printf("frames: %d", r16(a+4)) -- 61
    -- w16(a + 4, 1021)
    w16(a + 4, 1)
    -- printf("tracks: %d", r16(a+6)) -- 32
    w16(a + 6, 2)
end
printf("================\n")
end
local fx = FixFloatConverter(19, 12)
local vn = 40
local v = ValueUpdater(vn, 0, 0x10000, "parabola")
local samp_x_vals = {}
for _, a in pairs(samp_x_addrs) do
    samp_x_vals[a] = fx:tof(r32(a))
end
local ok = false
local key = DS.key.lis("A"):on("down", function() ok = true end)
function loop()
    -- for _, a in pairs(basis_mat) do
    --     for i = 0, 20 do
    --         -- w32(a+i*4, rand(0, 0xffffffff))
    --         add32(a+i*4, rand(-1,0x1)*0x10000)
    --     end
    -- end
    key()
    if not ok then return end
    v()
    if v.i == 0 then
        if rand(1,4) == 1 then
            v.n = vn
            v:minmax(0, 0x10000)
        else
            v.n = vn//2
            v:minmax(0, 0x4000)
        end
    end
    for _, a in pairs(samp_x_addrs) do
        -- w32(a, rand(0,0xffffffff))
        w32(a, fx:toi(samp_x_vals[a]+ v.v/0x1000))
    end
end

```

## video24 千秋カクカク回転

```lua

local addrs = {
0x0228ABF0, -- 千秋指揮アニメーション
}
CLS()
-- local ftr = FixFloatConverter(19, 12)

local samp_x_addrs = {}
local basis_mat = {}

for _, addr in pairs(addrs) do
local res = Nitro.read_JNT0(addr, "tmp.txt")
local anim = res.addrs_anim
-- for _, a in pairs(res.addrs_basis_mat) do
--     table.insert(basis_mat, a)
-- end
for _, a in pairs(res.addrs_pivot_mat) do
    table.insert(basis_mat, a)
end
for i, a in pairs(anim) do
    assert(a%2==0)
    w16(a + 4, 10)
    w16(a + 6, 10)
end
end
local fx = FixFloatConverter(19, 12)
local vn = 40
local v = ValueUpdater(vn, 0, 0x10000, "parabola")
local samp_x_vals = {}
for _, a in pairs(samp_x_addrs) do
    samp_x_vals[a] = fx:tof(r32(a))
end
local ok = false
local key = DS.key.lis("A"):on("down", function() ok = true end)
function loop()
    for _, a in pairs(basis_mat) do
        for i = 0, 0x10 do
            add32(a+i*4, rand(-1,0x1)*0x100)
        end
    end
end

lib.irume.start(function()
    local head = 0x03eb8660
    local as = {}
    local poses = {}
    local t = 0x20
    local p1 = 0x13
    local p2 = 0x06
    local vol = 0x0b
    local pps = {}
    for i = 0, 15 do
        as[i] = head + 0x40*i
    end
    local r = RC(120)
    local m = lib.at(head)
    local ps = {1,6,11,16,21}
    local c = Cnt(10, #ps)
    return function()
        c()
        for i, a in pairs(as) do
            w8(a+vol, 0x44)
            w8(a+vol+1, 0x44)
            local __p = ps[c.i+1]
            if __p < 0 then __p = 0x100+__p end
            w16(a+p2, (__p<<8)|__p)
        end
    end
end)
```
