
# マリオ64 DS

メモ

```lua
-- 023096c0付近
-- 230f1a0

-- 22f659A -> ピーチあらぶり
-- 22f6593-6 を33でうめつくすと、いい感じに荒ぶる

-- ======================================
-- ======================================
-- ======================================

CLS()

lib.fill_in(0x0228ba00, 0x0228baff)

print("DONE " .. tostring(rand(0, 9999)))

w32(0x0228ba30, 0) -- 衣服のテクスチャ

w8(0x0228ba81, 0) -- 目の垂直位置
-- 16: 
-- 0C: のびる

w8(0x0228ba7d, 0) -- 目の水平位置
-- 3F: 目が2組
-- 0: 目なし

w8(0x0228BA9A, 0) -- 目まわりの透過具合

w8(0x0228ba93, 0) -- 目まわりをさっ白く

w8(0x0228c48d, 0x03) -- 店を傾ける
w8(0x0228c499, 0x40) -- 店の高さスケールを変える
w8(0x0228c4a9, 0x40) -- 店の奥行きスケールを変える
w16(0x0228c488, 0x0880) -- 店の幅を変える(def: 0x1000)

-- キノピオ
-- 0x022921b4あたりから

-- ======================================
-- ======================================
-- ======================================

-- lib.fill_in(0x022892d0, 0x0228b4ff)
-- lib.fill_in(0x0228b500, 0x0228baff, 0xff)
-- lib.fill_in(0x02093d60, 0x02094fff, 0xff)
-- lib.fill_in(0x022f6000, 0x022fffff, 0x64)


-- lib.fill_in(0x06506000, 0x06ffffff, 0x64)
-- lib.fill_in(0x06000000, 0x061fffff, 0x64)
-- lib.fill_in(0x04000000, 0x0400001f, 0x64)
lib.fill_in(0x228d160, 0x02292040)
function loop()
    -- w16(0x04000010, 0xafaf) -- 画面を横移動

    lib.fill_in(0x02292040, 0x0229219f)

    -- -- にしきかげ&カード消滅
    -- w8(0x04000240, 0xff)
    -- w8(0x04000243, 0xff)

    -- -- 下画面背景 かいめつ
    -- w8(0x0400100E, 0x10)

    w32(0x0217d528, 0) -- キノピオをおドム化

    -- ルイージ 0217d450あたり
    -- 太さ: 0x0217d419
end
```

イルーム1

```lua
lib.irume.start(function()
    local m1 = lib.at(0x03e07D57)
    local vib_sp1 = lib.at(0x03e07d5e)
    local vib_dp1 = lib.at(0x03e07d5f)
    local m2 = lib.at(0x03e07D97)
    local m3 = lib.at(0x03e07DD7)
    local vib_sp3 = lib.at(0x03e07ddd)
    local vib_dp3 = lib.at(0x03e07dde)
    local m4 = lib.at(0x03e07E17)
    local r = RC(30)
    local voice1 = lib.at(0x03e07e57)
    local voice2 = lib.at(0x03e07e97)
    local voice1p = lib.at(0x03e07e5d)
    local voice2p = lib.at(0x03e07e9d)
    local voice_p = 0
    return function()
        if r() then m1:w8(stou8(rand(-4, 4))) end
        if r() then m2:w8(stou8(rand(-4, 4))) end
        vib_dp1:w8(0x20)
        vib_sp1:w8(0x10)
        vib_dp3:w16(0x3020)
        vib_sp3:w8(0x01)
        m3:w8(rand(1, 6))
        if r() then m4:w8(stou8(rand(-2, 8))) end
        if rand(1, 20) == 1 then
            voice_p = stou8(rand(-5, 2))
        end
        voice1:w8(voice_p)
        voice2:w8(voice_p)
        voice1p:warr({0x08, 0x20, 0x20})
        voice2p:warr({0x08, 0x20, 0x20})
    end
end)
```

イルーム2

