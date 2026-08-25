

local table_special = {
    [0x0a] = "\\n",
    [0x00] = "\\0",
}

local table_half_width_from_20 = {
" ", "!", "\"", "#", "$", "%", "&", "'", "(", ")", "*", "+", ",", "-", ".", "/",
"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ":", ";", "<", "=", ">", "?",
"@", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O",
"P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "[", "\\", "]", "^", "_",
"`", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o",
"p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "{", "|", "}", "~", nil,
nil,nil,nil,nil,     nil,nil,nil,nil,     nil,nil,nil,nil,     nil,nil,nil,nil,
nil,nil,nil,nil,     nil,nil,nil,nil,     nil,nil,nil,nil,     nil,nil,nil,nil,
nil, "｡", "｢", "｣", "､", "･", "ｦ", "ｧ", "ｨ", "ｩ", "ｪ", "ｫ", "ｬ", "ｭ", "ｮ", "ｯ",
"ｰ", "ｱ", "ｲ", "ｳ", "ｴ", "ｵ", "ｶ", "ｷ", "ｸ", "ｹ", "ｺ", "ｻ", "ｼ", "ｽ", "ｾ", "ｿ",
"ﾀ", "ﾁ", "ﾂ", "ﾃ", "ﾄ", "ﾅ", "ﾆ", "ﾇ", "ﾈ", "ﾉ", "ﾊ", "ﾋ", "ﾌ", "ﾍ", "ﾎ", "ﾏ",
"ﾐ", "ﾑ", "ﾒ", "ﾓ", "ﾔ", "ﾕ", "ﾖ", "ﾗ", "ﾘ", "ﾙ", "ﾚ", "ﾛ", "ﾜ", "ﾝ", "ﾞ", "ﾟ",
}

