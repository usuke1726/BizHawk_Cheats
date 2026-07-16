
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
