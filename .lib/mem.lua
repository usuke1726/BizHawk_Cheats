
---@param addr int
local function get_domain(addr)
    -- DSに特化した超簡略的な処理。後々ちゃんとしたものに修正するかも。
    if addr >= 0x03000000 and addr < 0x04000000 then
        return "ARM7 System Bus"
    else
        return "ARM9 System Bus"
    end
end
__get_domain = get_domain

---@param addr int
---@param domain string?
---@return int
local function _r8(addr, domain)
    return memory.read_u8(addr, domain or get_domain(addr))
end
---@param addr int
---@param value u8
---@param domain string?
local function _w8(addr, value, domain)
    memory.write_u8(addr, value, domain or get_domain(addr))
end
---指定したアドレス(補正付き)から**Little Endianで**2バイト読み込む。
---@param addr int
---@param domain string?
---@return int
local function _r16(addr, domain)
    return memory.read_u16_le(addr, domain or get_domain(addr))
end
---指定したアドレス(補正付き)に**Little Endianで**2バイト書き込む。
---@param addr int
---@param value u16
---@param domain string?
local function _w16(addr, value, domain)
    memory.write_u16_le(addr, value, domain or get_domain(addr))
end
---指定したアドレス(補正付き)から**Little Endianで**4バイト読み込む。
---@param addr int
---@param domain string?
---@return int
local function _r32(addr, domain)
    return memory.read_u32_le(addr, domain or get_domain(addr))
end
---指定したアドレス(補正付き)に**Little Endianで**4バイト書き込む。
---@param addr int
---@param value u32
---@param domain string?
local function _w32(addr, value, domain)
    memory.write_u32_le(addr, value, domain or get_domain(addr))
end
r8 = _r8
r16 = _r16
r32 = _r32
w8 = _w8
w16 = _w16
w32 = _w32

---@param addr int
---@param value int
---@param min_? int
---@param max_? int
---@param domain string?
local function _add8(addr, value, min_, max_, domain)
    domain = domain or get_domain(addr)
    _w8(addr, __util.stou8(__util.clamp8(_r8(addr, domain) + value, min_, max_)), domain)
end
---@param addr int
---@param value int
---@param min_? int
---@param max_? int
---@param domain string?
local function _add16(addr, value, min_, max_, domain)
    domain = domain or get_domain(addr)
    _w16(addr, __util.stou16(__util.clamp16(_r16(addr, domain) + value, min_, max_)), domain)
end
---@param addr int
---@param value int
---@param min_? int
---@param max_? int
---@param domain string?
local function _add32(addr, value, min_, max_, domain)
    domain = domain or get_domain(addr)
    _w32(addr, __util.stou32(__util.clamp32(_r32(addr, domain) + value, min_, max_)), domain)
end
add8 = _add8
add16 = _add16
add32 = _add32

local _ROM_DOMAIN_NAME = "ROM"
ROM_DOMAIN_NAME = _ROM_DOMAIN_NAME

---ROM領域のアドレスから1バイト書き込む。
---@param addr int
---@return int
local function _rom_r8(addr)
    return memory.read_u8(addr, _ROM_DOMAIN_NAME)
end
---ROM領域のアドレスに1バイト書き込む。
---@param addr int
---@param value u8
local function _rom_w8(addr, value)
    memory.write_u8(addr, value, _ROM_DOMAIN_NAME)
end
---ROM領域の指定したアドレス(補正付き)から**Little Endianで**2バイト読み込む。
---@param addr int
---@return int
local function _rom_r16(addr)
    return memory.read_u16_le(addr, _ROM_DOMAIN_NAME)
end
---ROM領域の指定したアドレス(補正付き)に**Little Endianで**2バイト書き込む。
---@param addr int
---@param value u16
local function _rom_w16(addr, value)
    memory.write_u16_le(addr, value, _ROM_DOMAIN_NAME)
end
---ROM領域の指定したアドレス(補正付き)から**Little Endianで**4バイト読み込む。
---@param addr int
---@return int
local function _rom_r32(addr)
    return memory.read_u32_le(addr, _ROM_DOMAIN_NAME)