local table_from_8140 = {
    "　", "、", "。", "，", "．", "・", "：", "；", "？", "！", "゛", "゜", "’", "`", "\"", "^",
    -- nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "ー", "ー", nil, "／", nil,
    "￣", "＿", "ヽ", "ヾ", "ゝ", "ゞ", "〃", "仝", "々", "〆", "〇", "ー", "―", "‐", "／", "＼",
    -- "～", nil, nil, "…", "‥", nil, nil, nil, nil, "（", "）", nil, nil, nil, nil, nil,
    "～", "∥", "｜", "…", "‥", "‘", "’", "“", "”", "（", "）", "〔", "〕", "［", "］", "｛",
    -- nil, nil, nil, nil, nil, "「", "」", nil, nil, "[", "]", "＋", "－", "±", "×", nil,
    "｝", "〈", "〉", "《", "》", "「", "」", "『", "』", "【", "】", "＋", "－", "±", "×", nil,
    -- "÷", "＝", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
    "÷", "＝", "≠", "＜", "＞", "≦", "≧", "∞", "∴", "♂", "♀", "°", "′", "″", "℃", "￥",
    -- nil, nil, nil, nil, nil, "＆", nil, nil, nil, "☆", "★", "○", nil, "◎", nil, nil,
    "＄", "￠", "￡", "％", "＃", "＆", "＊", "＠", "§", "☆", "★", "○", "●", "◎", "◇", "◆",
    -- nil, nil, "△", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
    "□", "■", "△", "▲", "▽", "▼", "※", "〒", "→", "←", "↑", "↓", "〓", nil, nil, nil,
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
[0x88ab] = "悪",
[0x88c0] = "安",
[0x88ea] = "一",
[0x89a4] = "王",
[0x89b9] = "音",
[0x89ba] = "下",
[0x89bd] = "何",
[0x89ef] = "会",
[0x89f1] = "回",
[0x8a43] = "海",
[0x8a4a] = "開",
[0x8a77] = "学",
[0x8a79] = "楽",
[0x8ab4] = "感",
[0x8ad4] = "間",
[0x8adb] = "丸",
[0x8ae7] = "顔",
[0x8b43] = "気",
[0x8b78] = "休",
[0x8b7d] = "急",
[0x8b86] = "究",
[0x8b89] = "級",
[0x8bad] = "強",
[0x8bb3] = "教",
[0x8bdf] = "近",
[0x8bf3] = "空",
[0x8c5a] = "兄",
[0x8c88] = "決",
[0x8ca4] = "研",
[0x8ca9] = "見",
[0x8cbe] = "言",
[0x8ce3] = "後",
[0x8cf6] = "公",
[0x8cfc] = "向",
[0x8d4c] = "広",
[0x8d5a] = "校",
[0x8d62] = "甲",
[0x8d6c] = "考",
[0x8d73] = "行",
[0x8d87] = "合",
[0x8d95] = "黒",
[0x8d9e] = "込",
[0x8da1] = "今",
[0x8db7] = "差",
[0x8dc5] = "最",
[0x8dcb] = "才",
[0x8e45] = "殺",
[0x8e67] = "使",
[0x8e6d] = "士",
[0x8e6e] = "始",
[0x8e71] = "子",
[0x8e76] = "思",
[0x8e96] = "事",
[0x8e9d] = "持",
[0x8e9e] = "時",
[0x8e9f] = "次",
[0x8ea9] = "自",
[0x8eae] = "式",
[0x8ed2] = "者",
[0x8ee3] = "弱",
[0x8ee5] = "主",
[0x8ee6] = "取",
[0x8ee7] = "守",
[0x8ee8] = "手",
[0x8ef1] = "首",
[0x8f49] = "終",
[0x8f57] = "集",
[0x8f6f] = "出",
[0x8f8a] = "所",
[0x8f91] = "書",
[0x8f97] = "女",
[0x8f9f] = "勝",
[0x8fa4] = "商",
[0x8fab] = "将",
[0x8fac] = "小",
[0x8fad] = "少",
[0x8fe3] = "上",
[0x8fea] = "場",
[0x9053] = "心",
[0x9056] = "新",
[0x906c] = "人",
[0x9094] = "数",
[0x90b3] = "正",
[0x90b6] = "生",
[0x90ba] = "声",
[0x90ce] = "石",
[0x90e6] = "先",
[0x90ec] = "川",
[0x90ed] = "戦",
[0x914f] = "前",
[0x9153] = "全",
[0x9167] = "組",
[0x9181] = "早",
[0x918a] = "相",
[0x9197] = "送",
[0x91ab] = "足",
[0x91bd] = "多",
[0x91cc] = "体",
[0x91d2] = "待",
[0x91e5] = "大",
[0x926a] = "男",
[0x926d] = "知",
[0x9286] = "中",
[0x928e] = "虫",
[0x92b7] = "長",
[0x92e8] = "定",
[0x9356] = "天",
[0x9358] = "店",
[0x9378] = "度",
[0x9396] = "当",
[0x93af] = "同",
[0x93fa] = "日",
[0x93fc] = "入",
[0x9483] = "買",
[0x948e] = "博",
[0x94ad] = "発",
[0x954b] = "必",
[0x955c] = "表",
[0x9573] = "不",
[0x9589] = "負",
[0x95aa] = "分",
[0x95b7] = "聞",
[0x95d4] = "返",
[0x95fb] = "方",
[0x967b] = "本",
[0x9688] = "毎",
[0x96bc] = "名",
[0x96d8] = "木",
[0x96da] = "目",
[0x9752] = "由",
[0x976c] = "様",
[0x9788] = "来",
[0x978e] = "落",
[0x9798] = "利",
[0x979d] = "理",
[0x97cd] = "力",
[0x9862] = "話",
[0x9756] = "遊",
[0x9492] = "白",
[0x8ec0] = "実",
[0x97a7] = "立",
[0x8bc9] = "極",
[0x8b41] = "帰",
[0x8be0] = "金",
[0x96e9] = "夜",
[0x90a2] = "世",
[0x95bd] = "平",
[0x91e6] = "第",
[0x9285] = "着",
[0x8c5e] = "型",
[0x8e64] = "仕",
[0x8a47] = "絵",
[0x96e2] = "問",
[0x91e8] = "題",
[0x928d] = "注",
[0x95e0] = "歩",
[0x8ca2] = "犬",
[0x91bc] = "他",
[0x88e7] = "育",
[0x9069] = "進",
[0x96a1] = "味",
[0x88d3] = "意",
[0x8a4f] = "外",
[0x8ef3] = "受",
[0x9574] = "付",
[0x90ac] = "成",
[0x89ca] = "果",
[0x92b4] = "超",
[0x944e] = "年",
[0x91c5] = "打",
[0x8e7e] = "止",
[0x9085] = "水",
[0x89ce] = "火",
[0x9196] = "走",
[0x88f8] = "引",
[0x8a70] = "角",
[0x8e52] = "山",
[0x8c60] = "形",
[0x89a1] = "横",
[0x8e9a] = "字",
[0x90d8] = "切",
[0x9065] = "親",
[0x9067] = "身",
[0x97ce] = "緑",
[0x9046] = "色",
[0x9774] = "葉",
[0x947b] = "倍",
[0x97b7] = "旅",
[0x8d91] = "国",
[0x8f95] = "助",
[0x89cc] = "歌",
[0x9048] = "食",
[0x93aa] = "頭",
[0x92bc] = "直",
[0x94d4] = "番",
[0x8f4b] = "習",
[0x9687] = "枚",
[0x92ed] = "弟",
[0x92ca] = "通",
[0x93b9] = "道",
[0x8bef] = "具",
[0x9770] = "用",
[0x939a] = "答",
[0x926c] = "値",
[0x94bd] = "反",
[0x91ce] = "対",
[0x8dec] = "作",
[0x95d0] = "片",
[0x93f1] = "二",
[0x96ca] = "面",
[0x8f5c] = "十",
[0x905e] = "真",
[0x95d3] = "辺",
[0x8f89] = "初",
[0x90ab] = "性",
[0x8d82] = "高",
[0x8b4c] = "記",
[0x89af] = "憶",
[0x8ee1] = "若",
[0x96f0] = "役",
[0x8ea8] = "耳",
[0x926e] = "地",
[0x8cfb] = "口",
[0x8c8e] = "月",
[0x8d48] = "工",
[0x89c4] = "夏",
[0x974c] = "有",
[0x9594] = "部",
[0x89ae] = "屋",
[0x89c6] = "家",
[0x89e6] = "画",
[0x899b] = "央",
[0x8945] = "右",
[0x8db6] = "左",
[0x8cb3] = "元",
[0x93ae] = "動",
[0x92ac] = "町",
[0x9379] = "土",
[0x89d4] = "花",
[0x8ccb] = "戸",
[0x9363] = "田",
[0x88f5] = "員",
[0x8c76] = "計",
[0x8cf5] = "光",
[0x8a45] = "界",
[0x8cea] = "語",
[0x95b6] = "文",
[0x935d] = "転",
[0x9848] = "路",
[0x9746] = "友",
[0x8b4e] = "起",
[0x9360] = "伝",
[0x8a69] = "格",
[0x91b1] = "続",
[0x95cf] = "変",
[0x8ef6] = "授",
[0x8bc6] = "業",
[0x8f80] = "準",
[0x94f5] = "備",
[0x91be] = "太",
[0x9543] = "匹",
[0x905f] = "神",
[0x8ed0] = "社",
[0x8c83] = "激",
[0x8b7b] = "宮",
[0x9383] = "塔",
[0x9373] = "都",
[0x8e86] = "紙",
[0x88ca] = "位",
[0x8948] = "羽",
[0x8993] = "遠",
[0x899f] = "押",
[0x89a9] = "黄",
[0x89c1] = "加",
[0x8a88] = "活",
[0x8aae] = "完",
[0x8b63] = "議",
[0x8ba5] = "凶",
[0x8bb0] = "恐",
[0x8bb9] = "胸",
[0x8bbb] = "興",
[0x8bea] = "苦",
[0x8c52] = "軍",
[0x8c82] = "撃",
[0x8cc4] = "呼",
[0x8d44] = "好",
[0x8d55] = "攻",
[0x8d72] = "荒",
[0x8e70] = "姿",
[0x8e97] = "似",
[0x8eaf] = "識",
[0x8ed4] = "車",
[0x8ef5] = "寿",
[0x8f48] = "秋",
[0x8f5a] = "住",
[0x8f64] = "重",
[0x8f74] = "春",
[0x8f8b] = "暑",
[0x905b] = "深",
[0x90c2] = "青",
[0x90cc] = "昔",
[0x90d4] = "赤",
[0x9188] = "争",
[0x91ac] = "速",
[0x91e3] = "代",
[0x9242] = "達",
[0x925a] = "短",
[0x9269] = "段",
[0x9275] = "置",
[0x927c] = "竹",
[0x9283] = "茶",
[0x9287] = "仲",
[0x92a5] = "徴",
[0x92c7] = "追",
[0x9353] = "鉄",
[0x935f] = "点",
[0x936f] = "登",
[0x937b] = "怒",
[0x9387] = "島",
[0x938a] = "投",
[0x93a6] = "逃",
[0x93be] = "得",
[0x93c1] = "特",
[0x93c6] = "独",
[0x93e4] = "謎",
[0x9477] = "背",
[0x9497] = "迫",
[0x94df] = "悲",
[0x94e4] = "比",
[0x94e9] = "秘",
[0x94f2] = "飛",
[0x94fc] = "美",
[0x9581] = "普",
[0x95a0] = "腹",
[0x95a8] = "物",
[0x95b1] = "奮",
[0x95fa] = "放",
[0x965c] = "暴",
[0x96a3] = "魅",
[0x96bd] = "命",
[0x96cd] = "模",
[0x96d1] = "毛",
[0x96f4] = "躍",
[0x97a0] = "裏",
[0x97a4] = "陸",
[0x97d1] = "林",
[0x97d6] = "輪",
[0x9841] = "連",
[0x92a0] = "帳",
[0x8afa] = "期",
[0x88cc] = "偉",
[0x8970] = "英",
[0x89d8] = "華",
[0x89f6] = "怪",
[0x8a5a] = "鎧",
[0x8a95] = "兜",
[0x8aa6] = "寒",
[0x8aed] = "器",
[0x8aef] = "奇",
[0x8b52] = "騎",
[0x8b74] = "逆",
[0x8b90] = "巨",
[0x8be2] = "銀",
[0x8c8c] = "血",
[0x8cb4] = "原",
[0x8cb6] = "幻",
[0x8cec] = "護",
[0x8d81] = "香",
[0x8d9c] = "骨",
[0x8e47] = "雑",
[0x8e4b] = "錆",
[0x8e74] = "師",
[0x90d5] = "跡",
[0x90e0] = "説",
[0x91d1] = "帯",
[0x9382] = "唐",
[0x93c7] = "読",
[0x93ec] = "南",
[0x944d] = "熱",
[0x957c] = "怖",
[0x9597] = "風",
[0x95a1] = "複",
[0x95ba] = "兵",
[0x95c4] = "米",
[0x95f3] = "宝",
[0x966b] = "北",
[0x96b3] = "無",
[0x9759] = "雄",
[0x97ed] = "麗",
[0x9866] = "惑",
}
local function is_maybe_kanji(code)
    return (code >= 0x889f and code <= 0x9872) or
        (code >= 0x989f and code <= 0x9fff) or
        (code >= 0xe040 and code <= 0xeaa4)
