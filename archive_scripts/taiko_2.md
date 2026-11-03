
# 太鼓の達人 7つの島の大冒険

video4, 残酷な天使のテーゼプレイ用(楽曲を倍速にしたり等速に戻したり)

```lua
-- 太鼓 7つの島

-- 0x03EB8CC9: speed
-- 222CA60
-- A64を00に設定すると、曲選択画面で最初から再生になる

-- 譜面の位置: 0x022AF3C4
-- 魂バー: 22AF44C
-- w8(0x022AF2E4, 0x11) -> スコアが0のまま -- or 43 -> スコアがめちゃ多くなる

-- 020DF8A0
CLS()

local m = lib.at(0x020DF8A0)
local r = RC(60)
local c = Cnt(240)
local rl = RL(120)
function loop()
    if not rl() then return end
    if c.active then
        if c() then c.active = false
        else return
        end
    end
    if r() then
        c.active = true
        print("DO")
        -- m:add32(-0x10)
        m:add32(rand(-0x70, -0x10))
    end
end

```

バンビーニプレイ用(音声崩壊 & 譜面が突然ずれる & あべこべ+太鼓アイコン消滅 & 下画面収縮)

```lua
-- 0x20で1 block

-- スコアの伸び具合を変える
w8(0x022AF2E4, 0x43)

local function change_pos1(x, y)
    local y1 = y // 8
    local y2 = y % 8
    local head = 0x06601980
    local x1 = x // 4
    local x2 = x % 4
    return head + y1 * 0x80
        + y2 * 4
        + x1 * 32
        + x2
end
local function change_pos2(x, y)
    x = 0x1f - (x - 0x10)
    local y1 = y // 8
    local y2 = y % 8
    local x1 = x // 4
    local x2 = x % 4
    local head = 0x06600300
    return head + y1 * 0x100
        + y2 * 4
        + x1 * 32
        + (3-x2)
end

-- x: 中心からの座標
local function change_pos(x, y)
    if within(x, 0, 0xf) then
        return change_pos1(x, y)
    elseif within(x, 0x10, 0x2f) then return change_pos2(x, y)
    else error("out of bound")
    end
end
local orig = {}
for i = 0x06600300, 0x066017ff do
    -- orig[i] = r8(i)
    local _i = i % 4
    orig[i] = r8((i & 0xfffffffc) + (3-_i))
end
for i = 0x06601900, 0x066023ff do
    orig[i] = r8(i)
    -- local _i = i % 4
    -- orig[i] = r8((i & 0xfffffffc) + (3-_i))
end

local function MAIN(sc)

local vs = {}
for x = 0, 0x2f do
    for y = 0, 0xa7 do
        local _x = math.floor(x*sc)
        -- local _x = x
        vs[change_pos(x, y)] = within(_x, 0, 0x2f) and orig[change_pos(_x, y)] or 0
    end
end
for i = 0x06601900, 0x066023ff, 4 do
    local _v = 0
    local V = r32(i)
    for j = 3, 0, -1 do
        _v = (_v << 8) | (vs[i + j] or ((V >> (j*8)) & 0xff))
    end
    w32(i, _v)
end
for i = 0x06600300, 0x066017ff, 4 do
    local _v = 0
    local V = r32(i)
    for j = 0, 3 do
        _v = (_v << 8) | (vs[i + j] or ((V >> ((3-j)*8)) & 0xff))
    end
    w32(i, _v)
end
end

local cnt = Cnt(60)
local d = 0.7
local function update_taiko()
    if cnt() then
        d = rand(4, 10) * 0.1
        cnt:N(rand(15, 90))
    end
    local sc = math.sin(cnt.i * math.pi / (cnt.n * 2)) * d + 1.0
    MAIN(sc)
end

local humen_ichi_r = RC(90)
local humen_ichi_addr = 0x022AF3D4
local function update_humen_ichi()
    if humen_ichi_r() then
        w32(humen_ichi_addr, r32(humen_ichi_addr) + rand(-10, 10))
    end
end

local update_speed_up_m = lib.at(0x020DF8A0)
local update_speed_up_r = RC(60)
local update_speed_up_c = Cnt(240)
local update_speed_up_rl = RL(120)
local function update_speed_up()
    if not update_speed_up_rl() then return end
    if update_speed_up_c.active then
        if update_speed_up_c() then update_speed_up_c.active = false
        else return
        end
    end
    if update_speed_up_r() then
        update_speed_up_c.active = true
        print("SPEED UP")
        -- m:add32(-0x10)
        update_speed_up_m:add32(rand(-0x70, -0x10))
    end
end


local kyoku_broken_head = 0x020DF9C8
local kyoku_broken_width = 0x780
local kyoku_broken_scale = 4
assert(kyoku_broken_width % kyoku_broken_scale == 0)
local kyoku_broken_hwidth = kyoku_broken_width // kyoku_broken_scale
local function kyoku_broken()
    for i = 0, kyoku_broken_width-1, 4 do
        local _i = kyoku_broken_head + (i % kyoku_broken_hwidth)
        w32(kyoku_broken_head + i, r32(_i))
    end
end

local shokyo_and_abekobe_r = RC(90)
local shokyo_and_abekobe_m = lib.at(0x022AA284)
local function shokyo_and_abekobe()
    if shokyo_and_abekobe_r() then
        shokyo_and_abekobe_m:w8(shokyo_and_abekobe_m:r8() == 0 and 0xdc or 0)
    end
end

local function chara_araburi()
    -- コンボふきだし
    w32(0x022364A0, 0x11)
    -- レベルアップふきだし
    w8(0x022364A4, rand(0, 0xff))
end

local pause_m = lib.at(0x0223766F)
local pause_r = RC(600)
local function update_pause()
    if pause_r() then pause_m:w8(0x77) end
end

function loop()
    update_taiko()
    update_humen_ichi()
    kyoku_broken()
    update_speed_up()
    shokyo_and_abekobe()
    chara_araburi()
    update_pause()
end

-- lib.fill_in(0x06600000, 0x066023ff)
-- lib.fill_in(0x06600600, 0x0660063f)
-- lib.fill_in(0x06601ae0, 0x06601aff)

-- 0x06600300から0x100ごと
-- 17ffまで

-- 中心: 1900から0x80ごと
```


