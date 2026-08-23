

local function B_offset(from, to)
    from = from & 0xfffffffc
    to = to & 0xfffffffc
    local d = (to - 8 - from) // 4
    if d < 0 then
        d = 0x1000000 + d
    end
    assert(within(d, 0, 0xffffff), string.format("d: %d", d))
    return d
end

---アドレス `from` から アドレス `to` へジャンプする B命令のLittle Endian値を生成する
---
---B命令は https://github.com/akatsuki105/gba-docs-ja/blob/main/arm7tdmi/arm/branch.md を参考.
---@param from int
---@param to int
---@return int
local function make_B(from, to)
    return 0xEA000000 | B_offset(from, to)
end

---アドレス `from` から アドレス `to` へジャンプする B命令のLittle Endian値を生成する
---
---B命令は https://github.com/akatsuki105/gba-docs-ja/blob/main/arm7tdmi/arm/branch.md を参考.
---@param from int
---@param to int
---@return int
local function make_BL(from, to)
    return 0xEB000000 | B_offset(from, to)
end

---アドレス `from` に アドレス `to` へジャンプする B命令を書き込む。
---
---書き込みたくない場合は `make_B` を使えばよい。
---@param from int
---@param to int
---@param domain? string
---@return int prev_value
local function jump(from, to, domain)
    local prev = r32(from, domain)
    w32(from, make_B(from, to), domain)
    return prev
end

---アドレス `from` に アドレス `to` へジャンプする BL命令を書き込む。
---
---書き込みたくない場合は `make_BL` を使えばよい。
---@param from int
---@param to int
---@param domain? string
---@return int prev_value
local function BL(from, to, domain)
    local prev = r32(from, domain)
    w32(from, make_BL(from, to), domain)
    return prev
end

---アドレス `addr` (補正付き)にあるB/BL命令のジャンプ先アドレスを計算する。
---@param addr int
---@param domain? string
---@return int
local function BLtarget(addr, domain)
    addr = addr & 0xfffffffc
    local v = r32(addr, domain)
    assert(within(v >> 24, 0xEA, 0xEB), string.format("B/BL命令ではありません: %08X", v))
    local d = v & 0xffffff
    if d > 0x800000 then d = d - 0x1000000 end
    return addr + 8 + d * 4
end

local _asm = {
    make_B = make_B,
    make_BL = make_BL,
    jump = jump,
    BL = BL,
    BLtarget = BLtarget,
}
asm = _asm

return _asm