end
local invalid_char = "_"

---@alias SJisIterSpecialReader fun(addr: integer, first_char_found: boolean): {t: string, len: integer, valid?: boolean, is_char?: boolean}?

---@class SJISOptions
---@field silent bool
---@field half_space_str string
---@field dbl_space_str string
---@field special_reader SJisIterSpecialReader
---@field is_char fun(code: integer): boolean
local options = {
    silent = false,
    half_space_str = "<sp>",
    dbl_space_str = "<SP>",
    special_reader = function()end,
    is_char = function(code) return code ~= 0 end,
}

---@param code int
---@return string?
local function try_get_space(code)
    if code == 0x20 then return options.half_space_str
    elseif code == 0x8140 then return options.dbl_space_str
    else return nil
    end
end

---@param code int
---@return string?
local function to_char(code)
    return (
        table_special[code] or
        try_get_space(code) or
        table_half_width_from_20[code-0x20+1] or
        table_from_8140[code-0x8140+1] or
        table_from_8240[code-0x8240+1] or
        table_from_8340[code-0x8340+1] or
        table_kanji[code]
    )
end


---@alias SJisAddrIterObj {valid: boolean, len: int, addr: int, first_addr: int, next: (fun(self: SJisAddrIterObj): string?), it: (fun(self: SJisAddrIterObj): (fun(self: SJisAddrIterObj): string?))}
---@alias SJisArrayIterObj {valid: boolean, len: int, idx: int, next: (fun(self: SJisArrayIterObj): string?), it: (fun(self: SJisArrayIterObj): (fun(self: SJisArrayIterObj): string?))}

