
local pos_watch_id = "ranger_pos_watch"

---主人公の座標を管理するアドレスを探す。
---
---この関数を呼び出した後、y座標を(x座標が一切動かないように注意しながら)、真上、真下、...と上下に往復する。
---
---@param begin int
---@param iend int
---@param val? int
local function pos_watch(begin, iend, val)
    begin = (begin or 0x02200000) & 0xfffffffc
    iend = (iend or 0x022fffff) | 0x3
    val = val or 819
    local move = nil
    local cooltime = 0
    local addrs = {}
    local prevs = {}
    local probs = {}
    local trial_count = 0
    local reset = DS.key.lis("R")
    local is_first = true
    local c = Cnt(10)
    local failed_printed = false
    SET_LOOP(pos_watch_id, function()
        if reset() then
            is_first = true
            failed_printed = false
        end
        if DS.key.get("Up") then
            if move ~= 1 then
                print("UP")
                cooltime = 20
            end
            move = 1
        elseif DS.key.get("Down") then
            if move ~= 2 then
                print("DOWN")
                cooltime = 20
            end
            move = 2
        else move = nil
        end
        if cooltime > 0 then
            cooltime = cooltime - 1
            return
        end
        if not c() then return end
        if not move then return end
        if is_first then
            addrs = {}
            prevs = {}
            for i = begin, iend, 4 do
                addrs[i] = true
                prevs[i] = r32(i-0x30) -- y座標の値
                probs[i] = 0
            end
            is_first = false
            return
        end
        local new_addrs = {}
        local target = (move == 1 and 0x100000000-val or val)
        trial_count = trial_count + 1
        for i, _ in pairs(addrs) do
            local d, cur = r32(i), r32(i-0x30)
            if d == target and prevs[i] ~= cur then
                new_addrs[i] = true
                prevs[i] = cur
                probs[i] = probs[i] + 1
            else
                if probs[i]/trial_count > 0.1 then
                    new_addrs[i] = true
                    prevs[i] = cur
                end
            end
        end
        addrs = new_addrs
        local _a = {}
        for i, _ in pairs(addrs) do
            table.insert(_a, i)
        end
        table.sort(_a)
        local cnt = #_a
        if cnt < 6 then
            CLS()
            for i = 1, cnt do
                printf("0x%08X", _a[i]-0x38) -- x座標のアドレス
            end
        end
        if within(cnt, 1, 2) then
            DELETE_LOOP(pos_watch_id)
            print("Done.")
        end
        if cnt == 0 and (not failed_printed) then
            failed_printed = true
            print("FAILED press R to rewatch")
        end
    end)
end

---@param addr int
---@param speed? int
local function free_move(addr, speed)
    DELETE_LOOP(pos_watch_id)
    speed = speed or 0x800
    local xp = addr
    local yp = addr + 8

    local cx = r32(xp)
    local cy = r32(yp)

    local m = lib.at(0x02000000)
    local c = Cnt(30)
    local jump_active = false
    local jump_now = false
    local jump_d = 0
    SET_LOOP("ranger_free_move", function()
        if DS.key.get("R") then
            if not jump_active then
                c.i = 0
            end
            jump_active = true
        else
            if jump_active then jump_now = true end
            jump_active = false
        end
        local xd, yd = 0, 0
        if DS.key.get("Right") then
            xd = speed
        elseif DS.key.get("Left") then
            xd = -speed
        end
        if DS.key.get("Up") then
            yd = -speed
        elseif DS.key.get("Down") then
            yd = speed
        end
        if jump_active then
            if c() then
                jump_d = jump_d + 0x10
                printf("jump_d 0x%X", jump_d)
            end
        else
            if jump_now then
                cx = cx + xd * jump_d
                cy = cy + yd * jump_d
                jump_d = 0
            else
                cx = cx + xd
                cy = cy + yd
            end
        end
        m:with(xp):w32(cx)
        m:with(yp):w32(cy)
        jump_now = false
    end)