end
---ROM領域の指定したアドレス(補正付き)に**Little Endianで**4バイト書き込む。
---@param addr int
---@param value u32
local function _rom_w32(addr, value)
    memory.write_u32_le(addr, value, _ROM_DOMAIN_NAME)
end
romr8 = _rom_r8
romw8 = _rom_w8
romr16 = _rom_r16
romw16 = _rom_w16
romr32 = _rom_r32
romw32 = _rom_r32

r8r = _rom_r8
r16r = _rom_r16
r32r = _rom_r32
w8r = _rom_w8
w16r = _rom_w16
w32r = _rom_w32

---@class AtObj
---@field domain string
---@field addr int
---@field protected _first_domain string
---@field protected _first_addr int
---@operator add(int): AtObj
---@operator sub(int): AtObj
---@overload fun(new_addr: int?): AtObj
local AtObj = {}

---登録されているアドレスに1バイト書き込む。
---@param value int
function AtObj:w8(value) _w8(self.addr, value, self.domain) return self end
---登録されているアドレス(補正付き)に**Little Endianで**2バイト書き込む。
---@param value int
function AtObj:w16(value) _w16(self.addr, value, self.domain) return self end
---登録されているアドレス(補正付き)に**Little Endianで**4バイト書き込む。
---@param value int
function AtObj:w32(value) _w32(self.addr, value, self.domain) return self end
---登録されているアドレスに1バイト書き込む。ただし`nil`の場合は書き込まない。
---@param value? int
function AtObj:w8n(value) return value and self:w8(value) or self end
---登録されているアドレス(補正付き)に**Little Endianで**2バイト書き込む。ただし`nil`の場合は書き込まない。
---@param value? int
function AtObj:w16n(value) return value and self:w16(value) or self end
---登録されているアドレス(補正付き)に**Little Endianで**4バイト書き込む。ただし`nil`の場合は書き込まない。
---@param value? int
function AtObj:w32n(value) return value and self:w32(value) or self end
---登録されているアドレスから1バイト読み込む。
---@return int
function AtObj:r8() return _r8(self.addr, self.domain) end
---登録されているアドレス(補正付き)から**Little Endianで**2バイト読み込む。
---@return int
function AtObj:r16() return _r16(self.addr, self.domain) end
---登録されているアドレス(補正付き)から**Little Endianで**4バイト読み込む。
---@return int
function AtObj:r32() return _r32(self.addr, self.domain) end

---@param value int
---@param min_? int
---@param max_? int
function AtObj:add8(value, min_, max_) _add8(self.addr, value, min_, max_, self.domain) return self end
---@param value int
---@param min_? int
---@param max_? int
function AtObj:add16(value, min_, max_) _add16(self.addr, value, min_, max_, self.domain) return self end
---@param value int
---@param min_? int
---@param max_? int
function AtObj:add32(value, min_, max_) _add32(self.addr, value, min_, max_, self.domain) return self end


---`th`の値を超えていたら書き込む。
---@param th int
---@param value int
---@return AtObj
function AtObj:T8(th, value) if self:r8() > th then self:w8(value) end return self end
---`th`の値を超えていたら書き込む。
---@param th int
---@param value int
---@return AtObj
function AtObj:T16(th, value) if self:r16() > th then self:w16(value) end return self end
---`th`の値を超えていたら書き込む。
---@param th int
---@param value int
---@return AtObj
function AtObj:T32(th, value) if self:r32() > th then self:w32(value) end return self end

---`th`の値を下回っていたら書き込む。
---@param th int
---@param value int
---@return AtObj
function AtObj:B8(th, value) if self:r8() < th then self:w8(value) end return self end
---`th`の値を下回っていたら書き込む。
---@param th int
---@param value int
---@return AtObj
function AtObj:B16(th, value) if self:r16() < th then self:w16(value) end return self end
---`th`の値を下回っていたら書き込む。
---@param th int
---@param value int
---@return AtObj
function AtObj:B32(th, value) if self:r32() < th then self:w32(value) end return self end