---@param data int[]
---@return SJisArrayIterObj
local function iter_array(data)
    local special_reader = options.special_reader
    local v, c, v2
    ---@param self SJisArrayIterObj
    local next = function(self)
        self.valid = true
        self.len = 1
        local s = special_reader(self.idx, false)
        if s then
            self.idx = self.idx + s.len
            return s.valid and s.t or invalid_char
        end
        v = data[self.idx]
        self.idx = self.idx + 1
        if not v then
            return nil
        end
        c = to_char(v)
        if c then return c end
        v2 = data[self.idx]
        self.idx = self.idx + 1
        if not v2 then
            return nil
        end
        v = (v << 8) | v2
        c = to_char(v)
        self.len = 2
        if c then return c end
        if not options.silent then
            print(string.format("[unknown] %04X", v))
        end
        self.valid = false
        return invalid_char
    end
    ---@param self SJisArrayIterObj
    local it = function(self) return self end
    return setmetatable({
        next = next,
        idx = 1,
        len = 1,
        valid = true,
        it = it,
    }, {
        ---@param obj SJisArrayIterObj
        __call = function(obj)
            return obj:next()
        end
    })
end

---@param addr int
---@param is_ram? bool
---@return SJisAddrIterObj
local function iter_addr(addr, is_ram)
    local special_reader = options.special_reader
    local is_char = options.is_char
    local count = 0
    local first_char_found = false
    local is_first = true
    local _r = is_ram and r8 or r8r
    local v, c, _is_char
    local ending = function()
        is_first = true
        first_char_found = false
        count = 0
        return nil
    end
    ---@param self SJisAddrIterObj
    local next = function(self)
        count = count + 1
        assert(count < 10000, "TOO LONG")
        self.valid = true
        self.len = 1
        if not is_first then
            self.addr = self.addr + 1
        end
        is_first = false
        local s = special_reader(self.addr, first_char_found)
        if s then
            self.valid = s.valid ~= false
            self.len = s.len
            _is_char = s.is_char ~= false
            if _is_char and (not first_char_found) then
                self.first_addr = self.addr
                first_char_found = true
            elseif first_char_found and (not _is_char) then
                return ending()
            end
            self.addr = self.addr + s.len - 1
            return self.valid and s.t or invalid_char
        end
        v = _r(self.addr)
        _is_char = is_char(v)
        if first_char_found and (not _is_char) then
            return ending()
        end
        c = to_char(v)
        if c then
            if (not first_char_found) and _is_char then
                self.first_addr = self.addr
                first_char_found = true
            end
            return c
        end
        self.addr = self.addr + 1
        self.len = 2
        v = (v << 8) | _r(self.addr)
        c = to_char(v)
        _is_char = is_char(v)
        if c then
            if (not first_char_found) and _is_char then
                self.first_addr = self.addr - 1
                first_char_found = true
            end
            return c
        end
        if not options.silent then
            print(string.format("[unknown] %04X", v))
        end
        self.valid = false
        return invalid_char
    end
    ---@param self SJisArrayIterObj
    local it = function(self) return self end
    return setmetatable({
        next = next,
        addr = addr,
        len = 1,
        first_addr = addr,
        valid = true,
        it = it,
    }, {
        ---@param obj SJisAddrIterObj
        __call = function(obj)
            return obj:next()
        end
    })
end

--- 実行例:
--- ```lua
--- local buf = ""
--- local i = 0
--- for char, stat in iter(addr) do
---     buf = buf .. char
---     i = i + stat.len
---     if i >= 16 then
---         print(buf) buf = ""
---         i = i - 16
---     end
--- end
--- ```
--- 
---@param addr int
---@param is_ram? bool
---@return SJisAddrIterObj
---@overload fun(data: int[]): SJisArrayIterObj
local function iter(addr, is_ram)
    if type(addr) == "number" then
        return iter_addr(addr, is_ram)
    else
        return iter_array(addr--[[@as (int[])]])
    end
end

return {
    options = options,
    is_maybe_kanji = is_maybe_kanji,
    to_char = to_char,
    iter = iter,
}