<details>
<summary>雑多(後で消すかも)</summary>
<div>

```lua
--- ===================================


local arm9 = "ARM9 System Bus"
local arm7 = "ARM7 System Bus"

CLS()

-- 太鼓部分
-- lib.fill_in(0x06600000, 0x066023ff)
-- 
local vs = {}
for i = 0x06600000, 0x066023ff, 4 do
    vs[i] = r32(i)
end
local r = RC(20)

local function main()
    local block_size = rand(0x80, 0x100)
    local i = 0x06600000
    while true do
        if r() then
            local _i = 0x06600000 + (rand(0, 0x23ff) & 0xfffc)
            for j = 0, block_size-1 do
                w32(i, vs[_i + j*4] or 0)
                i = i + 4
                if i > 0x066023ff then return end
            end
        else
            -- w32(i, vs[i])
            for j = 0, block_size-1 do
                w32(i, vs[i])
                i = i + 4
                if i > 0x066023ff then return end
            end
        end
    end
end

function loop()
    main()
-- lib.fill_in(0x06600000, 0x066023ff, rand(0, 0xff))
-- lib.fill_in(0x04b00000, 0x04bfffff, rand(0,0xff), arm7)
-- lib.fill_in(0x09900000, 0x099fffff, rand(0, 0xff), arm9)
-- lib.fill_in(0x06f00000, 0x06ffffff, rand(0, 0xff))
-- lib.fill_in(0x020df9d0, 0x020dffff, rand(0, 0xff))
end

-- lib.fill_in(0x06000000, 0x064fffff, 0x54, arm9)
-- lib.fill_in(0x04000500, 0x040005ff, 0x54)

print("OK")

--- ===================================


-- 0x020DF9C8 -- 0x020E0147 (bound 780)


local head = 0x020DF9C8
local width = 0x780
local scale = 4
assert(width % scale == 0)
local hwidth = width // scale
function loop()
    for i = 0, width-1, 4 do
        local _i = head + (i % hwidth)
        w32(head + i, r32(_i))
    end
end

--- ===================================

-- 下画面の画像幅を調べたときの控え

-- 小block:
-- 幅 4
-- 高さ 8
-- 中心幅: 4*4 = 16
80, a0, c0, e0
w32(0x06601a60, 0)
-- w32(0x06601aa0, 0xffffff00)

--- ===================================

-- lib.fill_in(0x06601900, 0x066023ff, 0xff)

-- 幅 4
-- 高さ 8

-- 00, 20, 40, 60, 80, a0, c0, e0 -> 全体幅 = 4*8 = 32

-- w32(0x066003e0, 0x55555555)

lib.fill_in(0x06600300, 0x066017ff, 0x55555555)

--- ===================================


function loop()
    -- lib.fill_in(0x022AA270, 0x022AA27f)

    -- ふきだし制御の控え
    w32(0x02236510, 0x11)
    w8(0x02236514, rand(0, 0xff))
end
```


</div>
</details>


video5 音声にビブラートを試みる