---`th`の値を超えていたら加算する。
---@param th int
---@param value int
---@param min_? int
---@param max_? int
---@return AtObj
function AtObj:Tadd8(th, value, min_, max_) if self:r8() > th then self:add8(value, min_, max_) end return self end
---`th`の値を超えていたら加算する。
---@param th int
---@param value int
---@param min_? int
---@param max_? int
---@return AtObj
function AtObj:Tadd16(th, value, min_, max_) if self:r16() > th then self:add16(value, min_, max_) end return self end
---`th`の値を超えていたら加算する。
---@param th int
---@param value int
---@param min_? int
---@param max_? int
---@return AtObj
function AtObj:Tadd32(th, value, min_, max_) if self:r32() > th then self:add32(value, min_, max_) end return self end

---`th`の値を下回っていたら加算する。
---@param th int
---@param value int
---@param min_? int
---@param max_? int
---@return AtObj
function AtObj:Badd8(th, value, min_, max_) if self:r8() < th then self:add8(value, min_, max_) end return self end
---`th`の値を下回っていたら加算する。
---@param th int
---@param value int
---@param min_? int
---@param max_? int
---@return AtObj
function AtObj:Badd16(th, value, min_, max_) if self:r16() < th then self:add16(value, min_, max_) end return self end
---`th`の値を下回っていたら加算する。
---@param th int
---@param value int
---@param min_? int
---@param max_? int
---@return AtObj
function AtObj:Badd32(th, value, min_, max_) if self:r32() < th then self:add32(value, min_, max_) end return self end

---`func`の返り値が非`nil`なら返り値で書き込む。
---@param func fun(v: int): int?
---@return AtObj
function AtObj:filter8(func) local v = func(self:r8()) if v then self:w8(v) end return self end
---`func`の返り値が非`nil`なら返り値で書き込む。
---@param func fun(v: int): int?
---@return AtObj
function AtObj:filter16(func) local v = func(self:r16()) if v then self:w16(v) end return self end
---`func`の返り値が非`nil`なら返り値で書き込む。
---@param func fun(v: int): int?
---@return AtObj
function AtObj:filter32(func) local v = func(self:r32()) if v then self:w32(v) end return self end


---メモリアドレスを`i`だけずらす。
---@param i? int
---@return AtObj self
function AtObj:step(i)
    self.addr = self.addr + (i or 1)
    return self
end
---メモリアドレスを再設定する。(ただし**ドメインは変わらない**ことを想定する。ドメインも変える場合は`withd`を用いること。)
---@param addr int
---@return AtObj self
function AtObj:with(addr)
    self.addr = addr
    return self
end
---メモリアドレスとドメインを再設定する。
---@param addr int
---@param domain string?
---@return AtObj self
function AtObj:withd(addr, domain)
    self.addr = addr
    self.domain = domain or get_domain(addr)
    return self
end
---オブジェクトを生成した初期の`domain`, `offset`に戻す。
---@return AtObj self
function AtObj:reset()
    self.domain = self._first_domain
    self.addr = self._first_addr
    return self
end
---登録されているアドレスからバイト列`bytes`を書き込んでいく。
---@param bytes int[]
---@return AtObj self
function AtObj:warr(bytes)
    for i = 1, #bytes do
        _w8(self.addr + i - 1, bytes[i], self.domain)
    end
    return self
end

---メモリ操作オブジェクトを取得する。
---@param addr int
---@param domain string?
---@return AtObj
local function at(addr, domain)
    domain = domain or get_domain(addr)
    return setmetatable({
        domain = domain,
        addr = addr,
        _first_domain = domain,
        _first_addr = addr,
    }, {
        __index = AtObj,
        ---@param self AtObj
        ---@param new_addr? int
        __call = function(self, new_addr)
            if new_addr then return self:with(new_addr)
            else return self:reset()
            end
        end,
        ---@param self AtObj
        ---@param value int
        __add = function(self, value) return self:step(value) end,
        ---@param self AtObj
        ---@param value int
        __sub = function(self, value) return self:step(-value) end,
        __tostring = function(obj)
            return string.format("memory 0x%08X (value %02X)", addr, obj:r8())
        end
    })
