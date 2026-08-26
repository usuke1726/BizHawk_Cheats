
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
---現在のマウスの位置を返却する。
---
--- - `x`の範囲: `[0, 255]`
--- - `y`の範囲: `[0, 191]` (下画面), `[-192, -1]` (上画面)
---@return {x: int, y: int}
local function get_mouse_pos()
    local mouse_pos = input.getmouse()
    return {
        x = mouse_pos["X"],
        y = mouse_pos["Y"]//2,
    }
end
---画面をタッチしているなら現在のマウスの位置を返却。そうでないなら`nil`を返却する。
---
--- - `x`の範囲: `[0, 255]`
--- - `y`の範囲: `[0, 191]` (下画面), `[-192, -1]` (上画面)
---@return {x: int, y: int}?
local function mouse()
    local _touch  = joypad.get()["Touch"] --[[@as boolean]]
    return _touch and get_mouse_pos() or nil
end
---指定した座標をタッチする。(引数無しならタッチペンを離す)
---
--- - `x`の範囲: `[0, 255]`
--- - `y`の範囲: `[0, 191]` (下画面), `[-192, -1]` (上画面)
---@param x int
---@param y int
---@overload fun()
local function touch(x, y)
    if x then
        joypad.set({["Touch"] = true})
        joypad.setanalog({["X"] = x, ["Y"] = y*2})
    else
        joypad.set({["Touch"] = false})
    end
end

---@enum ButtonLis_Statuses
local ButtonLis_Statuses = {
    up = 0,
    down = 1,
    holding = 2,
    released = 3,
    waiting_holding = 4,
    waiting_released = 5,
}

---@class ButtonLisObj
---@field key DS_Keys
---@field protected prev bool
---@field protected _status ButtonLis_Statuses
---@field protected up_callback? fun()
---@field protected down_callback? fun()
---@field protected _delay int
---@field protected delay_i int
---@overload fun(): bool | nil
local ButtonLisObj = {}

--- キーを離した瞬間か否か
--- 
--- ※`update`をしてから呼び出すこと。
---@return bool
function ButtonLisObj:keyup()
    return self._status == ButtonLis_Statuses.up
end

--- キーを押しているか否か(押した瞬間は含まれない)
--- 
--- ※`update`をしてから呼び出すこと。
---@return bool
function ButtonLisObj:holding()
    return self._status == ButtonLis_Statuses.holding
end

--- キーを離しているか否か(押した瞬間は含まれない)
--- 
--- ※`update`をしてから呼び出すこと。
---@return bool
function ButtonLisObj:released()
    return self._status == ButtonLis_Statuses.released
end

--- キーを押した瞬間か否か
--- 
--- ※`update`をしてから呼び出すこと。
---@return bool
function ButtonLisObj:keydown()
    return self._status == ButtonLis_Statuses.down
end

---`update`した際に自動で実行する処理を登録する
---@param event "up" | "down"
---@param callback fun()
---@return ButtonLisObj
function ButtonLisObj:on(event, callback)
    if event == "up" then self.up_callback = callback
    else self.down_callback = callback
    end
    return self
end

--- `holding`, `released` 状態に移行するまでの遅延フレーム数を設定する。
---@param delay int
---@return ButtonLisObj
function ButtonLisObj:delay(delay)
    self._delay = delay
    return self
end

---状態を更新する。(`__call`メタメソッドと同等)
---@return boolean|nil `nil`: 変化なし, `true/false`: `down/up`
function ButtonLisObj:update()
    local k = get(self.key)
    local p = self.prev
    self.prev = k
    if p then
        if k then
            if self._status == ButtonLis_Statuses.holding then return nil
            elseif self._status == ButtonLis_Statuses.waiting_holding then
                self.delay_i = self.delay_i + 1
            else
                self.delay_i = 0
                self._status = ButtonLis_Statuses.waiting_holding
            end
            if self.delay_i >= self._delay then
                self._status = ButtonLis_Statuses.holding
            end
        else
            self._status = ButtonLis_Statuses.up
        end
    else
        if k then
            self._status = ButtonLis_Statuses.down
        else
            if self._status == ButtonLis_Statuses.released then return nil
            elseif self._status == ButtonLis_Statuses.waiting_released then
                self.delay_i = self.delay_i + 1
            else
                self.delay_i = 0
                self._status = ButtonLis_Statuses.waiting_released
            end
            if self.delay_i >= self._delay then
                self._status = ButtonLis_Statuses.released
            end
        end
    end
    if self._status == ButtonLis_Statuses.up then
        if self.up_callback then
            self.up_callback()
        end
        return false
    end
    if self._status == ButtonLis_Statuses.down then
        if self.down_callback then
            self.down_callback()
        end
        return true
    end
    return nil
end

--- ボタン入力の状態を管理するオブジェクトを生成する
--- 
--- 使用例1：
--- ```lua
--- local L = ButtonLis("L"):delay(60)
--- function loop()
---     if L() then
---         print("pressed now!")
---     end
---     if L:holding() then
---         print("holding")
---     end
--- end
--- ```
--- 
--- ---
--- 使用例2：
--- 
--- ```lua
--- local L = ButtonLis("L")
--- :on("down", function()
---     -- do something
--- end)
--- function loop() L() end
--- ```
---@param key DS_Keys
---@return ButtonLisObj
local function _ButtonLis(key)
    return setmetatable({
        key = key,
        prev = false,
        _status = ButtonLis_Statuses.released,
        up_callback = nil,
        down_callback = nil,
        _delay = 0,
        delay_i = 0,
    }, {
        __index = ButtonLisObj,
        __call = ButtonLisObj.update,
    })
end
ButtonLis = _ButtonLis

__lib_ds_keys = {
    key = button_keys,
    get = get,
    set = set,
    lis = _ButtonLis,
    get_mouse_pos = get_mouse_pos,
    mouse = mouse,
    touch = touch,
}
return __lib_ds_keys