```lua
-- 鳴りっぱなし爆音
lib.irume.start(function()
    local head = {
        0x03e07d40,
        0x03e07d40 + 0x40,
        0x03e07d40 + 0x40 * 2,
        0x03e07d40 + 0x40 * 3,
        0x03e07d40 + 0x40 * 4,
        0x03e07d40 + 0x40 * 5,
        0x03e07d40 + 0x40 * 6,
        0x03e07d40 + 0x40 * 7,
        0x03e07d40 + 0x40 * 8,

        0x03e07d40 + 0x40 * 9,
        0x03e07d40 + 0x40 * 10,
        0x03e07d40 + 0x40 * 11,
        0x03e07d40 + 0x40 * 12,
        0x03e07d40 + 0x40 * 13,
        0x03e07d40 + 0x40 * 14,
        0x03e07d40 + 0x40 * 15,
        0x03e07d40 + 0x40 * 16,
    }
    local r = RC(30)
    return function()
        for _, a in pairs(head) do
            w16(a + 0x0e, 0x1212)
            if r() then
                w8(a + 0x17, stou8(rand(-6, 6)))
            end
        end
    end
end)
```

腕をチカチカ上下させた後、奥にすっ飛ぶ

```lua
local m1 = lib.at(0x022f659a)
local c1 = Cnt(20, 2)
local c2 = Cnt(15)
local tate = lib.at(0x022f657c)
local yoko = lib.at(0x022f6580)
local tate_c = RC(2)
local yoko_c = RC(2)
local rl = RL(240)
local V = 0
function loop()
    m1:w16(c1:next() == 1 and 0xff01 or 0)
    if c2() then
        c1.n0 = math.max(c1.n0 - 1, 5)
    end
    if rl() then
        V = math.min(V + 0x5000, 0xffffff)
        -- V = math.min(V + 0x3000, 0xffffff)
        yoko:add32(V)
    else
        -- ブルブル震える(動画ではボツにした？)
        -- if tate_c() then tate:add32(rand(-0x2, 0x2) * 0x1000) end
        -- if yoko_c() then yoko:add32(rand(-0x2, 0x2) * 0x1000) end
    end
end
```

荒ぶり系

```lua
local m1 = lib.at(0x022f659a)
local c1 = Cnt(20, 2)
local c2 = Cnt(15)
local v1 = {0xff01, 0x20ff, 0xff}
local m2 = lib.at(0x022f6572)
local tate = lib.at(0x022f657c)
local yoko = lib.at(0x022f6580)
local tate_c = RC(2)
local yoko_c = RC(2)
local rl = RL(240)
local V = 0
local arabu = lib.at(0x022f6593)
function loop()
    if c1() then
        m1:w16(v1[rand(1, #v1)])
    end
    -- arabu:warr({0x33,0x33,0x33,0x33})
    -- m1:w16(0xff01)
    -- m1:w16(0x4444)

    -- m2:w16(rand(0, 0xffff)) -- 何のコードか忘れた
end
```

色変化系

```lua
function loop()
    for i = 0x023095f0, 0x0230962f, 4 do
        w32(i, rand(0, 0xffffffff))
    end
end
```


ルイージ細長&どんな気持ち煽り, キノピオおドム化

```lua
local v = 0
local t = 0
local n = 2
local rl = RL(120)
local c = Cnt(60)

function loop()
    w32(0x0217d528, 0) -- キノピオをおドム化
    w8(0x0217d419, 0x05)
    w8(0x0217d429, 0x14)
    w32(0x0217d440, 0xffffefff)
    w32(0x0217d444, 0x14000)
    if not rl() then return end
    t = t + n
    if c() then n = n + 1 end
    w32(0x0217d43c, stou32(math.sin(t / 20.0) * 0x2000))
end
```

キノピオ荒ぶり & ルイージさっ白

