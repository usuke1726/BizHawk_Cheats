
# お料理ナビ

発話文字を強引に変更(フリーズ率高め)

```lua
local preset = {
-- {0x73, 0x14, 0x3b, 0x00, 0x00, 0x10, 0x2a, 0x3b},
{0x00, 0x00, 0x11, 0x00, 0x00, 0x11, 0x21, 0x00}, -- 「あ」？
-- {0x2a, 0x00, 0x0a, 0x00, 0x00, 0x0a, 0x15, 0x00}, -- 「い」？
}

local is_first = false
local values = {}
local function all_zero(addr)
    for i = 0, 7 do
        if r8(addr + i) ~= 0 then return false end
    end
    return true
end
function loop()
    if is_first then
        is_first = false
        for i = 0x2211c000, 0x2211ffff, 8 do
            -- if r8(i) ~= 0 then
            if not all_zero(i) then
                local news = {}
                for j = 0, 7 do
                    news[j + 1] = r8(i+j)
                end
                values[#values+1] = news
                -- w8(i, rand(1, 0xff))
            end
        end
    end
    for i = 0x2211b700, 0x2211ffff, 8 do
        if not all_zero(i) then
        -- if r8(i) ~= 0 then
            -- local n = values[rand(1, #values)]
            local n = preset[rand(1, #preset)]
            for j = 0, 7 do
                w8(i + j, n[j + 1])
            end
        end
    end
end
```


発話文字を強引に変更 その2(フリーズ率高め)

```lua
local function all_zero(addr)
    for i = 0, 7 do
        if r8(addr + i) ~= 0 then return false end
    end
    return true
end

local A = {0x00, 0x00, 0x11, 0x00, 0x00, 0x11, 0x21, 0x00}

local addrs = {
0x03eb9227,
0x03eb9267,
0x03eb92A7,
0x03eb92E7,
0x03eb9327,
0x03eb9367,
0x03eb93A7,
0x03eb93E7,
0x03eb9427,
0x03eb9477,
0x03eb94A7,
0x03eb94E7,
0x03eb9527,
0x03eb9567,
0x03eb95A7,
}
function loop()
    for i = 1, #addrs do
        if rand(1, 30) == 1 then
            w8(addrs[i], rand(0, 8))
        end
        if rand(1, 30) == 1 then
            w8(addrs[i]+3, rand(0, 8))
        end
        -- if rand(1, 60) == 1 then
        --     w8(addrs[i] + 4, stou8(rand(-5, 5)))
        -- end
        if rand(1, 60) == 1 then
            -- 00, 04, 07, 08
            w8(addrs[i] - 0x11, rand(1, 8))
        end
    end
    -- for a = 0x023cf400, 0x023cffff do
    --     if within(r8(a), 0x10,0x1f) then
    --     w8(a, rand(0x10, 0x1f))
    --     end
    -- end
    -- w16(0x023cff24, rand(0, 0xffff))
        -- w8(addr, rand(0, 8))
    -- end
    -- w16(0x023d0852, rand(0, 0xffff))

    -- for i = 0x0211b700, 0x0211bfff, 8 do
    --     if not all_zero(i) and rand(1, 10) == 1 then
    --     -- if r8(i) ~= 0 then
    --         -- local n = values[rand(1, #values)]
    --         for j = 0, 7 do
    --             w8(i + j, A[j + 1])
    --         end
    --     end
    -- end
end
```


色々試行錯誤

```lua
-- 「ください」
-- SJIS: lib.htob("82ad82be82b382a2")

-- FOUND 0x003A6D03 (ROM)

-- lib.findr(0x00300000, 0x003FFFFF, lib.htob("82ad82be82b382a2"))

-- _, addrs1 = lib.find_all(0x02000000, 0x02ffffff, lib.htob("82bb"), nil, true)
-- _, addrs2 = lib.find_all(0x02000000, 0x02ffffff, lib.htob("82ea"), nil, true)

-- print(string.format("found %d, %d", #addrs1, #addrs2))

local chars = {}
for i = 0x4f, 0x58 do chars[#chars+1] = i end
for i = 0x60, 0x79 do chars[#chars+1] = i end
for i = 0x81, 0x9a do chars[#chars+1] = i end
for i = 0x9f, 0xf1 do chars[#chars+1] = i end

-- local i = 0x02345f00
-- while i < 0x02345f2f do
local i = 0x02345000
while i < 0x023fffff do
    local v1 = r8(i)
    local v3 = r8(i + 2)
    if v1 == 0x82 and v3 == 0x82 then
        w8(i + 1, chars[rand(1, #chars)])
        w8(i + 3, chars[rand(1, #chars)])
        i = i + 3
    end
    i = i + 1
end

-- for _, i in pairs(addrs1) do
--     for _, j in pairs(addrs2) do
--         if math.abs(i - j) <= 0x20 then
--             print(string.format("NEAR (%08X, %08X)", i, j))
--         end
--     end
-- end

-- for _, ad in pairs(addrs) do
--     local a = {}
--     for i = 0, 7 do
--         a[#a+1] = _HEX(r8(ad + i), 2, true)
--     end
--     print(string.format("0x%08X: %s", ad, table.concat(a, " ")))
-- end

-- lib.find(0x02000000, 0x02ffffff, lib.htob("82bb82ea"))
-- lib.find(0x03000000, 0x03ffffff, lib.htob("82bb82ea82c582cd"))

-- sjis.print_range(0x003a2e41, 0x003a6d9d, ROM_DOMAIN_NAME)
-- sjis.print_range(0x003a6cd0, 0x003a6d3d, ROM_DOMAIN_NAME)


--- ==================================
--- ==================================
--- ==================================

local cache = {}

local i = 0
local is_replaying = false
local r = RC(45)
local r2 = RC(20)

local function is_speak_end()
    return r32(0x023C0620) == 0xffffffff
end

local prev = {}

local function diff_data(arr)
    if #prev ~= #arr then return true end
    local n = #prev
    for i = 1, n do
        if prev[i] ~= arr[i] then return true end
    end
    return false
end

function loop()
    if r() then
        is_replaying = not is_replaying
        if is_speak_end() then
            is_replaying = true
        end
        i = 0
    end
    i = i + 1
    if is_replaying then
        if cache[i] then
            lib.warr(0x023C0620, cache[i])
            if r2() then i = 0 end
        else
            i = 0
        end
    else
        if not is_speak_end() then
            local tmp = lib.rarr(0x023C0620, 0x023C18DF)
            if diff_data(tmp) then
                cache[i] = tmp
                prev = table_copy(tmp)
            end
        end
    end
    -- lib.fill_in(0x023C0620, 0x023C18DF)
end
```