end
---ROM領域のメモリ操作オブジェクトを取得する。
---@param addr int
---@return AtObj
local function romat(addr) return at(addr, ROM_DOMAIN_NAME) end


print_time_at_fill_in = false
__print_fill_in = false
__print_warr = false
__warr_silent = false

---@return bool
---@package
local function _print_time_at_fill_in()
    return (print_time_at_fill_in or __print_fill_in or __print_warr) and (not __warr_silent)
end

---先頭アドレス`begin`から`inclusiveEnd`までを、1バイト値`value`で埋め尽くす。
---@param begin int
---@param inclusiveEnd int
---@param value? int (デフォルト値は`0`)
---@param domain? string
local function _fill_in(begin, inclusiveEnd, value, domain)
    domain = domain or get_domain(begin)
    value = (value or 0x00) & 0xff
    if begin > inclusiveEnd then
        begin, inclusiveEnd = inclusiveEnd, begin
    end
    if inclusiveEnd - begin > 0xffffff then
        print("Too wide range")
    end
    local t1 = 0
    if _print_time_at_fill_in() then
        t1 = os.clock()
    end
    local value32 = value | (value << 8) | (value << 16) | (value << 24)
    -- local value32 = value + (value * 256) + (value * 65536) + (value * 16777216)
    if inclusiveEnd > begin + 8 then
        for i = begin, inclusiveEnd - 4, 4 do _w32(i, value32, domain) end
        for i = inclusiveEnd - 4, inclusiveEnd do _w8(i, value, domain) end
    else
        for i = begin, inclusiveEnd do _w8(i, value, domain) end
    end
end
fill_in = _fill_in

---ROM領域の先頭アドレス`begin`から`inclusiveEnd`までを、1バイト値`value`で埋め尽くす。
---@param begin int
---@param inclusiveEnd int
---@param value? int (デフォルト値は`0`)
local function _fill_inr(begin, inclusiveEnd, value)
    _fill_in(begin, inclusiveEnd, value, _ROM_DOMAIN_NAME)
end
fill_inr = _fill_inr

---先頭アドレス`begin`から`inclusiveEnd`までを、バイト列`bytes`で(ループさせて)書き込む。
---@param begin int
---@param inclusiveEnd int
---@param bytes int[]
---@param domain string?
local function fill_in_arr(begin, inclusiveEnd, bytes, domain)
    domain = domain or get_domain(begin)
    if begin > inclusiveEnd then
        begin, inclusiveEnd = inclusiveEnd, begin
    end
    if inclusiveEnd - begin > 0xffffff then
        print("Too wide range")
    end
    local n = #bytes
    if n == 0 then print("empty bytes") return
    elseif n <= 8 then
        for i = begin, inclusiveEnd do
            local idx = (i - begin) % n
            _w8(i, bytes[idx + 1], domain)
        end
        if _print_time_at_fill_in() then
            local str_data = {}
            for i = 1, n do str_data[i] = string.format("%02X", bytes[i]) end
            local data = table.concat(str_data, " ")
            print(string.format("Filled range [0x%08X -- 0x%08X] with \"%s\" (time: almost 0 [s])", begin, inclusiveEnd, data))
        end
        return
    end
    local _bytes = {}
    local values = {}
    local lcm
    if (n & 0xff) == 0 then lcm = n
    elseif (n & 0xf) == 0 then lcm = n * 2
    else lcm = n * 4
    end
    for i = 0, n - 1 do _bytes[i] = bytes[i+1] & 0xff end
    for i = 0, lcm - 1 do
        values[i] = (
            _bytes[i % n] |
            (_bytes[(i + 1) % n] << 8) |
            (_bytes[(i + 2) % n] << 16) |
            (_bytes[(i + 3) % n] << 24)
        )
    end
    local t1 = 0
    if _print_time_at_fill_in() then
        t1 = os.clock()
    end

    -- 0始まりなので要素数が1だけ小さくなるのを直す
    local n1 = #_bytes + 1
    local m = #values + 1
    local s1 = begin + 4 - (begin % 4)
    for i = begin, s1 do _w8(i, _bytes[(i - begin) % n1], domain) end
    for i = s1, inclusiveEnd - 4, 4 do _w32(i, values[(i - begin) % m], domain) end
    for i = math.max(begin, inclusiveEnd - 4), inclusiveEnd do _w8(i, _bytes[(i - begin) % n1], domain) end

    if _print_time_at_fill_in() then
        local t2 = os.clock()
        local str_data = {}
        for i = 1, n do str_data[i] = string.format("%02X", _bytes[i-1]) end
        local data = table.concat(str_data, " ")
        print(string.format("Filled range [0x%08X -- 0x%08X] with \"%s\" (time: %.3f [s])", begin, inclusiveEnd, data, t2 - t1))
    end