```lua
local kyoku_broken_head = 0x020E1660
local kyoku_broken_width = 0xa00
local kyoku_broken_scale = 2
assert(kyoku_broken_width % kyoku_broken_scale == 0)
local kyoku_broken_hwidth = kyoku_broken_width // kyoku_broken_scale

local function round(x) return math.floor(x + 0.5) end

local function kyoku_broken1(scale)
    -- for i = 0, kyoku_broken_width-1, 4 do
    --     local _i = kyoku_broken_head + (round(i * scale) % kyoku_broken_width)
    --     w32(kyoku_broken_head + i, r32(_i))
    -- end
    for i = 0, kyoku_broken_width-1, 2 do
        local _i = kyoku_broken_head + (round(i * scale) % kyoku_broken_width)
        w16(kyoku_broken_head + i, r16(_i))
    end
end

-- local max_scale = 1.5
local max_scale = 1.5
local min_scale = 1.0
local c = Cnt(60)
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
    if DS.key.get("Select") then
        key_e()
        if first then first = false
        else key_e2() end
        local f = key_e.i == 1
        if prev ~= f then
            prev = f
            -- 連射機能
        DS.key.set({
            [DS_KEYS.A] = f,
            [DS_KEYS.B] = f,
            [DS_KEYS.X] = not f,
            [DS_KEYS.Y] = not f,
            [DS_KEYS.Up] = f,
            -- [DS_KEYS.Select] = true,
        })
        end
        f = key_e2.i == 1
        if prev2 ~= f then
            prev2 = f
        DS.key.set({
            [DS_KEYS.Down] = f,
            [DS_KEYS.Left] = not f,
            [DS_KEYS.Right] = not f,
            [DS_KEYS.L] = f,
            [DS_KEYS.R] = not f,
            -- [DS_KEYS.Select] = true,
        })
        end
    end
end
```

video5 本番用