```plaintext
23C05A0

0x023C05A9 => 21
0x023C05F8 => 00

0x023C0620 -- 0x023C18DF
```


辻先生ボイス波形をレコーディング

```lua
local FILE_PATH = "<絶対パス>"
local span = 60

CLS()

local kyoku_broken_head = 0x023C0620
local kyoku_broken_width = 0x12c0

local _i = 0
local cache = {}
local cache2 = {}

local recording = false
local finished = false

function loop()
    if finished then return end
    if recording then
        _i = _i + 1
        if not DS.key.get("Select") then
            print("RECORD FINISH")
            finished = true
            local file = io.open(FILE_PATH, "w")
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


ピーマン連打 & 画面崩壊 & イルーム

```lua
local r = RC(30)
local r2 = RC(45)
local c = Cnt(45)
local active = false
local i = 0

local data = {
    DATA_Piman_hi,
    DATA_Piman_norm,
    DATA_Piman_fast,
    DATA_Piman_low_slow,
}
local cdata

local function update_voice()
    if r() or c() then
        w8(0x023C1904, rand(0x50, 0xa0))
        w8(0x023C1901, rand(0x01, 0x3f))
        cdata = data[rand(1, 4)]
        n = #cdata
        c.i = 0
        active = true
        i = 0
    end
    if active then
        i = i + 1
        if i <= n then
            lib.warr(0x023C0620, cdata[i])
        else active = false
        end
        active = not r2()
    end
end


function loop()
    update_voice()
end