end

---先頭アドレス`begin`から`inclusiveEnd`までを、バイト列`bytes`で(ループさせて)書き込む。
---@param begin int
---@param inclusiveEnd int
---@param bytes int[]
local function romfill_in_arr(begin, inclusiveEnd, bytes)
    fill_in_arr(begin, inclusiveEnd, bytes, _ROM_DOMAIN_NAME)
end
---先頭アドレス`begin`からバイト列`bytes`を書き込んでいく。
---@param begin int
---@param bytes int[]
---@param domain string?
local function warr(begin, bytes, domain)
    fill_in_arr(begin, begin + #bytes - 1, bytes, domain)
end
---ROM領域の先頭アドレス`begin`からバイト列`bytes`を書き込んでいく。
---@param begin int
---@param bytes int[]
local function romwarr(begin, bytes)
    warr(begin, bytes, _ROM_DOMAIN_NAME)
end
---指定した範囲のバイト列を読み込む。
---@param begin int
---@param inclusiveEnd int
---@param domain string?
---@return int[]
local function rarr(begin, inclusiveEnd, domain)
    if begin > inclusiveEnd then
        begin, inclusiveEnd = inclusiveEnd, begin
    end
    domain = domain or get_domain(begin)
    local out = {}
    local base_begin = begin & 0xfffffffc
    if begin ~= base_begin then
        local next_base = base_begin + 4
        for i = begin, next_base - 1 do
            out[#out+1] = _r8(i, domain)
        end
        begin = next_base
    end
    local last_base = inclusiveEnd & 0xfffffffc
    for i = begin, last_base - 1, 4 do
        local v = _r32(i, domain)
        out[#out+1] = v & 0xff
        out[#out+1] = (v >> 8) & 0xff
        out[#out+1] = (v >> 16) & 0xff
        out[#out+1] = (v >> 24) & 0xff
    end
    for i = last_base, inclusiveEnd do
        out[#out+1] = _r8(i, domain)
    end
    return out
end
---ROM領域の指定した範囲のバイト列を読み込む。
---@param begin int
---@param inclusiveEnd int
---@return int[]
local function romrarr(begin, inclusiveEnd) return rarr(begin, inclusiveEnd, ROM_DOMAIN_NAME) end

local function _print_range(begin, inclusiveEnd)
    local arr = {}
    local idx = 1
    for i = begin, inclusiveEnd do
        arr[idx] = string.format("%02X", _r8(i))
        idx = idx + 1
    end
    print(string.format("MEMORY IN [0x%08X..0x%08X]\r\n", begin, inclusiveEnd) .. table.concat(arr, " "))
end
print_range = _print_range


---@class RangeObj
---@field begin int
---@field inclusiveEnd int
---@field domain string
---@field _cache u32[]
---@field _saved bool
local RangeObj = {}

---現在のメモリデータを保存する。
---@return RangeObj self
function RangeObj:save()
    for i = self.begin, self.inclusiveEnd, 4 do
        self._cache[i] = _r32(i, self.domain)
    end
    self._saved = true
    return self
end
---最後に保存したのメモリデータを復元する。
---@param self RangeObj
function RangeObj:rollback()
    if (not self._saved) then
        self:save()
        print("saveされていませんでした")
        return
    end
    for i = self.begin, self.inclusiveEnd, 4 do
        _w32(i, self._cache[i], self.domain)
    end
end
---saveされたバイト列を丸ごと出力する。
function RangeObj:print()
    local s = ""
    if (not self._saved) then
        print("saveされていません")
        return
    end
    for i = self.begin, self.inclusiveEnd, 4 do
        local v = self._cache[i]
        -- endianをLEからBEに修正
        local _v = 0
        for j = 0, 3 do _v = (_v << 8) | ((v >> (8*j)) & 0xff) end
        s = s .. string.format("%08X", _v)
    end
    print("\n" .. s .. "\n")
end
local _diff_result_count = 0
---最後に`save`したメモリデータと比較し、異なっている箇所を列挙する。
---@param self RangeObj
---@param ignore? int[]
function RangeObj:diff(ignore)
    if (not self._saved) then
        self:save()
        print("saveされていませんでした")
        return
    end
    ---@type table<int, bool>
    local _ignore = nil
    if ignore then
        for i = 1, #ignore do _ignore[ignore[i]] = true end
    end
    local arr = {}
    local arr_tmp = {}
    local c = 0
    local c_tmp = 0
    local last_changed = false
    local same = false
    for i = self.begin, self.inclusiveEnd, 4 do
        if ignore == nil or (not _ignore[i]) then
            same = _r32(i, self.domain) == self._cache[i]
            if (not same) then
                last_changed = true
                c_tmp = c_tmp + 1
                arr_tmp[c_tmp] = i
            end
        end
        if same and last_changed then
            last_changed = false
            c = c + 1
            if #arr_tmp > 1 then
                arr[c] = string.format("0x%08X--0x%08X", arr_tmp[1], arr_tmp[#arr_tmp])
            else
                arr[c] = string.format("0x%08X", arr_tmp[1])
            end
            c_tmp = 0
            arr_tmp = {}
        end
    end
    _diff_result_count = _diff_result_count + 1
    local ss = "\n=========================\n  DIFF ADDRESSES:\n" .. table.concat(arr, "\n") .. "\n=========================\n\n"
    print(ss)
end
---メモリ範囲のステートロード・差分照会などを行うオブジェクトを生成する。
---@param begin int
---@param inclusiveEnd int
---@param domain string?
---@return RangeObj
local function range(begin, inclusiveEnd, domain)
    return setmetatable({
        _cache = {},
        _saved = false,
        begin = begin,
        domain = domain or get_domain(begin),
        inclusiveEnd = inclusiveEnd | 0x3, -- 下位2ビットを必ず11にすれば4ずつincrementしてもincludeEndの範囲をr32でカバーできる
    }, {
        __index = RangeObj,
        __tostring = function(obj)
            return string.format("range [0x%08X, 0x%08X]", begin, inclusiveEnd)
        end
    })
end
---ROM領域内のステートロード・差分照会などを行うオブジェクトを生成する。
---@param begin int
---@param inclusiveEnd int
---@return RangeObj
local function romrange(begin, inclusiveEnd)
    return range(begin, inclusiveEnd, _ROM_DOMAIN_NAME)
end

---与えられた範囲内の値を、関数 `func` に従い変更する。(返り値が`nil`の場合は変更しない)
---@param begin int
---@param inclusiveEnd int
---@param func fun(v: int, i: int): int?
---@param domain string?
local function mfilter8(begin, inclusiveEnd, func, domain)
    domain = domain or get_domain(begin)
    local v
    for i = begin, inclusiveEnd do
        v = func(_r8(i, domain), i)
        if v then _w8(i, v, domain) end
    end
end
---与えられた範囲内の値を、関数 `func` に従い変更する。(返り値が`nil`の場合は変更しない)
---@param begin int
---@param inclusiveEnd int
---@param func fun(v: int, i: int): int?
---@param domain string?
local function mfilter16(begin, inclusiveEnd, func, domain)
    domain = domain or get_domain(begin)
    begin = begin & 0xfffffffe
    inclusiveEnd = inclusiveEnd | 1
    local v
    for i = begin, inclusiveEnd, 2 do
        v = func(_r16(i, domain), i)
        if v then _w16(i, v, domain) end
    end
end
---与えられた範囲内の値を、関数 `func` に従い変更する。(返り値が`nil`の場合は変更しない)
---@param begin int
---@param inclusiveEnd int
---@param func fun(v: int, i: int): int?
---@param domain string?
local function mfilter32(begin, inclusiveEnd, func, domain)
    domain = domain or get_domain(begin)
    begin = begin & 0xfffffffc
    inclusiveEnd = inclusiveEnd | 3
    local v
    for i = begin, inclusiveEnd, 4 do
        v = func(_r32(i, domain), i)
        if v then _w32(i, v, domain) end
    end
end

---与えられた範囲内のバイト `before` をすべて `after` に置換する。
---@param begin int
---@param inclusiveEnd int
---@param before int
---@param after int
---@param domain string?
local function replace8(begin, inclusiveEnd, before, after, domain)
    mfilter8(begin, inclusiveEnd, function(v) return v == before and after or nil end, domain)
end
---**ROM領域の**与えられた範囲内のバイト `before` をすべて `after` に置換する。
---@param begin int
---@param inclusiveEnd int
---@param before int
---@param after int
local function replace8r(begin, inclusiveEnd, before, after)
    replace8(begin, inclusiveEnd, before, after, ROM_DOMAIN_NAME)
end
---与えられた範囲内の値 `before` をすべて `after` に置換する。
---@param begin int
---@param inclusiveEnd int
---@param before int
---@param after int
---@param domain string?
local function replace16(begin, inclusiveEnd, before, after, domain)
    mfilter16(begin, inclusiveEnd, function(v) return v == before and after or nil end, domain)
end
---**ROM領域の**与えられた範囲内の値 `before` をすべて `after` に置換する。
---@param begin int
---@param inclusiveEnd int
---@param before int
---@param after int
local function replace16r(begin, inclusiveEnd, before, after)
    replace16(begin, inclusiveEnd, before, after, ROM_DOMAIN_NAME)
end
---与えられた範囲内の値 `before` をすべて `after` に置換する。
---@param begin int
---@param inclusiveEnd int
---@param before int
---@param after int
---@param domain string?
local function replace32(begin, inclusiveEnd, before, after, domain)
    mfilter32(begin, inclusiveEnd, function(v) return v == before and after or nil end, domain)
end
---**ROM領域の**与えられた範囲内の値 `before` をすべて `after` に置換する。
---@param begin int
---@param inclusiveEnd int
---@param before int
---@param after int
local function replace32r(begin, inclusiveEnd, before, after)
    replace32(begin, inclusiveEnd, before, after, ROM_DOMAIN_NAME)
end

---@param addr int
---@param val int?
---@param domain string
---@return bool
local function _eval_byte(addr, val, domain)
    if val == nil then return true
    elseif val > 0xff then return _r8(addr, domain) ~= (val & 0xff)
    else return _r8(addr, domain) == val
    end
end
---`arr`のバイト列を一つ検索する。
---@param begin int
---@param inclusiveEnd int
---@param arr (int?)[] バイト列
--- - `nil`を指定した場合は、その箇所は任意の値でよいことを意味するものとする。
--- - `0xff`より大きい値を指定した場合は、その値と`0xff`とのbitwise andに相当する値以外の任意値を検索するものとする。
---@param domain string?
---@param silent? bool
---@return bool found 検索バイト列が見つかったか否か
---@return int address 見つかったアドレス
local function find(begin, inclusiveEnd, arr, domain, silent)
    domain = domain or get_domain(begin)
    local n = #arr
    if n == 0 then
        if (not silent) then
            print("[mem.find] arr is empty")
        end
        return false, 0
    end
    local non_nil_st = 0
    for i = 1, n do
        non_nil_st = i
        if arr[i] ~= nil then break
        elseif i == n then
            print("[mem.find] all-nil-query given")
            return false, 0
        end
    end
    local idx = non_nil_st
    local baseAddr
    begin = begin + non_nil_st - 1
    for i = begin, inclusiveEnd do
        if _eval_byte(i, arr[idx], domain) then
            if idx == non_nil_st then baseAddr = i end
            idx = idx + 1
            if idx > n then
                baseAddr = baseAddr - non_nil_st + 1
                if (not silent) then
                    print(string.format("[mem.find] == FOUND from 0x%08X", baseAddr))
                end
                return true, baseAddr
            end
        else
            idx = non_nil_st
        end
    end
    if (not silent) then
        print("[mem.find] not found")
    end
    return false, 0
end
---ROM領域から`arr`のバイト列を一つ検索する。
---@param begin int
---@param inclusiveEnd int
---@param arr (int?)[] バイト列
--- - `nil`を指定した場合は、その箇所は任意の値でよいことを意味するものとする。
--- - `0xff`より大きい値を指定した場合は、その値と`0xff`とのbitwise andに相当する値以外の任意値を検索するものとする。
---@param silent? bool
---@return bool found 検索バイト列が見つかったか否か
---@return int address 見つかったアドレス
local function findr(begin, inclusiveEnd, arr, silent)
    return find(begin, inclusiveEnd, arr, _ROM_DOMAIN_NAME, silent)
end
---`arr`のバイト列をすべて取得する。
---@param begin int
---@param inclusiveEnd int
---@param arr (int?)[]
---@param domain string?
---@param silent? bool
---@return bool found 検索バイト列が見つかったか否か
---@return int[] addresses 見つかったアドレス
local function find_all(begin, inclusiveEnd, arr, domain, silent)
    domain = domain or get_domain(begin)
    local res = {}
    local addr = begin
    local n = #arr
    if n == 0 then
        if (not silent) then
            print("[mem.find] arr is empty")
        end
        return false, {}
    end
    while true do
        local f, newAddr = find(addr, inclusiveEnd, arr, domain, true)
        if (not f) then break end
        res[#res + 1] = newAddr
        addr = newAddr + n
    end
    if (not silent) then
        if #res == 0 then
            print("[mem.find_all] not found")
        else
            local s = table.concat(__util.map(res, function(v) return string.format("    0x%08X", v) end), "\n")
            print(string.format("[mem.find] == FOUND from\n%s", s))
        end
    end
    return #res > 0, res
end
---`arr`のバイト列をすべて取得する。
---@param begin int
---@param inclusiveEnd int
---@param arr (int?)[]
---@param silent? bool
---@return bool found 検索バイト列が見つかったか否か
---@return int[] addresses 見つかったアドレス
local function find_allr(begin, inclusiveEnd, arr, silent)
    return find_all(begin, inclusiveEnd, arr, _ROM_DOMAIN_NAME, silent)
end

__mfilter8 = mfilter8
__mfilter16 = mfilter16
__mfilter32 = mfilter32
__replace8 = replace8
__replace8r = replace8r
__replace16 = replace16
__replace16r = replace16r
__replace32 = replace32
__replace32r = replace32r
__find = find
__findr = findr
__find_all = find_all
__find_allr = find_allr

__mem_lib = {
    get_domain = get_domain,
    r8 = _r8,
    r16 = _r16,
    r32 = _r32,
    w8 = _w8,
    w16 = _w16,
    w32 = _w32,
    add8 = _add8,
    add16 = _add16,
    add32 = _add32,
    romr8 = _rom_r8,
    romr16 = _rom_r16,
    romr32 = _rom_r32,
    romw8 = _rom_w8,
    romw16 = _rom_w16,
    romw32 = _rom_w32,
    print_range = _print_range,
    fill_in = _fill_in,
    fill_in_arr = fill_in_arr,
    romfill_in_arr = romfill_in_arr,
    warr = warr,
    romwarr = romwarr,
    rarr = rarr,
    romrarr = romrarr,
    mfilter8 = mfilter8,
    mfilter16 = mfilter16,
    mfilter32 = mfilter32,
    replace8 = replace8,
    replace8r = replace8r,
    replace16 = replace16,
    replace16r = replace16r,
    replace32 = replace32,
    replace32r = replace32r,
    range = range,
    romrange = romrange,
    find = find,
    findr = findr,
    find_all = find_all,
    find_allr = find_allr,
    at = at,
    romat = romat,
}
return __mem_lib