```lua
CLS()


local kyoku_broken_head = 0x020E1660
local kyoku_broken_width = 0xa00
local kyoku_broken_scale = 2
assert(kyoku_broken_width % kyoku_broken_scale == 0)
local kyoku_broken_hwidth = kyoku_broken_width // kyoku_broken_scale

local function round(x) return math.floor(x + 0.5) end

local function kyoku_broken1(scale)
    -- for i = 0, kyoku_broken_width-1, 4 do
    --     local _i = kyoku_broken_head + (round(i * scale) % kyoku_broken_width)
    --     w32(kyoku_broken_head + i, r32(_i))
    -- end
    for i = 0, kyoku_broken_width-1, 2 do
        local _i = kyoku_broken_head + (round(i * scale) % kyoku_broken_width)
        w16(kyoku_broken_head + i, r16(_i))
    end
end

-- local max_scale = 1.5
local max_scale = 1.5
local min_scale = 1.0
local c = Cnt(60)
local function get_scale()
    return min_scale + c:next() * (max_scale - min_scale) / c.n
end
local function get_scale2()
    return (math.sin(c:next() * 2 * math.pi / c.n) + 1.0) * (max_scale - min_scale) + min_scale
end

local function irume1()
    kyoku_broken1(get_scale2())
end
local mode = RC(2)
local irume2_r = RC(120)
local function irume2()
    if irume2_r() then
        mode()
        min_scale = rand(100, 110) * 0.01
        max_scale = min_scale + rand(10, 20) * 0.01
        c:N(rand(10, 120))
    end
    local i = mode.i
    local scale = get_scale2()
    -- if i == 0 then scale = get_scale2()
    -- else scale = get_scale()
    -- end
    kyoku_broken1(scale)
end


local rensha_key_e = Cnt(2, 2)
local rensha_key_e2 = Cnt(2, 2)
local rensha_prev = false
local rensha_prev2 = false
local rensha_first = true
local function rensha()
    if DS.key.get("Select") then
        rensha_key_e()
        if rensha_first then rensha_first = false
        else rensha_key_e2() end
        local f = rensha_key_e.i == 1
        if rensha_prev ~= f then
            rensha_prev = f
            DS.key.set({
                [DS_KEYS.A] = f,
                [DS_KEYS.B] = f,
                [DS_KEYS.X] = not f,
                [DS_KEYS.Y] = not f,
                [DS_KEYS.Up] = f,
                -- [DS_KEYS.Select] = true,
            })
        end
        f = rensha_key_e2.i == 1
        if rensha_prev2 ~= f then
            rensha_prev2 = f
            DS.key.set({
                [DS_KEYS.Down] = f,
                [DS_KEYS.Left] = not f,
                [DS_KEYS.Right] = not f,
                [DS_KEYS.L] = f,
                [DS_KEYS.R] = not f,
                -- [DS_KEYS.Select] = true,
            })
        end
    end
end



local function change_pos1(x, y)
    local y1 = y // 8
    local y2 = y % 8
    local head = 0x06601980
    local x1 = x // 4
    local x2 = x % 4
    return head + y1 * 0x80
        + y2 * 4
        + x1 * 32
        + x2
end
local function change_pos2(x, y)
    x = 0x1f - (x - 0x10)
    local y1 = y // 8
    local y2 = y % 8
    local x1 = x // 4
    local x2 = x % 4
    local head = 0x06600300
    return head + y1 * 0x100
        + y2 * 4
        + x1 * 32
        + (3-x2)
end

-- x: 中心からの座標
local function change_pos(x, y)
    if within(x, 0, 0xf) then
        return change_pos1(x, y)
    elseif within(x, 0x10, 0x2f) then return change_pos2(x, y)
    else error("out of bound")
    end
end
local orig = {}
local function taiko_setup()
    for i = 0x06600300, 0x066017ff do
        -- orig[i] = r8(i)
        local _i = i % 4
        orig[i] = r8((i & 0xfffffffc) + (3-_i))
    end
    for i = 0x06601900, 0x066023ff do
        orig[i] = r8(i)
        -- local _i = i % 4
        -- orig[i] = r8((i & 0xfffffffc) + (3-_i))
    end
end

local function MAIN(sc, scy, signy)

local vs = {}
for x = 0, 0x2f do
    for y = 0, 0xa7 do
        local _x = math.floor(x*sc)
        local _y = signy >= 0 and y or (0xa7 - y)
        local _y = math.floor(_y*scy)
        if _x < 0 then _x = 0
        elseif _x > 0x2f then _x = 0x2f
        end
        if _y < 0 then _y = 0
        elseif _y > 0xa7 then _y = 0xa7
        end
        -- local _x = x
        vs[change_pos(x, y)] = orig[change_pos(_x, _y)] or 0
    end
end
for i = 0x06601900, 0x066023ff, 4 do
    local _v = 0
    local V = r32(i)
    for j = 3, 0, -1 do
        _v = (_v << 8) | (vs[i + j] or ((V >> (j*8)) & 0xff))
    end
    w32(i, _v)
end
for i = 0x06600300, 0x066017ff, 4 do
    local _v = 0
    local V = r32(i)
    for j = 0, 3 do
        _v = (_v << 8) | (vs[i + j] or ((V >> ((3-j)*8)) & 0xff))
    end
    w32(i, _v)
end
end

local cnt = Cnt(60)
local d = 0.7
local cnty = Cnt(60)
local dy = 0.7
local signy = 1
local update_sign = RC(60)
local update_x = RC(90)
local update_y = RC(90)

-- [0, 1]の区間を返す
local scale_funcs = {
    function(i, n)
        return math.sin(i * math.pi / (n * 2))
    end,
    function(i, n)
        return i / n
    end,
    function(i, n)
        local x = i / n
        return x + math.sin(8 * math.pi * x) / 8.0
    end,
    function(i, n)
        local x = i / n
        x = x * x
        x = x * x
        x = x * x
        return x
    end,
    function(i, n)
        local x = i / n
        return math.floor(x * 4) / 4
    end,
}
local scale_func_i = 1
local update_scale_func = RC(90)
local update_taiko_ready = false

local function update_taiko()
    if not update_taiko_ready then return end
    if update_x() then
        d = rand(4, 10) * 0.1
        cnt:N(rand(5, 90))
    end
    if update_y() then
        dy = rand(4, 10) * 0.1
        cnty:N(rand(5, 90))
    end
    if update_sign() then
        signy = -signy
    end
    if update_scale_func() then
        scale_func_i = rand(1, #scale_funcs)
    end
    cnt() cnty()
    local f = scale_funcs[scale_func_i]
    local sc = f(cnt.i, cnt.n) * d + 1.0
    local scy = f(cnty.i, cnty.n) * dy + 1.0
    MAIN(sc, scy, signy)
end






local setup_c = CntOnce(330)
local function setup()
    print("SETUP")
    w16(0x022B1180, 0x0120) -- 大ドンで 524160 になる(52149に近い)

    -- 良などを消す
    for i = 0, 7 do
    w32(0x022B0FF0 + 0x18*i, 0x022DAFA0)
    end

    update_taiko_ready = true
    taiko_setup()
end



local _i = 0
local ts = {
    60,
}

local irume1_time = 1290
local irume2_time = 1680
local irume_mode = 0
local taiko_mute = CntOnce(490)
local taiko_unmute = CntOnce(5090)

function loop()
    if setup_c() then setup() end
    update_taiko()
    if taiko_mute() then
    w32(0x0208ed68, 0xffffffff) -- 太鼓の音を消す
    end
    if taiko_unmute() then
        print("UNMUTE")
    w32(0x0208ed68, 0xE3A00000) -- 太鼓の音を消す
    end
    rensha()
    _i = _i + 1
    if _i == irume1_time then
        irume_mode = 1
        print("IRUME1")
    elseif _i == irume2_time then
        irume_mode = 2
        print("IRUME2")
    end
    if irume_mode == 1 then
        irume1()
    elseif irume_mode == 2 then
        irume2()
    end
    for _, t in pairs(ts) do
        if _i == t then
            DS.key.set("A", true) break
        elseif _i == t + 10 then
            DS.key.set("A", false) break
        end
    end
end
```

