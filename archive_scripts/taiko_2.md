
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