```lua
local r = RC(10)
local m = lib.at(0x0217d528)

function loop()
    w8(0x0228ba93, 0)
    w8(0x0217d441, 0x40)
    w32(0x0228ba30, 0)
    w32(0x0228ba60, 0)
    w8(0x0228c499, 0x40)
    if r() then
        m:w32(rand(0, 0xffff) << 8)
    end
end

lib.irume.start(function()
    local m1 = lib.at(0x03e07d4e)
    local mp1 = lib.at(0x03e07d57)
    local m2 = lib.at(0x03e07e1b)
    local m3 = lib.at(0x03e07e9b)
    local mp3 = lib.at(0x03e07e97)
    local mp4 = lib.at(0x03e07e57)
    local m4 = lib.at(0x03e07e4c)
    local c4 = Cnt(1, 2)
    return function()
        m1:w16(0x1212)
        mp1:w8(stou8(rand(-3, 3)))
        m2:w8(0x11)
        m3:w8(0x01)
        mp3:w8(stou8(rand(-3, 3)))
        mp4:w8(stou8(c4:next() * 2 - 1))
        m4:w32(0x0600000f)
    end
end)
```

ルイージフリーダムに大きさ・位置変化 & キノピオ悪い顔

```lua

local i = 0
local r = Cnt(3)


local r2 = Cnt(1)
-- local r2 = Cnt(20)

local eyes = {
    function() w8(0x0228ba7d, 0) end,
    function() w8(0x0228ba7d, 0x20) end,
    function() w8(0x0228ba7d, 0x3f) end,
    function() w8(0x0228ba7d, 0x60) end,
    function() w8(0x0228ba7d, 0x80) end,

    function() w8(0x0228ba81, 0x0c) end,
    function() w8(0x0228ba81, 0x16) end,
    function() w8(0x0228ba81, 0x13) end,
    function() w8(0x0228ba81, 0x10) end,
    function() w8(0x0228ba81, 0x03) end,
    function() w8(0x0228ba81, 0x20) end,
}
local kino_c = Cnt(4)
function loop()
    if r() then
        i = (i + 1) % 0x180
    end
    w8(0x022921b4, 0x21)
    if kino_c() then w32(0x0217d52C, 0) end
    if r2() then
        eyes[rand(1, #eyes)]()
        w8(0x0217d419, rand(1, 0x80))
        w8(0x0217d421, rand(1, 0x80))
        w8(0x0217d441, rand(1, 0x80))
        w32(0x0217d444, stou32(rand(-0x60000, 0x10000)))
    end
    -- w16(0x04000010, ((i & 0xff) << 4) | ((i & 0xff00) >> 4)) -- 背景をKGBさせる
end

lib.irume.start(function()
    local head = {
        0x03e07d40,
        0x03e07d40 + 0x40,
        0x03e07d40 + 0x40 * 2,
        0x03e07d40 + 0x40 * 3,
        0x03e07d40 + 0x40 * 4,
        0x03e07d40 + 0x40 * 5,
        0x03e07d40 + 0x40 * 6,
        0x03e07d40 + 0x40 * 7,
        0x03e07d40 + 0x40 * 8,

        0x03e07d40 + 0x40 * 9,
        0x03e07d40 + 0x40 * 10,
        0x03e07d40 + 0x40 * 11,
        0x03e07d40 + 0x40 * 12,
        0x03e07d40 + 0x40 * 13,
        0x03e07d40 + 0x40 * 14,
        0x03e07d40 + 0x40 * 15,
        0x03e07d40 + 0x40 * 16,
    }
    local r = RC(30)
    return function()
        for _, a in pairs(head) do
            w16(a + 0x0e, 0x1212)
            w8(a + 0x1a, 0x80)
            if r() then
                w8(a + 0x17, stou8(rand(-6, 6)))
            end
        end
    end
end)

```

背景を傾け & にしきかげ