SELECT押した間の曲データを取得してテキストファイルに書き込む

```lua
local span = 60

CLS()

local kyoku_broken_head2 = 0x020DF9C8
local kyoku_broken_width2 = 0x780

local kyoku_broken_head = 0x020E1660
local kyoku_broken_width = 0xa00

local _i = 0
local cache = {}
local cache2 = {}

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
            local file = io.open(--[[ <ファイルの絶対パス> ]], "w")
            local text = "local DATA = {\n" .. table.concat(cache, "\n") .. "\n}"
            file:write(text)
            file:flush()
            file:close()
        else
            local d = {}
            for i = 0, kyoku_broken_width-1 do
                d[i+1] = string.format("%02X", r8(kyoku_broken_head + i))
            end
            local s = table.concat(d, "")
            cache[_i] = "lib.htob(\"" .. s .. "\"),"
        end
    elseif DS.key.get("Select") then
        print("RECORD START")
        recording = true
    end
end
```

くじけそうになった(音MAD的なヤツ) & 上画面崩壊
(※データ部分は膨大なため省略)

```lua
local kyoku_broken_head = 0x020E1660
local kyoku_broken_width = 0xa00

CLS()

local _i = 0
local actions = {
    {250, 1},
    -- {280, 0},
    -- {300, 1},
    {460, 0},
    -- {140, 0},
    {600, 2},
    {755, 3},
    {1020, -1},
}
local actions_i = 1
local tone_k = 0
local tone_i = 0

local function get_tone(i)
    if i == 1 then return DATA_AAAAAAAA
    elseif i == 2 then return DATA_kujikesou
    else return DATA_last
    end
end

local humen_ichi_addr = 0x022AF3D4
local _vv2 = 0x83
local _vv2_r = RC(1)
local _vv1 = 0x83
local _vv1_r = RC(1)
local vs1 = {0x8b, 0x80, 0x9b}
local vs2 = {0x83, 0x80}

local function update_gra(i)
    if i <= 260 then return end
    if i > 1000 then
        w16(0x04000240, 0)
        return
    end
    if _vv2_r() then _vv2 = vs2[rand(1, #vs2)] end
    w8(0x04000241, _vv2)
    if i > 550 then
        if _vv1_r() then _vv1 = vs1[rand(1, #vs1)] end
        w8(0x04000240, _vv1)
    end
end

function loop()
    _i = _i + 1
    update_gra(_i)
    if _i > 1100 then
        w32(humen_ichi_addr, 0x3000)
    elseif _i > 260 then
        w32(humen_ichi_addr, rand(0x0d30, 0x0d60))
        -- w32(humen_ichi_addr, rand(0x80, 0x1160))
    end
    if actions_i <= #actions then
        local a = actions[actions_i]
        if _i >= a[1] then
            actions_i = actions_i + 1
            tone_k = a[2]
            tone_i = 0
        end
    end
    if tone_k == 0 then return end
    if tone_k < 0 then
        for i = 0, kyoku_broken_width-1, 4 do
            w32(kyoku_broken_head + i, 0)
        end
        return
    end
    local tone = get_tone(tone_k)
    tone_i = (tone_i % #tone) + 1
    local d = tone[tone_i]
    for i = 0, kyoku_broken_width-1 do
        w8(kyoku_broken_head + i, d[i + 1])
    end
end
```

## 雑多メモ

