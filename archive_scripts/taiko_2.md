
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
