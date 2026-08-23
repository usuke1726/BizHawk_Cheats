

local sjis = require "misc/sjis"

---@param use_file bool
---@param filename string
---@return {write: fun(self, s: string), close: fun(self)}
local function get_file(use_file, filename)
    if use_file then
        return assert(io.open(lib.path.output(filename), "w"), "ファイル "..filename.." のオープンに失敗しました")
    else
        return {
            ---@param s string
            write = function(self, s) print(s) end,
            close = function(self) end,
        }
    end
end

---@param use_file bool
---@return fun(t: string): string
local function format(use_file)
    if use_file then
        return function(s)
            s = string.gsub(s, "\\n＋＋$", "")
            s = string.gsub(s, "\\n", "\n")
            return s .. "\n"
        end
    else
        return function(s)
            return s
        end
    end
end

---(デフォルトでRAM領域の)sjis領域のテキストを取得する
---@param output "file" | "stdout"
---@param addr int
---@param options? {is_rom?: bool, bound?: int, end_addr?: int, filename?: string}
local function dump_text(output, addr, options)
    options = options or {}
    local use_file = output == "file"
    local is_rom = options.is_rom == true
    local end_addr = options.end_addr or (addr + (options.bound or 0x800))
    local filename = options.filename or "mushi_text.txt"
    local _format = format(use_file)
    local _r32 = is_rom and r32r or r32
    sjis.options.dbl_space_str = use_file and "　" or "<SP>"
    sjis.options.half_space_str = use_file and " " or "<sp>"
    sjis.options.silent = true
    sjis.options.is_char = function(code) return code ~= 0 end
    sjis.options.special_reader = function(_addr)
        if _addr & 0x3 ~= 0 then return end
        local v = _r32(_addr)
        if (v >> 24) == 0x02 then
            return {
                t = "\\0",
                len = 4,
                valid = true,
                is_char = false,
            }
        end
    end

    local iter = sjis.iter(addr, not is_rom)
    if not use_file then CLS() end
    local i = 0
    local buf = ""
    local file = get_file(use_file, filename)
    while true do
        for c in iter:it() do
            if c ~= "\\0" then
                buf = buf .. c
            end
        end
        if buf == "フェーズNOが不正です" then
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
end

return {
    dump_text = dump_text,
}