```lua
-- スコアの伸び具合を変える
w16(0x022B1180, 0x06ff)

-- w8(0x022AF2E4, 0x43)
-- w8(0x022AF2E4, 0x41) -- フリーズ
-- w8(0x022AF2E4, 0x55) -- オートモード
-- 64112B02

-- 0x022B1180 -> 1打分のスコア
-- 0x022B1184 -> オートモードか否か
-- w16(0x022B1180, 0x06ff)
w16(0x022B1180, 0x2001) -- 大ドンで 524160 になる(52149に近い)
-- 1820
-- 3640
-- 910

for i = 0, 7 do
w32(0x022B0FF0 + 0x18*i, 0x022DAFA0)
end

-- =================================
-- =================================
-- =================================


-- ROM領域に、「アンパンマン」という文字コードはやっぱりなさそう
-- local b = lib.htob("8341839383708393837d8393")
-- local b = lib.htob("a230f330d130f330de30f330")
-- local b = lib.htob("30a230f330d130f330de30f3")
local b = lib.htob("e382a2e383b3e38391e383b3e3839ee383b3")

CLS()
-- lib.findr(0x00000000, 0x03ffffff, b)


```

```
以下のアドレスをいじってキャラを高速にできる
228F7AC:
59 00 00 00
<anim time>
80 00 00 00 C0 00 00 00 00 00 80 3F 00 00 80 3F
<x座標>     <y座標>        <width>    <height>
08 00 00 00 00 00 00 00 8B 05 00 00
```

## アンパンの譜面を改造する(試験段階)

```lua

local data = lib.image.lz77.decompress(0x00983200, false)
-- local s = table.concat(Array.map(data, function(v) return _HEX(v, 2, true) end), "")
local len = #data
local out = {}
for i = 1, len do out[i-1]=data[i] end
local function main(v, i)
    if i < 0x1930 then
        if v & 0xf0 == 0xA0 then
            return 0x37
        end
        return
    end
    local num = 0x8
    if v == 0xff or v == 0 then return end
    -- if v == 0x14 then return 0x50 end
    if v == 0x7 then for j=9,15 do out[i+j]=0 end out[i+8]=num out[i+12]=0x78 out[i+13]=0x0b return 0xa end
    if v == 0x1 then for j=9,15 do out[i+j]=0 end out[i+8]=num out[i+12]=0x78 out[i+13]=0x0b return 0xa end
    if v == 0x2 then for j=9,15 do out[i+j]=0 end out[i+8]=num out[i+12]=0x78 out[i+13]=0x0b return 0xa end
    if v == 0x3 then for j=9,15 do out[i+j]=0 end out[i+8]=num out[i+12]=0x78 out[i+13]=0x0b return 0xa end
    if v == 0x4 then for j=9,15 do out[i+j]=0 end out[i+8]=num out[i+12]=0x78 out[i+13]=0x0b return 0xa end
    if v == 0x5 then for j=9,15 do out[i+j]=0 end out[i+8]=num out[i+12]=0x78 out[i+13]=0x0b return 0xa end
    if v == 0xa then for j=9,15 do out[i+j]=0 end out[i+8]=num out[i+12]=0x78 out[i+13]=0x0b return 0xa end
    if v == 0x6 then for j=9,15 do out[i+j]=0 end out[i+8]=num out[i+12]=0x78 out[i+13]=0x0b return 0xa end
    -- if v==6 then return 6 end
    -- if v == 0x6 then
    --     out[i+12] = 0x44
    --     out[i+13] = 0x44
    -- end
    -- return rand(0, 0x2A)
end

local _out2 = {}
local i = 0
while true do
local v = out[i]
for _ = 1, 1 do
    -- if i == 0 then out[0] = 0x30 end
    if i < 0x1938 then
        if v & 0xf0 == 0xA0 then
            -- out[i] = 0x37
        end
        break
    end
    -- local num = 0x1
    local num = 0x2
    if v == 0xff or v == 0 then break end
    -- if v == 0x14 then return 0x50 end
    if (
        v == 0x7
        or v == 0x1
        or v == 0x2
        or v == 0x3
        or v == 0x4
        or v == 0x5
        or v == 0x6
        or v == 0xa
    ) then
    -- 7が大ドン, 8が大カツ, aが風船, 6が連打
        -- 風船だらけにする
        out[i] = 0xa
        i = i + 8
        for j = 0, 7 do
            out[i+j] = 0
        end
        if i-8==0x31F8 then
            out[i] = 1
        elseif i-8==0x31D8 then
            out[i] = 0x60
        elseif v == 0xa or v == 0x7 or v == 0x6 then
            out[i] = 0x07
            out[i+1] = 0x1
        else
            out[i] = num
        end
        out[i+4] = 78
        -- out[i+5] = 0xb
        out[i+5] = 0x24
        -- out[i+5] = 0x40
        -- 風船を落とすまでの時間
        i = i + 8
        i = i - 1
        break
    end
end
i = i + 1
if i > len-1 then break end
end

for i = 0, len-1 do _out2[i+1] = out[i] end
lib.romwarr(0x00983200, lib.image.lz77.compress(_out2))
-- local file = io.open(lib.path.output("taiko_anpan.dat"), "wb")
-- file:write(longchars(data))
-- file:close()

```