lib.irume.start(function()
    local head = 0x03EB9210
    local as = {}
    for i = 0, 14 do as[i] = head + 0x40*i end
    local p1 = 0x0a
    local p2 = 0x17
    local t = 0x24
    local vol = 0x0e
    local hat1 = 0x1a
    local hat2 = 0x1b
    local hat3 = 0x1c -- 大きくすると遅くなる
    local r = RC(40)
    local m = lib.at(head)
    local hat_preset = {
        {0x20, 0xf3, 0x60},
        {0x20, 0xfa, 0x60},
        {0x50, 0x01, 0x00},
    }
    -- 20 F3(FA) 60 -- ゆっくり上昇
    return function()
        for _, a in pairs(as) do
            if r() then w8(a+p1, rand(0, 0xff)) end
            if r() then w8(a+p2, stou8(rand(-5, 5))) end
            if r() then w8(a+vol, rand(0, 0x50)) end
            if r() then m:with(a+t):Tadd8(1, rand(-2, 2), 1) end
            if r() then
                if rand(1, 2) == 1 then
                    w8(a+hat1, 0)
                    w8(a+hat2, 0)
                    w8(a+hat3, 0)
                else
                    if rand(1, 4) == 1 then
                        w8(a+hat1, rand(0, 0xff))
                        w8(a+hat2, rand(0, 0xff))
                        w8(a+hat3, rand(0, 0xff))
                    else
                        local pre = hat_preset[rand(1, #hat_preset)]
                        w8(a+hat1, pre[1])
                        w8(a+hat2, pre[2])
                        w8(a+hat3, pre[3])
                    end
                end
            end
        end
    end
end)



--下画面背景
-- lib.fill_in(0x06000000, 0x060fffff)

-- 上画面背景
-- lib.fill_in(0x06200000, 0x06200fff)

local orig = {}

local function setup()
    for i = 0x06201800, 0x0620186f do
        orig[i] = r8(i)
    end
end

setup()

local bg_backup = lib.range(0x06204000, 0x062040ff):save()
local function text_bug()
    local vs = {}
    local d = rand(-0x60, 0x60)
    for i = 0x06201800, 0x0620186f do
        vs[i] = orig[i + d]
    end
    for i = 0x06201800, 0x0620186f, 4 do
        local v = 0
        for j = 0, 3 do
            local _i = i + 3 - j
            v = (v << 8) | (vs[_i] or r8(_i))
        end
        w32(i, v)
    end
    local function go(st, ed, r_n)
        local vs = {}
        local head = 0x06201800
        local d = rand(-0x100, 0x100)
        local __i = -1
        local __r = RC(60)
        for i = st, ed do
            __i = __i + 1
            if __i > 0x6f or __r() then __i = 0 end
            vs[i] = orig[head + i + d]
        end
        for i = st, ed do
            local v = 0
            for j = 0, 3 do
                local _i = i + 3 - j
                v = (v << 8) | (vs[_i] or r8(_i))
            end
            w32(i, v)
        end
    end
    go(0x06202000, 0x06202fff)
    go(0x06201870, 0x062018ff)
    go(0x06204000, 0x062040ff)
    if rand(1, 10) == 1 then
        bg_backup:rollback()
    end
end

local bottom_bk = lib.range(0x06400000, 0x06409fff):save()
local function update_bottom()
    if rand(1, 4) == 1 then
        bottom_bk:rollback()
        return
    end
    local r = RC(2)
    if r() then
        local vs = {
            0x43, 0xff, 0x0f, 0x20
        }
        lib.fill_in(0x06400000, 0x06409fff, vs[rand(1, #vs)])
    end
    if r() then bottom_bk:rollback() end
    for i = 0x06400000, 0x06409fff, 4 do
        local _i = i
        if r() then
            if r() then _i = _i ~ 0x1000 end
            if r() then _i = _i ~ 0x700 end
            if r() then _i = _i ~ 0xf0 end
            w32(i, r32(_i))
        end
    end
end

local update_sprites = (function()
    local mic_bk = lib.range(0x06600000, 0x06600fff):save()
    local tsuji_bk = lib.range(0x06601000, 0x06606fff):save()
    local no_bk = lib.range(0x06607000, 0x06607fff):save()
    local no_max_bk = lib.range(0x06608000, 0x066082ff):save()
    local line_bk = lib.range(0x06608800, 0x066089ff):save()
    local migiue_no_bk = lib.range(0x06608a00, 0x06608aff):save()
    local pic_bk = lib.range(0x0660a000, 0x0660e1ff):save()
-- mic: 0x06600000, 0x06600fff
-- tsuji: 0x06601000, 0x06606fff
-- no.: 0x06607000, 0x06607fff
-- no.max: 0x06608000, 0x066082ff
-- no.bg: 0x06608300, 0x066087ff
-- line: 0x06608800, 0x066089ff
-- migiue no. 0x06608a00, 0x06608aff
-- pic: 0x0660a000, 0x0660e1ff
    local r = RC(20)
    local rol = RC(60)
    local bks = {
        mic_bk,
        tsuji_bk,
        no_bk,
        no_max_bk,
        line_bk,
        migiue_no_bk,
        pic_bk
    }
    local r2 = RC(60)
    local function go(st, ed, change_i)
        if not r() then return end
        local _i = 0
        for i = st, ed, 4 do
            if _i < st then _i = i else _i = _i + 4 end
            _i = change_i(_i)
            w32(i, r32(_i))
        end
    end
    return function()
        for _, b in pairs(bks) do
            if rol() then b:rollback() end
        end
        go(0x06601000, 0x06606fff, function(_i)
            if r2() then _i = _i ~ 0x1000 end
            if r2() then _i = _i ~ 0x2000 end
            if r2() then _i = _i ~ 0x800 end
            return _i
        end)
        go(0x06600000, 0x06600fff, function(_i)
            if r2() then _i = _i ~ 0x100 end
            if r2() then _i = _i ~ 0x200 end
            if r2() then _i = _i ~ 0x80 end
            return _i
        end)
        go(0x06607000, 0x06607fff, function(_i)
            if r2() then _i = _i ~ 0x100 end
            if r2() then _i = _i ~ 0x200 end
            if r2() then _i = _i ~ 0x80 end
            return _i
        end)
        go(0x06608000, 0x066082ff, function(_i)
            if r2() then _i = _i ~ 0x80 end
            if r2() then _i = _i ~ 0x40 end
            return _i
        end)
        go(0x06608800, 0x066089ff, function(_i)
            if r2() then _i = _i ~ 0x40 end
            if r2() then _i = _i ~ 0x20 end
            return _i
        end)
        go(0x06608a00, 0x06608aff, function(_i)
            if r2() then _i = _i ~ 0x40 end
            if r2() then _i = _i ~ 0x20 end
            return _i
        end)
        go(0x0660a000, 0x0660e1ff, function(_i)
            if r2() then _i = _i ~ 0x800 end
            return _i
        end)
    end
end)()

local r = RC(10)
local r_bt = RC(10)
SET_LOOP(1, function()
    if r() then text_bug() end
    if r_bt() then
        update_bottom()
    end
    update_sprites()
end)

-- lib.fill_in(0x06201800, 0x0620186f)
-- lib.fill_in(0x06202000, 0x06202fff)
```


```lua

-- 太鼓の達人の波形も使うバージョン

local r = RC(60)
local r2 = RC(45)
local c = Cnt(90)
local active = false
local i = 0

local data = {
    DATA_Piman_hi,
    DATA_Piman_norm,
    DATA_Piman_fast,
    DATA_Piman_low_slow,
    -- DATA_AAAAAAAA,
    DATA_kujikesou,
    DATA_last,
}
local data_n = #data
local cdata

local function update_voice()
    if r() or c() then
        w8(0x023C1904, rand(0x50, 0xa0))
        w8(0x023C1901, rand(0x01, 0x3f))
        cdata = data[rand(1, data_n)]
        n = #cdata
        c.i = 0
        active = true
        i = 0
    end
    if active then
        i = i + 1
        if i <= n then
            lib.fill_in_arr(0x023C0620, 0x023C0620 + 0x12bf, cdata[i])
        else active = false
        end
        active = not r2()
    end
end

function loop()
    update_voice()
end

lib.irume.start(function()
    local head = 0x03EB9210
    local as = {}
    for i = 0, 14 do as[i] = head + 0x40*i end
    local p1 = 0x0a
    local p2 = 0x17
    local t = 0x24
    local vol = 0x0e
    local r = RC(40)
    local m = lib.at(head)
    local rt = RC(5)
    return function()
        for _, a in pairs(as) do
            if r() then w8(a+p1, rand(0, 0xff)) end
            if r() then w8(a+p2, stou8(rand(-5, 5))) end
            if r() then w8(a+vol, rand(0, 0xa0)) end
            if rt() then m:with(a+t):Tadd8(1, rand(-5, -1), 1) end
        end
    end
end)

```

左テキストをいじる

```lua
local function update_text1()
    local head1 = 0x02ef88E0

    -- しかし、このテキスト改変、途中からのstateだとこの通りになったが、本番撮影では「丁」が「。」になったりと少し挙動が違っていた...
    local vals1 = {
        0x1604, -- 洗う。
        0x1102, -- E包丁
        0x1108, -- タ.
        0x1c09, -- Nダサ' 0イ.
        0x1104, -- Tッと洗う。
        0x1301, -- 丁丁丁盛りつける
        0xbb04, -- フライパン
        0x2605, -- pンに入れ、中火で...
        0x7704, -- わせる。
        0x3131, -- 丁丁丁//DJ
        0x9004, -- 丁野菜をしく。
        0x3b02, -- 細かくきざむ。
        -- 0x4004, -- ル
        -- 0x2102, -- 丁丁丁丁B
        -- 0xe102, -- 大さじ1を...
        -- 0xe101, -- 器に盛る
        -- 0x0f07, -- サ' 0イ
    }

    for i = 1, #vals1 do
        w16(head1 + (i-1)*8 + 2, vals1[i])
    end
end

-- ひらがなや漢字を別の文字にする
local function update_text2()
    local head = 0x02F47DC0
    local c = Cnt(60)
    SET_LOOP(1, function()
        if not c() then return end
        for i = 0, 10 do
            local _i = head + i * 0x40
            w16(_i, r16(_i) ~ (0x0100 * rand(1,0xf)))
        end
    end)
end

-- update_text1()
update_text2()
```

サブタイトル(「1 種を取る」など)をいじる

```lua

local head = 0x02efa000
local width = 0xf00
for i = 0, width-1, 4 do
    local v = 0
    v = (v << 8) | (0x01 * rand(1, 0xf))
    v = (v << 8) | (0x11 * rand(1, 0xf))
    v = (v << 8) | (0x01 * rand(1, 0xf))
    v = (v << 8) | (0x11 * rand(1, 0xf))
    w32(head + i, v)
    -- w32(head + i, 0x01100110 * rand(0x1, 0xf))
end

local vals = {}
local head2 = 0x2ef87C0
local width = 0x100
for i = 0, width-1, 16 do
    local _i = head2 + i
    -- vals[_i] = r32(_i)
    vals[_i] = r8(_i + 3)
end
for i = 0, width-1, 16 do
    local _i = rand(0, width-1) & 0xfffffff0
    _i = head2 + _i
    -- w32(head2 + i, vals[_i])
    w8(head2 + i + 3, vals[_i + 3])
end
```


リザルト画面をいじる

```lua
local function final_bg()
    -- 背景
    lib.fill_in(0x06000000, 0x062fffff)

    -- 先生を手だけにする
    lib.fill_in(0x06406200, 0x06406fff)

    local bk = lib.range(0x0640b000, 0x0640f9ff):save()
    local r = RC(20)
    local r2 = RC(5)
    local masks = {
        0xffffffff,
        0x0f0f0f0f,
        0x01010101,
        0xf0f00303,
    }
    -- 写真
    SET_LOOP(444, function()
        if r() then bk:rollback() end
        if not r2() then return end
        local v = 0x01010101 * rand(1, 0xf)
        local mask = masks[rand(1, #masks)]
        for i = 0x0640b000, 0x0640f9ff, 4 do
            if rand(1, 2) == 1 then
                w32(i, r32(i) ~ v)
            else
                w32(i, r32(i) ~ mask)
            end
        end
    end)
end
final_bg()
```

## part3 雑多メモ

- `w32(0x023D086C, 0x12121212)`
- `w32(0x023D086C, 0x22222200)`

### 辻先生のテクスチャ

手: `Morton(4, 0x20, 0x80)`, bound: 0x200
顔: `Morton(4, 0x20, 0x100)`, bound: 0x800

- anime1: `0x06600ec0 -- 0x066010c0 -- 0x066018bf`
- anime2: `0x066018c0 -- 0x06601ac0 -- 0x066022bf`
- anime3: `(none) -- 0x066022c0 -- 0x06602abf`
- anime4: `(none) -- 0x06602ac0 -- 0x066032bf`

待機

- anime1: `(none) -- 0x066036c0 -- 0x06603ebf` (OKのときも)
- anime2: `(none) -- 0x06603ec0 -- 0x066046bf`
- anime3: `(none) -- 0x066046c0 -- 0x06604ebf`

OKの手: `0x066057c0 -- 0x066059bf`

おじぎ: `0x066059c0 -- 0x066061bf`

顔: 幅32, 高さ64

```lua
-- x in [0, 31], y in [0, 63]
local function tsuji_face_pos(x, y, anime_i)
    anime_i = anime_i or 1
    local heads = {
0x066010c0,
0x06601ac0,
0x066022c0,
0x066036c0,
0x06603ec0,
0x066046c0,
0x066059c0,
    }
    local head = heads[anime_i] or heads[1]
    return lib.pos.Morton(x, y, 4, 0x20, 0x100) + head
end
```

### 写真

#### 写真 左上

高さ64 * 幅64

`0x0660a580 -- 0x0660b57f`, `Morton(8, 0x40, 0x200)`

#### 写真 中央上

高さ64 * 幅32

`0x0660b580 -- 0x0660bd7f`, `Morton(8, 0x40, 0x100)`

#### 写真 右上

高さ64 * 幅16

`0x0660bd80 -- 0x0660c17f`, `Morton(8, 0x40, 0x80)`

#### 写真 左下

`0x0660c180 -- 0x0660d17f`, `Morton(8, 0x40, 0x200)`

#### 写真 中央下

`0x0660d180 -- 0x0660d97f`, `Morton(8, 0x40, 0x100)`

#### 写真 右下

`0x0660d980 -- 0x0660dd7f`, `Morton(8, 0x40, 0x80)`

#### 写真 底

高さ8

`0x0660dd80 -- 0x0660e0ff`, `Morton(8, 0x40, 0x380)`

#### コード

```lua
-- x in [0, 111], y in [0, 135]
local function pos(x, y)
    local head_ue = {
0x0660a580, 0x0660b580, 0x0660bd80
    }
    local head_shita = {
0x0660c180, 0x0660d180, 0x0660d980
    }
    ---@type int | int[]
    local head
    if y >= 128 then
        head = 0x0660dd80
        return lib.pos.Morton(x, y - 128, 8, 0x40, 0x380) + head
    elseif y >= 64 then
        head = head_shita
        y = y - 64
    else head = head_ue
    end
    local L
    if x >= 96 then
        head = head[3]
        x = x - 96
        L = 0x80
    elseif x >= 64 then
        head = head[2]
        x = x - 64
        L = 0x100
    else
        head = head[1]
        L = 0x200
    end
    return lib.pos.Morton(x, y, 8, 0x40, L) + head
end
```

### 出来上がり写真

#### 左上

高さ64 * 幅64

`0x0640b000 -- 0x0640bfff`, `Morton(8, 0x40, 0x200)`

#### 中央上

高さ64 * 幅64

`0x0640c000 -- 0x0640cfff`, `Morton(8, 0x40, 0x200)`

#### 右上

高さ64 * 幅8

`0x0640d000 -- 0x0640d1ff`, `Raster(8)`

#### 左下

`0x0640d200 -- 0x0640e1ff`, `Morton(8, 0x40, 0x200)`

#### 中央下

`0x0640e200 -- 0x0640f1ff`, `Morton(8, 0x40, 0x200)`

#### 右下

`0x0640f200 -- 0x0640f3ff`, `Raster(8)`

#### 写真 底

高さ8

`0x0640f400 -- 0x0660f83f`, `Morton(8, 0x40, 0x440)`

#### コード

```lua
-- x in [0, 129], y in [0, 135]
local function pos(x, y)
    local head_ue = {
0x0640b000, 0x0640c000, 0x0640d000
    }
    local head_shita = {
0x0640d200, 0x0640e200, 0x0640f200,
    }
    ---@type int | int[]
    local head
    if y >= 128 then
        head = 0x0640f400
        return lib.pos.Morton(x, y - 128, 8, 0x40, 0x440) + head
    elseif y >= 64 then
        head = head_shita
        y = y - 64
    else head = head_ue
    end
    local L
    if x >= 128 then
        head = head[3]
        x = x - 128
        return lib.pos.Raster(x, y, 8) + head
    elseif x >= 64 then
        head = head[2]
        x = x - 64
        L = 0x200
    else
        head = head[1]
        L = 0x200
    end
    return lib.pos.Morton(x, y, 8, 0x40, L) + head
end
```

## ryori3 使用コード

<details>
<summary>コード</summary>
<div>

```lua
-- ================================
-- ======== ライブラリ部分 ========
-- ================================

local update_chars = (function()

local addrs = {
    {
        0x02F47DC0,
        0x02F47E00,
        0x02F47E40,
        0x02F47E80,
        0x02F47EC0,
        0x02F47F00,
        0x02F47F40,
        0x02F47F80,
        0x02F47FC0,
    },
    {
        0x02F48180,
        0x02F481C0,
        0x02F48200,
        0x02F48240,
        0x02F48280,
    },
    {
        0x02F48000,
        0x02F48040,
        0x02F48080,
        0x02F480a0,
        0x02F48100,
        0x02F48140,
    }
}

local vs = {{}, {}, {}}
local r = RC(40)
local is_first = true
local n = #addrs
local function get_random(i, _n)
    _n = _n or n
    while true do
        local v = rand(1, _n)
        if v ~= i then return v end
    end
end
return function()
    if is_first then
        for j = 1, 3 do
            for i, a in pairs(addrs[j]) do
                vs[j][i] = r16(a)
            end
        end
    end
    for j = 1, 3 do
        for i, a in pairs(addrs[j]) do
            if r() then
                local d = 9
                w16(a, vs[j][get_random(i)] + rand(-d, d) * 0x100)
            end
        end
    end
    is_first = false
end
end)()

local update_voice = (function()
    local r = RC(10)
    return function()
        if r() or r32(0x023D086C) == 0 then
        w32(0x023D086C, rand(0, 0xffffffff))
        end
    end
end)()

-- x in [0, 111], y in [0, 135]
local function pic_pos(x, y)
    local head_ue = {
0x0660a580, 0x0660b580, 0x0660bd80
    }
    local head_shita = {
0x0660c180, 0x0660d180, 0x0660d980
    }
    ---@type int | int[]
    local head
    if y >= 128 then
        head = 0x0660dd80
        return lib.pos.Morton(x, y - 128, 8, 0x40, 0x380) + head
    elseif y >= 64 then
        head = head_shita
        y = y - 64
    else head = head_ue
    end
    local L
    if x >= 96 then
        head = head[3]
        x = x - 96
        L = 0x80
    elseif x >= 64 then
        head = head[2]
        x = x - 64
        L = 0x100
    else
        head = head[1]
        L = 0x200
    end
    return lib.pos.Morton(x, y, 8, 0x40, L) + head
end

-- x in [0, 135], y in [0, 135]
local function lastPic_pos(x, y)
    local head_ue = {
0x0640b000, 0x0640c000, 0x0640d000
    }
    local head_shita = {
0x0640d200, 0x0640e200, 0x0640f200,
    }
    ---@type int | int[]
    local head
    if y >= 128 then
        head = 0x0640f400
        return lib.pos.Morton(x, y - 128, 8, 0x40, 0x440) + head
    elseif y >= 64 then
        head = head_shita
        y = y - 64
    else head = head_ue
    end
    local L
    if x >= 128 then
        head = head[3]
        x = x - 128
        return lib.pos.Raster(x, y, 8) + head
    elseif x >= 64 then
        head = head[2]
        x = x - 64
        L = 0x200
    else
        head = head[1]
        L = 0x200
    end
    return lib.pos.Morton(x, y, 8, 0x40, L) + head
end

-- x in [0, 31], y in [0, 63]
local function tsuji_face_pos(x, y, anime_i)
    anime_i = anime_i or 1
    local heads = {
0x066010c0,
0x06601ac0,
0x066022c0,
0x06602ac0,
0x066036c0,
0x06603ec0,
0x066046c0,
0x066059c0,
    }
    local head = heads[anime_i] or heads[1]
    return lib.pos.Morton(x, y, 4, 0x20, 0x100) + head
end

local function tsuji_hand_pos(x, y, anime_i)
    anime_i = anime_i or 1
    local heads = {
0x06600ec0,
0x066018c0,
0x066057c0,
    }
    local head = heads[anime_i] or heads[1]
    return lib.pos.Morton(x, y, 4, 0x20, 0x80) + head
end

local picF = lib.image.filterObj()
:width(112):height(136)
local lastPicF = lib.image.filterObj()
:width(136):height(136)
local tsujiF = lib.image.filterObj()
:width(32):height(64)
local tsujiHandF = lib.image.filterObj()
:width(16):height(32)

-- あらかじめ辻先生のグラ情報はバックアップをとる
local tsuji_vs = {}
for j = 1, 8 do
    for y = 0, 63 do
        for x = 0, 31 do
            local a = tsuji_face_pos(x, y, j)
            tsuji_vs[a] = r8(a)
        end
    end
end

local tsuji_hand_vs = {}
for j = 1, 3 do
    for y = 0, 31 do
        for x = 0, 15 do
            local a = tsuji_hand_pos(x, y, j)
            tsuji_hand_vs[a] = r8(a)
        end
    end
end

---@type table<int, fun(): fun()?>
local update_gra = {}

gra_mode = 0
local _current_gra_mode = 0
---@type fun()?
local current_gra_fun = nil

local _update_gra = function()
    if _current_gra_mode ~= gra_mode then
        _current_gra_mode = gra_mode
        ---@type fun(): fun()?
        local f = update_gra[gra_mode]
        local res, fun = pcall(f)
        current_gra_fun = res and fun or nil
        print(string.format("== STEP to next gra_mode \"%d\" ==", gra_mode))
    end
    if current_gra_fun then
        current_gra_fun()
    end
end

function loop()
    update_chars()
    update_voice()
    _update_gra()
end

irume_active = false
lib.irume.start(function()
    local head = 0x03EB9210
    local as = {}
    local prevs = {}
    for i = 0, 14 do
        as[i] = head + 0x40*i
        prevs[i] = 0
    end
    local p1 = 0x0a
    local p2 = 0x17
    local t = 0x24
    local vol = 0x0e
    return function()
        if not irume_active then return end
        for i, a in pairs(as) do
            local _t = r8(a + t)
            if prevs[i] < _t then
                _t = rand(0x5, 0x14)
                w8(a + p1, rand(0,0xff))
                w8(a + p2, stou8(rand(-6, 6)))
            end
            w8(a + t, _t)
            prevs[i] = _t
            -- w16(a + vol, 0x40)
        end
        w16(as[0] + vol, 0x80)
    end
end)

-- ================================
-- ================================
-- ================================
-- ================================
-- ================================

update_gra[1] = function()
-- step4 で画像が切り替わる瞬間！
local function go()
picF:go(function(x, y)
    local _x, _y = math.round(x * 32 / 112), math.round(y * 64 / 136)
    return pic_pos(x, y), tsuji_vs[tsuji_face_pos(_x, _y, 3)]
end)
end
local r = RL(10)
return function()
    if not r() then go() end
end
end

update_gra[2] = function()
-- step5
local c = Cnt(2, 2)
return function()
    local i = c:next() + 1
    for j = 1, 3 do
    tsujiHandF:go(function(x, y)
        return tsuji_hand_pos(x, y, j), tsuji_hand_vs[tsuji_hand_pos(x, y, i)]
    end)
    end
end
end

update_gra[3] = function()
-- step6
return function()
    local i = rand(1, 3)
    for j = 1, 3 do
    tsujiHandF:go(function(x, y)
        return tsuji_hand_pos(x, y, j), tsuji_hand_vs[tsuji_hand_pos(x, y, i)]
    end)
    end
    i = rand(1, 8)
    for j = 1, 8 do
        tsujiF:go(function(x, y)
            return tsuji_face_pos(x, y, j), tsuji_vs[tsuji_face_pos(x, y, i)]
        end)
    end
end
end

update_gra[4] = function()
-- step7
local c = Cnt(32)
local face = 1
local face_r = RC(30)
return function()
    if face_r() then face = rand(1, 8) end
    local xd = c:next()
    picF:go(function(x, y)
        local _x, _y
        _x = math.round(x * 32 / 112)
        _y = math.round(y * 64 / 136)
        _x = (_x + xd) % 32
        return pic_pos(x, y), tsuji_vs[tsuji_face_pos(_x, _y, face)]
    end)
end
end

update_gra[5] = function()
-- step8 -- 12
local __f = update_gra[3]()
local xd = 0
local yd = 0
local xs = 3
local ys = 2
local xs_t = xs
local ys_t = ys
local xsr = RC(60)
local ysr = RC(60)

local b_st = 40
local b_scale = 0.7
local br = RC(70)

local face = 1
local face_r = RC(30)
return function()
    __f()
    if face_r() then face = rand(1, 8) end
    if xsr() then xs_t = rand(-10, 10) end
    if ysr() then ys_t = rand(-10, 10) end
    xs = ilerp(xs, xs_t, 0.1)
    ys = ilerp(ys, ys_t, 0.1)
    if br() then
        b_st = rand(10, 50)
        b_scale = rand(30, 95) / 100
    end
    xd = (xd + xs) % 32
    yd = (yd + ys) % 64
    picF:go(function(x, y)
        local _x, _y
        _x = math.round(x * 32 / 112)
        _y = math.round(y * 64 / 136)
        _x = (_x + xd) % 32
        _y = (_y + yd) % 64
        if _y >= b_st then
            _y = math.round((_y - b_st) * b_scale) + b_st
        end
        return pic_pos(x, y), tsuji_vs[tsuji_face_pos(_x, _y, face)]
    end)
end
end

mode6_use_color_change = false
update_gra[6] = function()
-- step13 -- ?
local xd = 0
local yd = 0
local xs = 3
local ys = 2
local xs_t = xs
local ys_t = ys
local xsr = RC(60)
local ysr = RC(60)

local b_st = 40
local b_scale = 0.7
local br = RC(70)
local bx_center = 16
local bx_scale = 0.8

local face = 1
local face_r = RC(30)

local color_mask = 0xff
local color_mask_r = RC(20)
local color_mask_r2 = RC(99000)
local color_mask_r_rl = RL(300)
local function cc(v)
    if not mode6_use_color_change then return v end
    if v == 0 then return 0 end
    if color_mask_r_rl.fired and color_mask_r2() then
        color_mask = rand(0, 0xf) * 0x11
    end
    return v ~ color_mask
end

local update_face = (function()
    local xd = 0
    local yd = 0
    local xs = -3
    local ys = 0
    local xs_t = xs
    local ys_t = ys
    local xsr = RC(60)
    local ysr = RC(60)

    local b_st = 32
    local b_scale_c = Cnt(90)
    local br = RC(5)
    return function()
        if xsr() then xs_t = rand(-5, 5) end
        if ysr() then ys_t = rand(-5, 5) end
        xs = ilerp(xs, xs_t, 0.1)
        ys = ilerp(ys, ys_t, 0.1)
        xd = (xd + xs) % 32
        yd = (yd + ys) % 64
        if b_scale_c() and br() then
            b_st = rand(20, 40)
            b_scale_c:N(rand(30, 120))
        end
        local i = rand(1, 8)
        local y_scale = math.sin01(b_scale_c.i / b_scale_c.n) * 1.3 + 0.2
        for j = 1, 8 do
            tsujiF:go(function(x, y)
                local _x, _y
                _x = (x + xd) % 32
                _y = (y + yd) % 64
                _y = math.round((_y - b_st) * y_scale) + b_st
                _y = clamp(_y, 0, 63)
                return tsuji_face_pos(x, y, j), cc(tsuji_vs[tsuji_face_pos(_x, _y, i)])
            end)
        end
    end
end)()
local update_hand = (function()
    local xc = Cnt(10)
    local rev_y = false
    local r = RC(20)
    return function()
        if r() then rev_y = not rev_y end
        local xd = math.round(math.sin01(xc:next() / xc.n) * 8 - 4)
        local i = rand(1, 3)
        for j = 1, 3 do
        tsujiHandF:go(function(x, y)
            local _x, _y
            _x = clamp(x + xd, 0, 15)
            _y = rev_y and (31 - y) or y
            return tsuji_hand_pos(x, y, j), cc(tsuji_hand_vs[tsuji_hand_pos(_x, _y, i)])
        end)
        end
    end
end)()

return function()
    if mode6_use_color_change then
        if color_mask_r_rl() and color_mask_r() then
            color_mask = rand(0, 0xf) * 0x11
        end
    end
    if face_r() then face = rand(1, 8) end
    if xsr() then xs_t = rand(-10, 10) end
    if ysr() then ys_t = rand(-10, 10) end
    xs = ilerp(xs, xs_t, 0.1)
    ys = ilerp(ys, ys_t, 0.1)
    if br() then
        b_st = rand(10, 50)
        b_scale = rand(30, 95) / 100
    end
    if br() then
        bx_center = rand(10, 20)
        bx_scale = rand(30, 100) / 100
    end
    xd = (xd + xs) % 32
    yd = (yd + ys) % 64
    picF:go(function(x, y)
        local _x, _y
        _x = math.round(x * 32 / 112)
        _y = math.round(y * 64 / 136)
        _x = (_x + xd) % 32
        _y = (_y + yd) % 64
        _x = math.round((_x - bx_center) * bx_scale) + bx_center
        if _y >= b_st then
            _y = math.round((_y - b_st) * b_scale) + b_st
        end
        return pic_pos(x, y), cc(tsuji_vs[tsuji_face_pos(_x, _y, face)])
    end)
    update_hand()
    update_face()
end
end

update_gra[7] = function()

local function tsuji_mesen()
w32(0x06406840, r32(0x06406840) & 0xffff | 0x11110000)
w32(0x06406844, r32(0x06406844) & 0xffff | 0x11110000)
w32(0x06406848, r32(0x06406848) & 0xffff | 0x11110000)
w32(0x0640684c, r32(0x0640684c) & 0xffff | 0x11110000)

w32(0x06406860, 0x11111111)
w32(0x06406864, 0x11111111)
w32(0x06406868, 0x11111111)
w32(0x0640686c, 0x11111111)

w32(0x06406880, r32(0x06406880) & 0xffff0000 | 0x1111)
w32(0x06406884, r32(0x06406884) & 0xffff0000 | 0x1111)
w32(0x06406888, r32(0x06406888) & 0xffff0000 | 0x1111)
w32(0x0640688c, r32(0x0640688c) & 0xffff0000 | 0x1111)
end

local color_mask = 0
local color_mask_r = RC(20)
local color_mask_r2 = RC(99000)
local color_mask_r_rl = RL(180)
local function cc(v)
    if v == nil then return nil end
    if v == 0 then return 0 end
    if color_mask_r_rl.fired and color_mask_r2() then
        color_mask = rand(0, 0xf) * 0x11
    end
    return v ~ color_mask
end

local face = 1
local face_r = RC(30)

local br = RC(50)
local bx_ready = false
local by_ready = false
local bx_center = 60
local bx_max = 90
local bx_min = 40
local bx_scale_c = Cnt(40)
local by_center = 60
local by_scale_c = Cnt(50)
local by_max = 90
local by_min = 40
local y_ss = nil
local x_ss = nil
local sss = {true, false, nil}
return function()
    if color_mask_r_rl() and color_mask_r() then
        color_mask = rand(0, 0xf) * 0x11
    end
    tsuji_mesen()
    if face_r() then face = rand(1, 8) end
    bx_ready = bx_ready or br()
    by_ready = by_ready or br()
    if bx_scale_c() and bx_ready then
        bx_ready = false
        bx_center = rand(20, 110)
        bx_scale_c:N(rand(20, 90))
        bx_min = rand(20, 60)
        bx_max = rand(bx_min + 10, 100)
        x_ss = sss[rand(1, 3)]
    end
    if by_scale_c() and by_ready then
        by_ready = false
        by_center = rand(20, 110)
        by_scale_c:N(rand(20, 90))
        by_min = rand(20, 60)
        by_max = rand(bx_min + 10, 100)
        y_ss = sss[rand(1, 3)]
    end
    local x_scale = ilerp(bx_min, bx_max, math.sin01(bx_scale_c.i / bx_scale_c.n)) / 100
    local y_scale = ilerp(by_min, by_max, math.sin01(by_scale_c.i / by_scale_c.n)) / 100
    lastPicF:go(function(x, y)
        local _x, _y = x, y
        if x_ss == nil or (x < 68 == x_ss) then
            _x = math.round((_x - bx_center) * x_scale) + bx_center
        end
        if y_ss == nil or (y < 68 == y_ss) then
            _y = math.round((_y - by_center) * y_scale) + by_center
        end
        _x = clamp(_x, 0, 135)
        _y = clamp(_y, 0, 135)
        _x = math.round(_x * 32 / 136)
        _y = math.round(_y * 64 / 136)
        return lastPic_pos(x, y), cc(tsuji_vs[tsuji_face_pos(_x, _y, face)])
    end)
end
end
```

操作コード

```lua
-- step2に入る直前 => コードを送信！(音声&テキストバグ)
-- step3 声を高くする(0x023D0823)

-- [1] step4 で画像が切り替わる瞬間！
-- [2] step5
-- [3] step6
-- [4] step7
-- [5] step8
-- [6] step13
-- [6] with COLOR: step 16
-- [7] last scene

-- irume_active = true

gra_mode = gra_mode + 1
-- mode6_use_color_change = true

-- gra_mode = 7
```

</div>
</details>

## 雑メモ

`215CCC0` あたりから、右側の説明文のテキストデータ

```lua
-- 辻先生の位置あらぶり
w8(0x21f4278, rand(0, 0xff))
w8(0x21f427a, rand(0, 0xff))
w8(0x21f4290, rand(0, 0xff))
w8(0x21f4292, rand(0, 0xff))

23C1900 -> 4byteで小さいほど声が高くなる
23C1904 -> 2byteで大きいほど遅くなる

23C3260 -> asciiでしゃべっている声の内容?

23CA5E0あたり -> asciiで内容が分かる部分、いじると声が飛ぶ? => ここで発話内容をいじれる！！！！(なんとasciiで制御する)

-- 辻先生のボイスが超断片的になる
-- (1)
for i = 0x023c4440, 0x23c46ff do
    w8(i, 0)
end

-- (2)
for i = 0x023c4450, 0x23c47ff, 0x10 do
    if rand(1, 3) == 1 then
        w32(i, r32(i - 0x10))
        w32(i + 4, r32(i + 4 - 0x10))
        w32(i + 8, r32(i + 8 - 0x10))
        w32(i + 12, r32(i + 12 - 0x10))
    elseif rand(1, 2) == 1 then
        w32(i, r32(i + 0x10))
        w32(i + 4, r32(i + 4 + 0x10))
        w32(i + 8, r32(i + 8 + 0x10))
        w32(i + 12, r32(i + 12 + 0x10))
    end
end

-- (3)
-- local d = 0x10
local d = 0x20 -- 40もOK
for i = 0x023c4450, 0x23c47ff, d do
    if rand(1, 3) == 1 then
        for j = 0, d-1, 4 do
            w32(i + j, r32(i + j - d))
        end
    elseif rand(1, 2) == 1 then
        for j = 0, d-1, 4 do
            w32(i + j, r32(i + j + d))
        end
    end
end


-- 「ああああ」と発狂する
local d = 0x10
for i = 0x023c4440, 0x23c47ff, d do
    w16(i, r16(i-d))
end

-- 「にょにょにょ」みたく連呼する
local d = 0x10
for i = 0x023c4440, 0x23c47ff, d do
    -- r/w16ではなくr/w32にしてもよい
    local v =r16(i+rand(-8, 8)*d)
    if v ~= 0 and rand(1, 2) == 1 then
        w16(i, v)
    end
end

-- ノイズと水っけたっぷりの声になる
function loop()
    for i = 0x23c5c30, 0x23c5fff do
        local v = r8(i)
        if v ~= 0 then
            w8(i, v + 1)
        end
    end
end

-- ノイズまみれ?
function loop()
-- iを2つおきとかにすると、抑揚が中途半端につくようになる(恐らく、各文字の音の高さをここで制御している?)
-- ↑違う!2byteずつで、音の高さを管理している！
    for i = 0x23c6230, 0x23c62bf do
        local v = r8(i)
        if v ~= 0 then
            w8(i, v + rand(-4,4))
            -- w8(i, 0x10) -- こっちにするとロボット声になる(0x10-0x1dまではいけそう)
        end
    end
end
-- ↓
-- ver2
-- ↓
function loop()
    for i = 0x23c6230, 0x23c62bf, 2 do
        w16(i, 0x1300)
    end
end

-- 音程をある程度制御する?
local ps = {0x1200, 0x1300, 0x1400, 0x1500, 0x1600}
local c = Cnt(5, #ps)
function loop()
    c()
    for i = 0x23c6230, 0x23c62bf, 2 do
        w16(i, ps[c.i+1])
    end
end

-- 音声がハデにバグるが高確率でフリーズ
function loop()
    for i = 0x23c7638, 0x23c76cb, 4 do
        local v = r16(i + rand(-6,-1)*4)
        if v ~= 0 then
        w16(i, v)
        end
    end
end
```

```
23c4450の構造?

tttt s000 LL HH VV **

tttt: 恐らく発音している文字
s: 恐らく各文字の発話時間?
LL: スピード(signed2byteLE)(大きいほど長い)
HH: 高さ(signed2byteLE)(大きいほど高い)
VV: ボリューム(signed2byteLE)
**: unused
```

## twitter用(8/17) お前は終わりですネタ

```lua
local l1 = "3020300A686F2D63686F2D646520302031302030203230300A"
local l2 = "6f6d61657761"
local s2 = "203020313020313020300A"
local l3 = "6f7761726964657375"
local s3 = "20302031302030203230300A"
-- local l2 = "7361796f2d6e617261"
-- local l2 = "616e61746177617361796f756e617261"
local last = "2E20332035203020313030300A0000000000000000000000000000000"
lib.warr(0x023CA630, lib.htob(l1..l2..s2..l3..last))
```