```lua
w8(0x0228c48d, 0x03)

w8(0x0400100E, 0x10)

w8(0x04000240, 0xff)
w8(0x04000243, 0xff)

-- 高速化イルーム
lib.irume.start(function()
    local head = {
        0x03e07d40,
        0x03e07d40 + 0x40,
        0x03e07d40 + 0x40 * 2,
        0x03e07d40 + 0x40 * 3,
        0x03e07d40 + 0x40 * 4,
        0x03e07d40 + 0x40 * 5,
        0x03e07d40 + 0x40 * 6,
        0x03e07d40 + 0x40 * 7,
        0x03e07d40 + 0x40 * 8,

        0x03e07d40 + 0x40 * 9,
        0x03e07d40 + 0x40 * 10,
        0x03e07d40 + 0x40 * 11,
        0x03e07d40 + 0x40 * 12,
        0x03e07d40 + 0x40 * 13,
        0x03e07d40 + 0x40 * 14,
        0x03e07d40 + 0x40 * 15,
        0x03e07d40 + 0x40 * 16,
    }
    local r = RC(3)
    local m = lib.at(0x03e07d40)
    return function()
        for _, a in pairs(head) do
            if r() then
                m:with(a + 0x24):Tadd8(1, rand(-15, -3), 1)
                -- (a + 0x24, stou8(rand(-6, 6)))
            end
        end
    end
end)
```

どすこい距離 & 目がサイバー風に & 何度もおじぎ

```lua
local st = 0xa
local ed = 0x3ff

local rl = RL(150)

local n = 60

local c = Cnt(1, n + 1)

local bc = Cnt(60)
local bowing = false
local bi = 0
local b_n = 0
local function ease_in_out(x)
    local x2 = -2 * x + 2
    return x < 0.5 and 4 * x * x * x or 1 - x2 * x2 * x2 / 2.0
end
local function do_bow(n)
    bi = 0
    b_n = n
    bowing = true
end
local function update_bow()
    if not bowing then return end
    bi = bi + 1
    if bi == b_n then
        bowing = false
    end
    w32(0x0217d434, stou32(math.floor(math.sin(ease_in_out(bi / b_n) * math.pi) * (-0xf00))))
end

function loop()
    w8(0x0217d419, 0x40)
    w8(0x0217d441, 0x20)
    w8(0x0217d445, 0x70)
    w8(0x0228ba91, 0x1e)
    w8(0x0228ba92, 0x20)
    if rl() then
        local x = c:next()
        w32(0x0228ba7c, math.floor(x * x * 256 / (n * n)) * (ed - st) + (st << 8))
        update_bow()
        if (not bowing) and bc() then
            do_bow(rand(20, 60))
        end
    else
        w32(0x0228ba7c, 0x1d00)
    end
end

lib.irume.start(function()
    local m = lib.at(0x03e07eac)
    local p = lib.at(0x03e07e97)
    local r = RC(30)
    local mute1 = lib.at(0x03e07e62)
    local mute2 = lib.at(0x03e07e22)
    return function()
        if r() then
            m:w32(0x02182A93)
            p:w8(stou8(rand(-6, 6)))
        end
        mute1:w16(0)
        mute2:w16(0)
    end
end)
```

ホラーピーチにしき & 左右あらぶり

```lua

local tate = lib.at(0x022f657c)
local yoko = lib.at(0x022f6580)
local tate_c = RC(2)
local yoko_c = RC(2)
local m2 = lib.at(0x022f661c)
local m3 = lib.at(0x022f6614)
local c = Cnt(4)
local V = 0
local p1 = lib.at(0x022f678c)
local rl = RL(330)
function loop()
    p1:w32(0x22222222)
    V = math.min(V + 0x5000, 0xffffff)
    if c:next() < 2 then m2:w32(V)
    else m3:w32(V)
    end
    if rl() then
        if tate_c() then tate:add32(rand(-0x2, 0x2) * 0x1000) end
        if yoko_c() then yoko:add32(rand(-0x2, 0x2) * 0x1000) end
    end
end

lib.irume.start(function()
    local voice1 = 0x03e07e40
    local voice2 = 0x03e07e80
    local voice_p = 0xfd
    local voice_p_c = Cnt(120)
    local head = 0x03e07d40
    local as = {}
    local idxes = {0,1,2,3, 6, 7,8,9,10,11,12,13,14,15,16}
    local rl = RL(600)
    local not_yet = true
    for _, i in pairs(idxes) do as[i] = head + 0x40*i end
    return function()
        if voice_p_c() then
            voice_p = voice_p - 4
        end
        w16(voice1 + 0x0e, 0x7f7f)
        w16(voice2 + 0x0e, 0x7f7f)
        w8(voice1 + 0x17, voice_p)
        w8(voice2 + 0x17, voice_p)
        if rl() then
            if not_yet then
                not_yet = false
                print("DODO")
            end
            for _, a in pairs(as) do
                w8(a + 0x17, stou8(rand(-1, 0)))
            end
        end
    end
end)
```