## EKiBEN でんでん祭り & キャラ拡大、高速化

```lua
local function change_humen(addr, offset)
local data = lib.image.lz77.decompress(addr, false)
-- local s = table.concat(Array.map(data, function(v) return _HEX(v, 2, true) end), "")
local len = #data
local out = {}
for i = 1, len do out[i-1]=data[i] end

local _out2 = {}
local i = 0
while true do
local v = out[i]
for _ = 1, 1 do
    -- if i == 0 then out[0] = 0x30 end
    if i < offset then
        if v & 0xf0 == 0xA0 then
            -- out[i] = 0x37
        end
        break
    end
    if i < 0x7578 then break end
    -- local num = 0x1
    local num = 0x2
    if v == 0xff or v == 0 then break end
    -- if v == 0x14 then return 0x50 end
    if (
        v == 0x7
        or v == 0x1
        or v == 0x2
        or v == 0x3
        or v == 0x4
        or v == 0x5
        or v == 0x6
        or v == 0x8
        or v == 0x9
        or v == 0xa
        or v == 0xb
        or v == 0xd
    ) then
    -- 7が大ドン, 8が大カツ, aが風船, 6が連打
        -- 風船だらけにする
        -- out[i] = 0xa
        -- out[i] = 0xc
        out[i] = rand(1,4)==1 and 0xa or 0xc
        if within(i, 0x8800, 0x8F00) then
            out[i] = 0xc
        end
        i = i + 8
        for j = 0, 7 do
            out[i+j] = 0
        end
        if i-8==0x31F8 then
            out[i] = 1
        elseif i-8==0x31D8 then
            -- out[i] = 0x60
            -- out[i] = num
            out[i] = rand(1, 2)
        elseif v == 0xa or v == 0x7 or v == 0x6 then
            -- out[i] = 0x07
            -- out[i+1] = 0x1
            out[i] = rand(1, 2)
        else
            out[i] = rand(1, 2)
        end
        out[i+4] = 78
        -- out[i+5] = 0xb
        out[i+5] = 0x24
        -- out[i+5] = 0x40
        -- 風船を落とすまでの時間
        i = i + 8
        i = i - 1
        break
    end
end
i = i + 1
if i > len-1 then break end
end

for i = 0, len-1 do _out2[i+1] = out[i] end
lib.romwarr(addr, lib.image.lz77.compress(_out2))
end


-- change_sound()
-- change_humen(0x00983200, 0x1938)
change_humen(0x00a00800, 0x3E68)
-- w16r(0x0081C96A, 0x1111) -- スコアの一部をかいめつ

-- 踊り子をアラブらセル
w8(0x0228F788, 0x06)
w8(0x0228F78C, 0x20)
w16(0x0228F796, 0x4080)
w16(0x0228F79A, 0x4040)

w8(0x0228F7AC, 0x04)
w16(0x0228F7BA, 0x4080)
w16(0x0228F7BE, 0x4040)

w8(0x0228F7D0, 0x11)
w8(0x0228F7D4, 0xe0)
w16(0x0228F7DE, 0x4080)
w16(0x0228F7E2, 0x4040)

-- メカどんの位置を調整
w32(0x0228FF48, 0xFFFFFF40)
w32(0x0228FF4C, 0xFFFFFFC0)
w16(0x0228FF52, 0x4041)
w16(0x0228FF56, 0x3FA0)

```

## アンパンの音源をカオスにする

