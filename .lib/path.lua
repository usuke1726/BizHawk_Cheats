
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

--- ファイル出力か標準出力を容易に切り替えられるファイルオブジェクトのラッパーを生成する。
--- 
--- 例:
--- ```lua
--- local use_file = true -- or false
--- local file = lib.path.w(use_file and "output.txt")
--- -- 以後、画一的に file:write("...") -> file:close() と実行できる。
--- ```
---@param filename? string | boolean `string`型なら`io.open`、`true/false/nil`なら標準出力
---@return Writer
local function writer(filename)
    if type(filename) == "string" then
        local f = assert(io.open(output(filename), "w"), "ファイル " .. filename .. "のオープンに失敗しました")
        return {
            write = function(self, s) f:write(s) end,
            wl = function(self, s) f:write(s .. "\n") end,
            close = function(self) f:close() end,
            flush = function(self) f:flush() end,
        }
    else
        return {
            write = function(self, s) io.stdout:write(s) end,
            wl = function(self, s) print(s) end,
            close = function(self) end,
            flush = function(self) end,
        }
    end
end

__path_lib = {
    output = output,
    w = writer,
}

return __path_lib