## video7 首を長くしたり色々

```lua
-- 首: 2A98110 (4byte)
-- 回転 8125

local m = lib.range(0x02480000, 0x02487FFF):save()
local r = RC(60)

function loop()
    if r() then m:rollback() end
    -- 顔がバグる?
    for i = 0x2481500, 0x24815ff, 4 do

    -- for i = 0x2483000, 0x2484fff, 4 do
        if r() then w32(i, rand(0, 0xffffffff)) end
    end
end

lib.irume.start(function()
    local head = 0x03e07d40
    local as = {}
    for i = 0, 16 do
        as[i] = head + 0x40*i
    end
    -- local tone = 0x7F7F0040
    local tone = {0x40, 0x00, 0x7f, 0x7f}
    return function()
        w8(as[1] + 0x17, 24)
        w8(as[2] + 0x17, 24)
        for i = 4, 16 do
            lib.warr(as[i] + 0x06, tone)
            w8(as[i] + 0x17, stou8(-12))
        end
    end
end)

ADD_LOOP((function()
    local m = lib.at(0x02a98110)
    local v = 0x446D
    local target = 0x446D
    local r = RC(40)
    return function()
        if r() then
            target = rand(0x0, 0xFF) << 8
        end
        v = ilerp(v, target, 0.1)
        m:w16(v)
    end
end)())
```

## video9 タイトルのマリオをいじる

```lua
-- 候補1(結局使わなかった)
-- lib.fill_in(0x02aef000, 0x02afc6ff, 0x62)


lib.fill_in(0x02aee800, 0x02afc6ff, 0x02)

-- 以下、調査のためのコード。動画としてはボツ


-- lib.fill_in(0x02af4eb5, 0x02af8fff, rand(0, 0xff))
-- lib.fill_in(0x02af9000, 0x02afbfff, rand(0, 0xff))

local v = rand(0, 0xff)
-- _HEXP(v, 2)
-- 0x62, 0x37
lib.fill_in(0x02afc000, 0x02afc6ff, 0x62)

local vals = {0x62, 0x37}

local c = Cnt(2)

local f = false
function loop()
    local mouse_pos = input.getmouse()
    local _x = clamp(mouse_pos["X"], 0, 255)
    local _f = _x < 128
    CLS()
    print(tostring(_x))
    if f ~= _f then
        f = not f
        lib.fill_in(0x02afc000, 0x02afc6ff, vals[c:next() + 1])
    end
end


lib.irume.start(function()
    local head = 0x03e07d40
    local as = {}
    for i = 0, 16 do
        as[i] = head + 0x40*i
    end
    return function()
        for i = 0, 16 do
            if i == 1 or i == 11 then
                w16(as[i] + 0x1e, 0x1010)
                w8(as[i] + 0x1d, 0x10)
                w8(as[i] + 0x17, stou8(-6))
                w32(as[i] + 0x0c, 0x77777777)
                -- w32(as[i] + 0x0c, 0x11111111)
            else
                w8(as[i] + 0x17, stou8(rand(-12, 12)))
                w16(as[i] + 0x1e, 0x3010)
                w8(as[i] + 0x1d, 1)
            end
        end
    end
end)
```