```lua

-- ==============================
-- ========== 本番用 ============
-- ==============================

-- lib.fill_inr(0x028a0000, 0x028bb09f)
-- lib.fill_inr(0x028a0000, 0x028b809f)
local function change_sound()
local begin = 0x02844AD8
local iend = 0x028BB1FF
local begin2 = 0x028BE680
local r = RC(10)
local d = 0
-- https://github.com/oct0xor/taiko_no_tatsujin_ds_custom_songs/blob/master/taiko_music/main.cpp#L105 より
-- 太鼓の音源はSiren14（ITU-T G.722.1 Annex C）フォーマットに従っており、1サンプルのデータは0x78らしい
-- https://github.com/XyLe-GBP/PolyTool でもITU G.722.1をdecodeできるみたいだが、もしかすると太鼓とは互換性ないかも
local step = 0x78
local vs = {}
local spd = 1
local i_st = 0
for i = begin, iend do
    vs[i] = r8r(i)
end
for i = begin, iend, step do
    if r() then
        if i < begin + 0x1000 then
            -- do nothing
        elseif i < begin+0x30000 then
            d = rand(0x1, 0x40)*0x10
        elseif i > iend - 0x30000 then
            d = rand(-0x40, -0x1)*0x10
        else
            d = rand(-0x10, 0x10)*0x60
        end
        spd = rand(1, 4) == 1 and 2 or 1
        i_st = ( (i-begin)//step ) + d
    end
    -- local j = (i-begin+d)%(iend-begin)+begin
    -- local j = (i-begin)//2+begin

    -- if d then
    --     w32r(i, r32r(i - begin + begin2))
    -- else
    --     w32r(i, r32r(i))
    -- end
    -- if i > begin+ 0x1000 then
    local _i = ( (i-begin)//step ) + d
    assert(within(_i, 0, (iend-begin)//step), "out of bound of _i")
    if spd == 2 then
        local _i2 = (_i-i_st)*2+i_st
        if within(_i2, 0, (iend-begin)//step) then
            _i = _i2
        end
    end
    _i = _i * step + begin
        for j = 0, step-1 do
            local _j = j
            -- local v = r8r((i-begin)*2+begin+_j)
            local v = assert(vs[_i+_j])
            w8r(i+j, v)
        end
    -- end

    -- w32r(i, r32r(i)+rand(1,2)*0x10000000)
end
end


local function change_humen(addr, offset)
local data = lib.image.lz77.decompress(addr, false)
-- local s = table.concat(Array.map(data, function(v) return _HEX(v, 2, true) end), "")
local len = #data
local out = {}
for i = 1, len do out[i-1]=data[i] end

local _out2 = {}
local i = 0
while true do
local v = out[i]
for _ = 1, 1 do
    -- if i == 0 then out[0] = 0x30 end
    if i < offset then
        if v & 0xf0 == 0xA0 then
            -- out[i] = 0x37
        end
        break
    end
    -- local num = 0x1
    local num = 0x2
    if v == 0xff or v == 0 then break end
    -- if v == 0x14 then return 0x50 end
    if (
        v == 0x7
        or v == 0x1
        or v == 0x2
        or v == 0x3
        or v == 0x4
        or v == 0x5
        or v == 0x6
        or v == 0x8
        or v == 0x9
        or v == 0xa
        or v == 0xb
        or v == 0xd
    ) then
    -- 7が大ドン, 8が大カツ, aが風船, 6が連打
        -- 風船だらけにする
        out[i] = 0x9
        -- if within(v, 1, 9) then
        --     local _d = {1,2,3,4,5}
        --     out[i] = _d[rand(1, #_d)]
        --     out[i+4] = clamp(out[i+4]+rand(-0x10,0x10), 0, 0x20)
        -- end
        i = i + 8
        i = i + 8
        i = i - 1
        break
        for j = 0, 7 do
            out[i+j] = 0
        end
        if i-8==0x31F8 then
            out[i] = 1
        elseif i-8==0x31D8 then
            out[i] = 0x60
            out[i] = num
        elseif v == 0xa or v == 0x7 or v == 0x6 then
            out[i] = 0x07
            out[i+1] = 0x1
        else
            out[i] = num
        end
        out[i+4] = 78
        -- out[i+5] = 0xb
        out[i+5] = 0x24
        -- out[i+5] = 0x40
        -- 風船を落とすまでの時間
        i = i + 8
        i = i - 1
        break
    end
end
i = i + 1
if i > len-1 then break end
end

for i = 0, len-1 do _out2[i+1] = out[i] end
lib.romwarr(addr, lib.image.lz77.compress(_out2))
end


change_sound()
change_humen(0x00983200, 0x1938)
-- change_humen(0x00a00800, 0x3E68)
w16r(0x0081C96A, 0x1111) -- スコアの数字の一部をかいめつ

-- 踊り子をアラブらセル
w8(0x0228F788, 0x06)
w8(0x0228F78C, 0x20)
w16(0x0228F796, 0x4080)
w16(0x0228F79A, 0x4040)

w8(0x0228F7AC, 0x04)
w16(0x0228F7BA, 0x4080)
w16(0x0228F7BE, 0x4040)

w8(0x0228F7D0, 0x11)
w8(0x0228F7D4, 0xe0)
w16(0x0228F7DE, 0x4080)
w16(0x0228F7E2, 0x4040)

-- メカどんの位置を調整
w8(0x0228FF44, 0x04)
w32(0x0228FF48, 0xFFFFFF20)
w32(0x0228FF4C, 0xFFFFFF40)
w16(0x0228FF52, 0x4081)
w16(0x0228FF56, 0x4040)
```
