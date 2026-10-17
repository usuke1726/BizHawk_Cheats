
local output_path_env = "BizHawk_UOutputPath"

local output_path_cache = nil

---`_out`フォルダ上のファイルのパスを取得する
---@param filename string
---@return string
local function output(filename)
    output_path_cache = output_path_cache or os.getenv(output_path_env)
    if output_path_cache == nil then
        error("FAILED TO GET OutputPath Env")
    end
    return output_path_cache .. "/" .. filename
end

---@class Writer
---@field write fun(self: Writer, s: string)
---@field wl fun(self: Writer, s: string)
---@field close fun(self: Writer)
---@field flush fun(self: Writer)

---何も出力しないWriterを用意する。
---@return Writer
local function dummy_writer()
    return {
        write = function(self, s) end,
        wl = function(self, s) end,
        close = function(self) end,
        flush = function(self) end,
    }
end

--- ファイル出力か標準出力を容易に切り替えられるファイルオブジェクトのラッパーを生成する。
--- 
--- 例:
--- ```lua
--- local use_file = true -- or false
--- local file = lib.path.w(use_file and "output.txt")
--- -- 以後、画一的に file:write("...") -> file:close() と実行できる。
--- ```
---@param filename? string | boolean | Writer `string`型なら`io.open`、`true/false/nil`なら標準出力、`0`ならダミー
---@return Writer
---@overload fun(filename: 0): Writer
local function writer(filename)
    local t = type(filename)
    if t == "string" then
        local f = assert(io.open(output(filename), "w"), "ファイル " .. filename .. "のオープンに失敗しました")
        return {
            write = function(self, s) f:write(s) end,
            wl = function(self, s) f:write(s .. "\n") end,
            close = function(self) f:close() end,
            flush = function(self) f:flush() end,
        }
    elseif t == "boolean" or filename == nil then
        return {
            write = function(self, s) console.write(s) end,
            wl = function(self, s) print(s) end,
            close = function(self) end,
            flush = function(self) end,
        }
    elseif t == "number" then return dummy_writer()
    else return filename
    end
end

__path_lib = {
    output = output,
    w = writer,
    dummy = dummy_writer,
}

return __path_lib