## 花占い関係のメモ

```plaintext

-- 217D470あたり、花びらが勝手に消える(11で上書き)
-- 228B8E8: 50, 80, dd, 65, 66, 81(def)
-- 228B8Ea: c0, 1f(def)
-- 228B8E2: a0, 22, 43, c3(def)

-- ヨッシー崩壊
lib.fill_in(0x02480400, 0x024804ff, 0x11)

2481485 (2byte LE signed)
2481487 (2byte LE signed)


カメラの距離?
2480486 (2byte LR)

カメラの回転?
2480484 (2byte LR)

カメラの距離2?
2480750 (2byte)
2480752 (2byte)

2480730 (4byte)ヨッシーから謎の緑色の物体
```

## ヨッシー高速ズーム & 花暴走 &  高速マリオ風BGM(エンツ)

```lua

local update_zooming = (function()
    -- ここら辺のアドレスはピーチバグにも使えそう！
    local m = lib.at(0x02480752)
    local m2 = lib.at(0x02480484)
    local c = Cnt(60)
    local min1 = 1
    local max1 = 0x70ff
    local min2 = 0
    local max2 = 0x0a00
    local c2 = Cnt(120)
    local fired = false
    return function()
        local x = c:next() / c.n
        if c2() then
            fired = true
            c2.active = false
        end
        if c.fired and fired then
            fired = false
            c:N(math.max(math.floor(c.n * 0.9), 5))
            c2:N(math.max(math.round(c2.n * 0.9), 5))
            c2.active = true
            c2.i = 0
        end
        local v
        v = math.round(x*x*(max1 - min1)) + min1
        m:w16(v)

        v = math.round(x*(max2 - min2)) + min2
        m2:w16(v)
    end
end)()

local update_leaf = (function()
    local as = {}
    local vs = {}
    local xs = {}
    local ys = {}
    local _n = 11
    local add_n = 4
    local n = _n + add_n
    for i = 0, n-1 do
        as[i] = 0x0217D49C + 0x20*i
        vs[i] = {0x80000, 0x80000, 0x800}
    end
    local copy_data = lib.htob("0100000050DA0A00701205000000000000000000000000000000000032B30000")
    for i = 0, add_n-1 do
        local a = 0x0217D5D8 + 0x20*i
        lib.warr(a, copy_data)
    end
    local m = lib.at(0x02000000)
    local xmax = 0x117000
    local xmin = -0x18100
    local ymax = 0x0d0000
    local ymin = -0x12100
    local x_r = RC(60)
    local y_r = RC(60)
    local r_r = RC(60)

    -- local ready = RL(90)
    -- local ready2 = RL(340)
    local ready = RL(40)
    local ready2 = RL(90)
    return function()
        if not ready() then return end
        ready2()
        for i = 0, n-1 do
            local xa = as[i]
            local ya = as[i] + 4
            local ra = as[i] + 0x18
            if not xs[i] then xs[i] = r32(xa) end
            if not ys[i] then ys[i] = r32(ya) end
            if r_r() then
                vs[i][3] = rand(-0x40, 0x40) * 0x100
            end
            m:with(ra):add16(vs[i][3])
            if ready2.fired then
                if x_r() then
                    vs[i][1] = rand(-0x40, 0x40) * 0x800
                end
                if y_r() then
                    vs[i][2] = rand(-0x40, 0x40) * 0x800
                end
            end
            xs[i] = (xs[i] + vs[i][1]) % (xmax - xmin)
            m:with(xa):w32(stou32(xs[i] + xmin))
            ys[i] = (ys[i] + vs[i][2]) % (ymax - ymin)
            m:with(ya):w32(stou32(ys[i] + ymin))
        end
    end
end)()

function loop()
    update_zooming()
    update_leaf()
end


lib.irume.start(function()
    local head = 0x03e07d40
    local as = {}
    local cache = {}
    for i = 0, 16 do
        as[i] = head + 0x40*i
        cache[i] = 0
    end
    local c = Cnt(2)
    local m = lib.at(0x03000000)
    return function()
        c()
        for i, a in pairs(as) do
            if c.fired then
                cache[i] = -20
            end
            if cache[i] ~= 0 then
                m:with(a + 0x24)
                local v = m:r8()
                local d = math.max(cache[i], -v+1)
                cache[i] = cache[i] - d
                m:add8(d)
            end
        end
    end
end)

```

