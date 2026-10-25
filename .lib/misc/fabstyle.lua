
local sjis = require "misc/sjis"
local _N = false
local hiragana = {
_N, _N, _N, _N, _N, _N, "を", "ぁ", "ぃ", "ぅ", "ぇ", "ぉ", "ゃ", "ゅ", "ょ", "っ",
_N, "あ", "い", "う", "え", "お", "か", "き", "く", "け", "こ", "さ", "し", "す", "せ", "そ",
"た", "ち", "つ", "て", "と", "な", "に", "ぬ", "ね", "の", "は", "ひ", "ふ", "へ", "ほ", "ま",
"み", "む", "め", "も", "や", "ゆ", "よ", "ら", "り", "る", "れ", "ろ", "わ", "ん", _N, _N,
_N, _N, _N, _N, _N, _N, "が", "ぎ", "ぐ", "げ", "ご", "ざ", "じ", "ず", "ぜ", "ぞ",
"だ", "ぢ", "づ", "で", "ど", _N, _N, _N, _N, _N, "ば", "び", "ぶ", "べ", "ぼ", _N,
_N, _N, _N, _N, _N, _N, _N, _N, _N, _N, "ぱ", "ぴ", "ぷ", "ぺ", "ぽ", _N,

_N, _N, _N, _N, _N, _N, "ヲ", "ァ", "ィ", "ゥ", "ェ", "ォ", "ャ", "ュ", "ョ", "ッ",
_N, "ア", "イ", "ウ", "エ", "オ", "カ", "キ", "ク", "ケ", "コ", "サ", "シ", "ス", "セ", "ソ",
"タ", "チ", "ツ", "テ", "ト", "ナ", "ニ", "ヌ", "ネ", "ノ", "ハ", "ヒ", "フ", "ヘ", "ホ", "マ",
"ミ", "ム", "メ", "モ", "ヤ", "ユ", "ヨ", "ラ", "リ", "ル", "レ", "ロ", "ワ", "ン", _N, _N,
_N, _N, _N, _N, _N, _N, "ガ", "ギ", "グ", "ゲ", "ゴ", "ザ", "ジ", "ズ", "ゼ", "ゾ",
"ダ", "ヂ", "ヅ", "デ", "ド", _N, _N, _N, _N, _N, "バ", "ビ", "ブ", "ベ", "ボ", _N,
_N, _N, _N, _N, _N, _N, _N, _N, _N, _N, "パ", "ピ", "プ", "ペ", "ポ", _N,
}

---@param addr int
---@param end_addr int?
---@param bound_until_first_text int?
---@param is_ram bool?
---@return string
local function read_text(addr, end_addr, bound_until_first_text, is_ram)
    end_addr = end_addr or (addr + 0x2000)
    bound_until_first_text = bound_until_first_text or 0xff
    local domain = (not is_ram) and ROM_DOMAIN_NAME or nil
    local is_katakana = false
    local found, _first = lib.find(addr, addr+bound_until_first_text, {5,5,5}, 3, domain, true)
    if not found then print("NOT FOUND TEXT DATA from " .. string.format("%08X", addr)) end
    local a = _first + 3
    local function _r()
        local v = r8(a, domain)
        a = a + 1
        return v
    end
    local s = ""
    local color = 0
    local function read_sp()
        local c2 = _r()
        if c2 == 0x4B then is_katakana = true return end
        is_katakana = false
        if c2 == 0x48 then return end
        if c2 == 0x43 then
            color = _r() & 0xf
            s = s .. string.format("\\C%x", color)
            return
        end
        if c2 == 0x68 then
            local _s = ""
            while true do
                local v = _r()
                if not within(v, 0x30, 0x39) then
                    a = a - 1
                    s = s .. string.format("\\h{%s}", _s)
                    return
                end
                _s = _s .. tostring(v-0x30)
            end
        end
        print(string.format("UNKNOWN SPECIAL SEQUENCE: \"1B %02X\" (at 0x%08X)", c2, a))
    end
    ---@type string?
    local addr_text = string.format("\n\n0x%08X\n", a)
    while true do
        local c1 = _r()
        if a >= end_addr then return s .. "\n" end
        if c1 == 0xff then return s .. "\n" end
        if c1 == 0xfd then
            if r8(a, domain) == 0xfd and r8(a+1, domain) == 0xfd then
                return s .. "\n"
            end
        end
        if addr_text then
            s = s .. addr_text
            addr_text = nil
        end
        if c1 == 0x0a then s = s .. "\n"
        elseif within(c1, 0x20, 0x7e) then
            s = s .. string.char(c1)
        elseif c1 == 5 then
            a = a + 2
            is_katakana = false
            addr_text = string.format("\n\n0x%08X\n", a)
        elseif c1 == 0x1b then read_sp()
        elseif within(c1, 0xA6, 0xDD) then
            local offset = c1 - 0xa0 + 1
            if is_katakana then offset = offset + 0x70 end
            local c2 = _r()
            ---@type string | false
            local char = false
            if c2 == 0xDE and c1 == 0xB3 then char = "ヴ"
            elseif c2 == 0xDE then offset = offset + 0x30
            elseif c2 == 0xDF then offset = offset + 0x40
            else a = a - 1
            end
            char = char or hiragana[offset]
            if type(char) == "string" then
                s = s .. char
            else print(string.format("unknown hiragana %2x (at 0x%08X)", c1, a))
            s = s .. "_"
            end
        else
            local c2 = _r()
            local v = (c1 << 8) | c2
            local char = sjis.to_char(v)
            if char then
                s = s .. char
            else print(string.format("unknown kanji %04x (at 0x%08X)", v, a)) s = s .. "_"
            end
        end
    end
end

---@param addr int
---@param end_addr int?
---@param is_ram bool?
---@param writer_query WriterQuery ファイル名(`string`)または標準出力(`bool?`)
local function dump_text(addr, end_addr, is_ram, writer_query)
    local text = read_text(addr, end_addr, nil, is_ram)
    local file = lib.path.w(writer_query)
    file:wl(text)
    file:close()
end

return {
    read_text = read_text,
    dump_text = dump_text,
}
