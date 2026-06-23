
---@enum DS_Keys
local button_keys = {
    A = "A",
    B = "B",
    X = "X",
    Y = "Y",
    L = "L",
    R = "R",
    Up = "Up",
    Down = "Down",
    Left = "Left",
    Right = "Right",
    Start = "Start",
    Select = "Select",
}
DS_KEYS = button_keys
-- 以下は実装を保留
-- GBA Light Sensor
-- LidClose
-- LidOpen
-- Mic Volume
-- Microphone
-- Power
-- Touch
-- Touch X
-- Touch Y

---@param key DS_Keys
---@return bool
local function get(key)
    return joypad.get()[key] --[[@as boolean]]
end
---指定したキーの情報**のみ**の設定を上書きする。(他のキーの入力状態は変更しない)
---@param key DS_Keys
---@param on bool | int `int`値は非ゼロが`true`扱い
---@overload fun(info: table<DS_Keys, bool | int>)
local function set(key, on)
    if type(key) == "table" then
        local v = {}
        for k, f in pairs(key) do
            v[k] = type(f) == "boolean" and f or f ~= 0
        end
        joypad.set(v)
    else
        joypad.set({ [key] = type(on) == "boolean" and on or on ~= 0 })
    end
end

__lib_ds_keys = {
    key = button_keys,
    get = get,
    set = set,
}
return __lib_ds_keys