## video9 オープニング

```lua
local m2 = lib.at(0x02480486)
local min2 = 0x0e00
local max2 = 0x1f00
local c = Cnt(60)
zoom_done = false
function loop()
    if zoom_done then
        m2:w16(0x1500)
        return
    end
    local v
    local x = c:next() / c.n
    if c.fired then
        c:N(ilerp(c.n, 30, 0.2))
    end
    v = math.round(x*x*(max2 - min2)) + min2
    m2:w16(v)
end

lib.irume.start(function()
    local head = 0x03e07d40
    local prev = 0
    local as = {}
    local cache = {}
    for i = 0, 19 do
        as[i] = head + 0x40*i
    end
    return function()
        local t = r8(as[0] + 0x24)
        if prev < t then
            t = 0x10
            for i, a in pairs(as) do
                w8(a + 0x17, stou8(rand(-6, 6)))
            end
        end
        for i, a in pairs(as) do
            w8(a + 0x24, t)
        end
        prev = t
    end
end)

```


## video12 ルイージ荒ぶりなど

```lua
-- w8(0x0217D418, 0x0300) -- 太くする

local v = ValueUpdater(51, -0x4000, 0x1600)
:calc(function(obj)
    return obj:lerp(clamp(1 - math.abs(2*obj:x() - 1), 0, 1))
end)
-- :w32(0x0217D42C)
:w32(0x0217D41C)

local v2 = ValueUpdater(05, -0x2000, 0x2000)
:calc(function(obj)
    return obj:lerp(clamp(1 - math.abs(2*obj:x() - 1), 0, 1))
end)
:w32(0x0217D430)

local v3 = ValueUpdater()
:calc(function(obj)
    if rand(1, 20) == 1 then
        return stou32(rand(-3, 3) * 0x1000)
    end
end)
:w32(0x0217D418)

local i = 0
local prev = false
local rl = RL(70)
local ready = false
function loop()
    if not rl() then return end
    if not ready then
        print("READY")
        w8(0x022A5CFC, 0xf8) -- Lにしきがお

        lib.fill_in(0x02299700, 0x02299fff) -- キノピオがぺしゃんこになる
        ready = true
    end
    -- v()
    v2()
    v3()
end

--[[
雑多メモ




-- w8(0x022992CC, 0xa0) -- キノピオが駄々っ子みたいになる
-- lib.fill_in(0x022992D8, 0x0229930f, 0x11) -- キノピオが両腕を横に広げて前傾姿勢で歩く
-- lib.fill_in(0x022992D8, 0x022993af, 0x11) -- キノピオがふんぞりかえってなめ腐ったような歩き方をする

-- lib.fill_in(0x02299700, 0x02299fff) -- キノピオがぺしゃんこになる

-- local begin = 0x0229F100
-- lib.fill_in(0x02297800, 0x022978ff)
-- 22978e0: 15


local rl = RL(360)

w8(0x022992CC, 0xa0) -- キノピオが駄々っ子みたいになる
w8(0x022978e0, 0x15) -- Lも駄々っ子みたく横になって暴れる
local v = ValueUpdater(30, -0x8f00, 0xd000, function(obj)
    local x = 2*obj:x()-1
    return obj:lerp(clamp(1 - x*x, 0, 1))
end):w32(0x0217D440)

-- 217D41C, -0x1000
-- 217D420, 0x2000

function loop()
    if rl() then
        v()
    end
end

]]
```

そのときのイルーム