end

---@param begin int
---@param count int
---@param change_to int | int[] | (fun(id: int): int|nil)
---@param target_ids? int | int[]
local function update_yasei(begin, count, change_to, target_ids)
    local prev = r32(begin)
    local is_target_null = not target_ids
    target_ids = target_ids or {}
    if type(target_ids) == "number" then target_ids = {target_ids} end
    local function is_target(i)
        if is_target_null then return true end
        for _, v in pairs(target_ids--[[@as table]]) do
            if v == i then return true end
        end
        return false
    end
    ---@type fun(id: int): int
    local get_id = change_to--[[@as fun()]]
    if type(change_to) == "number" then
        get_id = function() return change_to end
    elseif type(change_to) == "table" then
        local n = #change_to
        local i = 0
        get_id = function() i = (i%n)+1 return change_to[i] end
    end
    local id = "WAITING"
    SET_LOOP(id, function()
        if r32(begin) ~= prev then
            DELETE_LOOP(id)
            print("GO")
            for i = 1, count do
                local addr = begin + 0x14 * (i-1)
                local id = r16(addr)
                if is_target(id) then
                    local v = get_id(id)
                    if v then
                        w16(addr, v)
                    end
                end
            end
        end
    end)
end

---@param R integer
---@param silent? boolean
local function zukan_from_Rno(R, silent)
    local addr = 0x00B2A02E + (R-1)*14
    local id = r16r(addr)
    local height = r16r(addr+4)/10
    local weight = r16r(addr+6)/10
    if not silent then
    printf("ID 0x%X %.1fm %.1fkg (at 0x%08X)", id, height, weight, addr)
    end
    return id
end

---キャプチャ中のラインの長さを管理するアドレスを探す。
---
---(例えば、そのアドレス+8のアドレスを0固定すると、無限ラインが可能になる)
---
---使い方:
---1. キャプチャ中に(**ラインを引いていない状態で**)この関数を呼び出す。
---1. 適当な長さのラインを引き、その状態で待機。
local function start_search_line_length_addr()
    local f, addrs = lib.find_all(0x02300000, 0x023fffff, htob("FFFFFFFFFFFFFFFF00000000"), nil, nil, true)
    local id = "ranger_search_line_length_addr"
    local is_touching = false
    local pos = {x = 0, y = 0}
    local c = Cnt(60)
    SET_LOOP(id, function()
        local mouse = DS.key.mouse()
        if mouse then
            if not is_touching then
                is_touching = true
                pos = mouse
                return
            end
            if not c() then return end
            if math.abs(pos.x-mouse.x) + math.abs(pos.y-mouse.y) > 20 then
                local as = Array.filter(addrs, function(addr)
                    local v1 = r32(addr)
                    local v2 = r32(addr+4)
                    local v3 = r32(addr+8)
                    return within(v1, 1, 0x100) and math.abs(v1 - v2) <= 3 and within(v3, 0x2000, 0x270000)
                end)
                if #as == 0 then
                    DELETE_LOOP(id)
                    printf("FAILED")
                elseif #as <= 3 then
                    DELETE_LOOP(id)
                    printf("FOUND:")
                    for _, a in pairs(as) do
                        printf("0x%08X", a)
                    end
                end
            end
        else is_touching = false
        end
    end)
end

local chars_from_81 = "ぁあぃいぅうぇえぉおかがきぎくぐけげこごさざしじすずせぜそぞただちぢっつづてでとどなにぬねのはばぱひびぴふぶぷへべぺほぼぽまみむめもゃやゅゆょよらりるれろゎわゐゑをん"
local chars_from_e1 = "ァアィイゥウェエォオカガキギクグケゲコゴサザシジスズセゼソゾタダチヂッツヅテデトドナニヌネノハバパヒビピフブプヘベペホボポマミムメモャヤュユョヨラリルレロヮワヰヱヲン"
local special_chars = {
    [0x4] = "\\C:blue",
    [0x5] = "\\C:black",
    [0x0a] = "\n",
    [0x0d] = "\n\\r\n",
    [0x0c] = "",
    [0x20] = "　",
    [0x14c] = "ー",
}
-- ROM内のテキストは0x00B8CC00から0x00C2A28Fまで

