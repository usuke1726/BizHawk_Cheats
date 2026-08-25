
local sjis = require "misc/sjis"
local kanji_full_table = require "misc/_sjis_kanji_full_table"

---@class VT_Unit
---@field t string
---@field v1 int
---@field v2 int
---@field v3 int
---@field v4 int

local VT_options = {
    head = 0x023CA5E6
}

---@return VT_Unit[]
local function get_vt()
    local head = VT_options.head
    local i = head
    ---@type VT_Unit[]
    local ret = {}
    local mode = 0
    local function update_v(current, v)
        if not within(v, 0x30, 0x39) then
            error(string.format("invalid v value (not number character): %02X (at %08X)", v, i))
        end
        return current * 10 + (v - 0x30)
    end
    local function VT_init()
        return {t = "", v1 = 0, v2 = 0, v3 = 0, v4 = 0}
    end
    ---@type VT_Unit
    local tmp = VT_init()
    while true do
        local v = r8(i)
        if v == 0 then return ret end
        if v == 0x20 then
            mode = mode + 1
            assert(mode <= 4, "mode out of bound (must be <= 4)")
        elseif v == 0x0a then
            ret[#ret+1] = tmp
            tmp = VT_init()
            mode = 0
        elseif mode == 0 then
            tmp.t = tmp.t .. string.char(v)
        elseif mode == 1 then
            tmp.v1 = update_v(tmp.v1, v)
        elseif mode == 2 then
            tmp.v2 = update_v(tmp.v2, v)
        elseif mode == 3 then
            tmp.v3 = update_v(tmp.v3, v)
        elseif mode == 4 then
            tmp.v4 = update_v(tmp.v4, v)
        end
        i = i + 1
    end
end

---@param data VT_Unit[]
local function set_vt(data)
    local bytes = {}
    for i, v in pairs(data) do
        local _i = tostring(i)
        assert(v.v1 >= 0, _i .. ": v1 is negative")
        assert(v.v2 >= 0, _i .. ": v2 is negative")
        assert(v.v3 >= 0, _i .. ": v3 is negative")
        assert(v.v4 >= 0, _i .. ": v4 is negative")
        local t = string.format("%s %d %d %d %d\n", v.t, v.v1, v.v2, v.v3, v.v4)
        local b = { string.byte(t, 1, -1) }
        for _, _v in pairs(b) do
            table.insert(bytes, _v)
        end
    end
    local head = VT_options.head
    local n = #bytes
    lib.warr(head, bytes)
    local i = head + n
    while true do
        if r8(i) == 0 then return end
        w8(i, 0)
        i = i + 1
    end
end

---@param data VT_Unit[]
local function print_vt(data)
    for i, v in pairs(data) do
        local t = string.format("[%02d] \"%s\" (%d %d %d %d)", i, v.t, v.v1, v.v2, v.v3, v.v4)
        print(t)
    end
end

---@param data [string, int, int, int, int][]
---@return VT_Unit[]
local function vt(data)
    local ret = {}
    for _, v in pairs(data) do
        ret[#ret+1] = {
            t = v[1],
            v1 = v[2],
            v2 = v[3],
            v3 = v[4],
            v4 = v[5],
        }
    end
    return ret
end

kanji_full_table[0x8770] = "㎝"

local command_table = {
    ["0000000001"] = "<C:B>",
    ["0000000002"] = "<C:G>",
    ["0000000003"] = "<C:R>",
    ["100001"] = "<LF>",
}

---(デフォルトでRAM領域の)sjis領域のテキストを取得する
---@param output "file" | "stdout"
---@param addr int
---@param options? {is_rom?: bool, bound?: int, end_addr?: int, filename?: string}
local function dump_text(output, addr, options)
    options = options or {}
    local use_file = output == "file"
    local is_rom = options.is_rom == true
    local end_addr = options.end_addr or (addr + (options.bound or 0x800))
    local filename = options.filename or "ryori_text.txt"
    local _format = (function()
        if use_file then
            return function(s) return s .. "\n" end
        else
            return function(s) return s end
        end
    end)()
    local _r32 = is_rom and r32r or r32
    sjis.options.dbl_space_str = use_file and "　" or "<SP>"
    sjis.options.half_space_str = use_file and " " or "<sp>"
    sjis.options.special_table = kanji_full_table
    sjis.options.silent = true
    sjis.options.is_char = function(code) return code ~= 0 end
    sjis.options.special_reader = function(_addr)
        if r8(_addr) == 0x1a then
            local len = r8(_addr + 1)
            local s = ""
            for j = 3, len do
                s = s .. string.format("%02X", r8(_addr + j - 1))
            end
            s = command_table[s] or ("<COM:" .. s .. ">")
            return {
                t = s,
                len = len,
                valid = true,
                is_char = true,
            }
        end
    end

    local iter = sjis.iter(addr, not is_rom)
    if not use_file then CLS() end
    local i = 0
    local buf = ""
    local file = lib.path.w(use_file and filename)
    if use_file then
        print("[dump_text] start")
    end
    while true do
        for c in iter:it() do
            if c ~= "\\0" then
                buf = buf .. c
            end
        end
        if buf == "DAT1" then
            if use_file then
                print("[dump_text] Detected \"DAT1\"")
            end
            -- 後続の4byteはテキスト領域の長さ(Big Endian)。このデータは無視する。
            iter.addr = iter.addr + 4
        elseif buf == "STR1" then
            file:write("<EOF>\n\n")
            buf = ""
            break
        end
        file:write(string.format("0x%08X\n%s\n", iter.first_addr, _format(buf)))
        buf = ""
        if iter.addr >= end_addr then break end
    end
    if buf ~= "" then
        file:write(string.format("0x%08X: %s\n", iter.first_addr, _format(buf)))
    end
    file:close()
    if use_file then
        print("[dump_text] done")
    end
end

return {
    options = VT_options,
    vt = vt,
    print_vt = print_vt,
    get_vt = get_vt,
    set_vt = set_vt,
    dump_text = dump_text,
}