```lua
lib.irume.start(function()
    local head = 0x03e07d40
    local as = {}
    local prevs = {}
    for i = 0, 16 do
        as[i] = head + 0x40*i
        prevs[i] = 0
    end
    local tone = {0x42, 0x00, 0x79, 0x7f}
    local t = 0x24
    local p1 = 0x17
    return function()
        for i, a in pairs(as) do
            local _t = r8(a + t)
            if prevs[i] < _t then
                _t = rand(0x6, 0x10)
                -- ver1
                -- w8(a + p1, stou8(rand(-5, 12)))
                -- ver2
                w8(a + p1, stou8(rand(27, 50)))
            end
            w8(a + t, _t)
            prevs[i] = _t
            -- i=6: 0x03E07EC0
            if i == 6 then
                w8(a + p1, stou8(-12))
                -- ver1
                -- w8(a + 0x1d, 1)
                -- w16(a + 0x1e, 0x5050)
                -- ver2
                w8(a + 0x1d, 6)
                w16(a + 0x1e, 0x3030)
            else
                lib.warr(a + 0x06, tone)
            end
        end
    end
end)

```

## video12 ルイージなどのポリゴン頂点をいじる

```lua
-- 240F3DC -> A6, AA, B8, B2: カメラがヘンになる?(ルイージがドアップになったり)

-- w8(0x022A5CFC, 0x11) -- Lがワイヤーだけになる

-- 22b1910
-- 22AFc70あたり、キノピオのポリゴンデータ?

-- 22A7E00あたりは背景のオブジェクトのポリゴンデータ(22A9590あたりまで?)

-- local begin = 0x0229F100
local begin = 0x0229E400
-- local inclusiveEnd = 0x0229FFFF
-- local inclusiveEnd = 0x022A5CCF

local inclusiveEnd = 0x022B1B6F

-- ポリゴンデータ
--終わりはもっと長い
-- 22a2f10より後
-- 22a5cc0あたりまで

local backup = lib.range(begin - 0x10, inclusiveEnd + 0x10):save()
local backup_r = RC(20)

local vs = {
    0x2122,
    0x2223,
    0x2321,
    0x1221,
    0x4123,
}
local function found(v)
    local function _in(_v)
        for _, a in pairs(vs) do
            if a == _v then return true end
        end
        return false
    end
    local v1 = v & 0xffff
    local v2 = (v >> 16) & 0xffff
    return _in(v1) and _in(v2)
end

local r = RC(2)
local addrs ={}
local first = true
function loop()
    if backup_r() then
        backup:rollback()
    end
    local i = begin
    local __v = rand(-0x4, 0x4) * 0x100
    while i <= inclusiveEnd do
        local v = r32(i)
        i = i + 4
        if found(v) then
            if first then
            addrs[#addrs+1] = i
            end
            for j = 1, 4 do
                if j == 4 then
                    add32(i, -0x200)
                elseif j ~= 1 then
                    if r() then
                add32(i, __v + rand(-0x200, 0x200))
                    end
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

-- w8(0x022A5CFC, 0xf8) -- Lにしきがお

-- そのときのイルーム
lib.irume.start(function()
    local head = 0x03e07d40
    local as = {}
    for i = 0, 16 do
        as[i] = head + 0x40*i
    end
    local tone = {0x42, 0x00, 0x79, 0x7f}
    local t = 0x24
    local p1 = 0x17
    return function()
        for i, a in pairs(as) do
            w8(a + p1, rand(12, 24))
            w8(a + 0x1d, 1)
            w16(a + 0x1e, 0x2020)
            lib.warr(a + 0x06, tone)
        end
    end
end)
```

## ピーチの位置固定(ポリゴンいじるテストに利用するとよい)

```lua
-- ピーチの位置固定(ポリゴンいじるテストに利用するとよい)
local tate = lib.at(0x022f657c)
local yoko = lib.at(0x022f6580)
function loop()
    yoko:w32(0x480000)
    -- tate:w32(0xffe60000)
end
```
