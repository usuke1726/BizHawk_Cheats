
local table_special = {
}

local table_from_8140 = {
    "␣", "、", "。", "，", "．", "・", "：", "；", "？", "！", "゛", "゜", "’", "`", "\"", "^",
    nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "ー", "ー", nil, "／", nil,
    "～", nil, nil, "…", "‥", nil, nil, nil, nil, "（", "）", nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, "「", "」", nil, nil, "[", "]", "＋", "－", "±", "×", nil,
    "÷", "＝", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, "＆", nil, nil, nil, "☆", "★", "○", nil, "◎", nil, nil,
    nil, nil, "△", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
}
local table_from_8240 = {
    nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "０",
    "１", "２", "３", "４", "５", "６", "７", "８", "９", nil, nil, nil, nil, nil, nil, nil,
    "Ａ", "Ｂ", "Ｃ", "Ｄ", "Ｅ", "Ｆ", "Ｇ", "Ｈ", "Ｉ", "Ｊ", "Ｋ", "Ｌ", "Ｍ", "Ｎ", "Ｏ", "Ｐ",
    "Ｑ", "Ｒ", "Ｓ", "Ｔ", "Ｕ", "Ｖ", "Ｗ", "Ｘ", "Ｙ", "Ｚ", nil, nil, nil, nil, nil, nil,
    nil, "ａ", "ｂ", "ｃ", "ｄ", "ｅ", "ｆ", "ｇ", "ｈ", "ｉ", "ｊ", "ｋ", "ｌ", "ｍ", "ｎ", "ｏ",
    "ｐ", "ｑ", "ｒ", "ｓ", "ｔ", "ｕ", "ｖ", "ｗ", "ｘ", "ｙ", "ｚ", nil, nil, nil, nil, "ぁ",
    "あ", "ぃ", "い", "ぅ", "う", "ぇ", "え", "ぉ", "お", "か", "が", "き", "ぎ", "く", "ぐ", "け",
    "げ", "こ", "ご", "さ", "ざ", "し", "じ", "す", "ず", "せ", "ぜ", "そ", "ぞ", "た", "だ", "ち",
    "ぢ", "っ", "つ", "づ", "て", "で", "と", "ど", "な", "に", "ぬ", "ね", "の", "は", "ば", "ぱ",
    "ひ", "び", "ぴ", "ふ", "ぶ", "ぷ", "へ", "べ", "ぺ", "ほ", "ぼ", "ぽ", "ま", "み", "む", "め",
    "も", "ゃ", "や", "ゅ", "ゆ", "ょ", "よ", "ら", "り", "る", "れ", "ろ", nil, "わ", nil, nil,
    "を", "ん", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
}
local table_from_8340 = {
    "ァ", "ア", "ィ", "イ", "ゥ", "ウ", "ェ", "エ", "ォ", "オ", "カ", "ガ", "キ", "ギ", "ク", "グ",
    "ケ", "ゲ", "コ", "ゴ", "サ", "ザ", "シ", "ジ", "ス", "ズ", "セ", "ゼ", "ソ", "ゾ", "タ", "ダ",
    "チ", "ヂ", "ッ", "ツ", "ヅ", "テ", "デ", "ト", "ド", "ナ", "ニ", "ヌ", "ネ", "ノ", "ハ", "バ",
    "パ", "ヒ", "ビ", "ピ", "フ", "ブ", "プ", "ヘ", "ベ", "ペ", "ホ", "ボ", "ポ", "マ", "ミ", nil,
    "ム", "メ", "モ", "ャ", "ヤ", "ュ", "ユ", "ョ", "ヨ", "ラ", "リ", "ル", "レ", "ロ", "ヮ", "ワ",
    nil, nil, "ヲ", "ン", nil, "ヵ", "ヶ", nil, nil, nil, nil, nil, nil, nil, nil, nil,
}
local table_kanji = {
}

local function is_maybe_kanji(code)
    return (code >= 0x889f and code <= 0x9872) or
        (code >= 0x989f and code <= 0x9fff) or
        (code >= 0xe040 and code <= 0xeaa4)
end

invalid_char = "_"
print_maybe_kanji = true
print_range_print_console = true
local function _f(char)
    if char == nil then return invalid_char
    else return char
    end
end
---@type table<int, bool>
local known_maybe_kanji = {}
---@param code int
---@return string
local function to_char(code)
    for key, value in pairs(table_special) do
        if code == key then return value end
    end
    if code < 0x8140 then return invalid_char
    elseif code < 0x81b0 then return _f(table_from_8140[code - 0x8140 + 1])
    elseif code < 0x8240 then return invalid_char
    elseif code < 0x8300 then return _f(table_from_8240[code - 0x8240 + 1])
    elseif code < 0x8340 then return invalid_char
    elseif code < 0x83a0 then return _f(table_from_8340[code - 0x8340 + 1])
    elseif is_maybe_kanji(code) then
        local c = table_kanji[code]
        if c then return c end
        if not known_maybe_kanji[code] then
            known_maybe_kanji[code] = true
            print(string.format("[maybe kanji] 0x%04x", code))
        end
        return invalid_char
    else return invalid_char
    end
end


---@param begin int
---@param inclusiveEnd int
---@param domain string?
local function print_range(begin, inclusiveEnd, domain)
    domain = domain or __get_domain(begin)
    local first, second, third
    local i = begin
    local _buffer = {}
    local _c = 1
    _buffer[1] = string.format("0x%08X:   ", begin)
    while true do
        first = memory.read_u8(i, domain)
        i = i + 1
        _c = _c + 1
        if first == 0x00 then
            _buffer[_c] = "\\0"
        else
            if i > inclusiveEnd then break end
            second = memory.read_u8(i, domain)
            i = i + 1
            _buffer[_c] = to_char((first << 8) | second)
            if (i & 0xf) == 0x0 then
                _c = _c + 1
                _buffer[_c] = string.format("\n0x%08X:   ", i & 0xfffffff0)
            end
        end
        if (i & 0xf) == 0xf then
            _c = _c + 1
            _buffer[_c] = string.format("\n0x%08X:   ", i + 1)
        end
        if i > inclusiveEnd then break end
    end
    print("== TEXT ==\n" .. table.concat(_buffer, ""))
end

local __sjis = {
    to_char = to_char,
    print_range = print_range,
}
sjis = {
    to_char = to_char,
    print_range = print_range,
}

return __sjis
