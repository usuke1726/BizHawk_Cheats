
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

__path_lib = {
    output = output,
}

return __path_lib