---@param addr int
---@param end_addr int?
---@param is_ram bool?
---@return string
local function read_text(addr, end_addr, is_ram)
    addr = addr & 0xfffffffe
    end_addr = end_addr or (addr + 0x2000)
    end_addr = end_addr - (end_addr & 1)
    local domain = (not is_ram) and ROM_DOMAIN_NAME or nil
    local ret = ""
    local is_new_dialogue = false
    local is_first = true
    local long_blank = false
    local function is_long_blank(i)
        for j = 0, 3 do
            if r32(i+4*j, domain) ~= 0 then return false end
        end
        return true
    end
    local function read(i)
        local v = r16(i, domain)
        if v == 0 then
            if long_blank then return end
            if not is_new_dialogue then
                is_first = false
                is_new_dialogue = true
            end
            if is_long_blank(i) then
                long_blank = true
                is_first = true
            end
            return
        elseif is_new_dialogue then
            is_new_dialogue = false
            if long_blank then
                long_blank = false
                if r16(i+6, domain) == 1 then
                    printf("EVENT 0x%X from 0x%08X", v, i)
                    -- イベントデータ? この場所はテキストでないのでスキップする
                    return 6
                end
            end
            ret = ret .. string.format("\n\n0x%08X\n", i)
        end
        long_blank = false
        if is_first then return end
        if v == 2 then
            local cmd = r16(i+2, domain)
            if cmd == 0x702 then
                ret = ret .. string.format("\\POKENAME[%X]", r16(i+4, domain))
                return 4
            elseif cmd == 0x101 then
                ret = ret .. string.format("\\MYNAME")
                return 3
            end
            local cnt = 1
            local vs = {"0200"}
            while true do
                local _v = r16(i+cnt*2, domain)
                vs[cnt+1] = string.format("%04X", (_v >> 8) | ((_v & 0xff) << 8))
                if _v == 3 then break end
                cnt = cnt + 1
                assert(cnt < 100, string.format("cnt out of bound at 0x%08X", i))
            end
            ret = ret .. string.format("\\CMD[%s]", table.concat(vs, ""))
            return cnt + 1
        end
        if v == 7 then
            ret = ret .. string.format("\\WAIT[%X]", r16(i+2, domain))
            return 2
        end
        if v == 0xff0c then
            ret = ret .. string.format("\\IMG[%X]", r16(i+2, domain))
            return 2
        end
        if special_chars[v] then
            ret = ret .. special_chars[v]
        elseif within(v, 0x81, 0xd3) then
            local j = v - 0x81
            ret = ret .. chars_from_81:sub(3*j+1, 3*j+3)
        elseif within(v, 0xe1, 0x133) then
            local j = v - 0xe1
            ret = ret .. chars_from_e1:sub(3*j+1, 3*j+3)
        elseif within(v, 0x20, 0x7e) then
            ret = ret .. string.char(v)
        end
    end
    local i = addr
    while i <= end_addr do
        i = i + (read(i) or 1) * 2
    end
    return ret
end

---@param addr int
---@param end_addr int?
---@param is_ram bool?
---@param writer_query WriterQuery ファイル名(`string`)または標準出力(`bool?`)
local function dump_text(addr, end_addr, is_ram, writer_query)
    local text = read_text(addr, end_addr, is_ram)
    local file = lib.path.w(writer_query)
    file:wl(text)
    file:close()
end

return {
    pos_watch = pos_watch,
    free_move = free_move,
    update_yasei = update_yasei,
    zukan_from_Rno = zukan_from_Rno,
    start_search_line_length_addr = start_search_line_length_addr,
    read_text = read_text,
    dump_text = dump_text,
}

