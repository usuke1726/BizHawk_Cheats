
---@alias Action fun(obj: ActionObj): fun(obj: ActionObj)?
---@alias ActionUpdateKeyFunc fun(prev_stat: bool?, obj: ActionObj): bool?
---@alias ActionsEntry (Action|Action[])[]

---@param key DS_Keys
---@return ActionUpdateKeyFunc
local function KeyFunc_Button(key)
    return function()
        return __lib_ds_keys.get(key)
    end
end

--- - `x`の範囲: `[0, 255]`
--- - `y`の範囲: `[0, 191]` (下画面), `[-192, -1]` (上画面)
---@param xmin? int
---@param xmax? int
---@param ymin? int
---@param ymax? int
---@return ActionUpdateKeyFunc
local function KeyFunc_Touch(xmin, xmax, ymin, ymax)
    xmin = xmin or 0
    xmax = xmax or 255
    ymin = ymin or -192
    ymax = ymax or 191
    if xmin > xmax then xmin, xmax = xmax, xmin end
    if ymin > ymax then ymin, ymax = ymax, ymin end
    return function()
        if not joypad.get()["Touch"] then return end
        local pos = input.getmouse()
        local x, y = pos["X"], pos["Y"]//2
        if x < xmin then return end
        if x > xmax then return end
        if y < ymin then return end
        if y > ymax then return end
        return true
    end
end

local key_func_lib = {
    button = KeyFunc_Button,
    touch = KeyFunc_Touch,
}

---@class ActionObj
---@field substate int
---@field cooltime int `tmp_func`の実行を一旦停止させるためのクールタイム
---@field timeout? int `cooltime`のエイリアス
---@field name string
---@field key_enable bool `register`で指定したキー関数によるaction移行を有効にする(デフォルトは`true`)
---@field key_interval int `register`で指定したキー関数で移行した後、次の入力を有効にするまでのクールタイム
---@field loop bool 最後のactionが終了した際に最初のactionに戻るか否か(デフォルトは`false`)
---@field skip bool 速攻で次のactionに移行するフラグ
---@field state_updating bool state更新timeoutが設定されているか否か
---@field protected _active bool
---@field protected _pressed_timeout int
---@field protected _end bool
---@field protected _obj_name string
---@field protected _actions Action[]
---@field protected _state int
---@field protected _interval_callbacks IntervalTimerObj[]
---@field protected _len int
---@field protected _key_func ActionUpdateKeyFunc
---@field protected _prev_key_func_stat bool?
---@field protected _state_updated bool
---@field protected _tmp_func fun(obj: ActionObj)?
---@field protected _on_state_changed fun(state: int)?
local ActionObj = {}
---@type table<int, ActionObj>
local actions_objects = {}
local actions_objects_cnt = 0

---@class IntervalTimerObj
---@field isActive bool
---@field callback? fun(obj: IntervalTimerObj)
---@field timeout int
local IntervalTimerObj = {}
---@alias IntervalCallback fun(obj: IntervalTimerObj)

---@package
function IntervalTimerObj:_update()
    if (not self.isActive) then return end
    if self._time > 0 then self._time = self._time - 1
    else
        local callback = self.callback
        if callback then callback(self) end
        self._time = self.timeout
    end
end

---@package
function ActionObj:_update()
    if (not self._active) or self._end then return end
    if self._pressed_timeout > 0 then
        self._pressed_timeout = self._pressed_timeout - 1
    end
    if self.key_enable then
        local stat = self._key_func(self._prev_key_func_stat, self)
        if stat ~= self._prev_key_func_stat then
            self._prev_key_func_stat = stat
            if stat and self._pressed_timeout == 0 then
                self._pressed_timeout = self.key_interval
                self:update_state()
            end
        end
    else
        self._prev_key_func_stat = nil
    end
    if self.timeout ~= nil then
        self.cooltime = self.timeout
        self.timeout = nil
    end
    if self.cooltime > 0 then
        self.cooltime = self.cooltime - 1
        return
    end
    if self.skip and (not self._state_updated) then self:update_state() end
    if self._state_updated then
        self._state_updated = false
        if self._state > self._len then
            if self.loop then self._state = 1
            else
                self._end = true
                print(string.format("[A %s] END", self._obj_name))
                return
            end
        end
        if self._on_state_changed then
            self._on_state_changed(self._state)
        end
        local a = self._actions[self._state]
        if a then self._tmp_func = a(self) end
    else
        if self._tmp_func then self._tmp_func(self) end
        for key, value in pairs(self._interval_callbacks) do
            value:_update()
        end
    end
end
---@package
function ActionObj:_setup()
    local a = self._actions[1]
    if a then self._tmp_func = a(self) end
end
---次のactionに移行する。なお、無条件に速攻で移行させたい場合は、このメソッドではなく`skip`フィールドを使用すると記述が簡潔で良い。
---@param delay? int 非正または`nil`の場合は即時更新
function ActionObj:update_state(delay)
    if delay and delay > 0 then
        if not self.state_updating then
            self.state_updating = true
            self:setTimeout(delay, function()
                self:update_state()
            end)
        end
        return
    end
    self._state = self._state + 1
    print(string.format("[A %s] state %d", self._obj_name, self._state))
    self.substate = 0
    self._tmp_func = nil
    self._state_updated = true
    self.state_updating = false
    self.key_enable = true
    self.skip = false
    self._interval_callbacks = {}
end
---自動で次のアクションに進む処理を行う。
---@param cooltime int
function ActionObj:SKP(cooltime)
    self.key_enable = false
    self.skip = true
    self.cooltime = cooltime
end
---キー入力、`tmp_func`の実行諸々を停止する。
function ActionObj:stop()
    self._active = false
end
---キー入力、`tmp_func`の実行諸々を再開する。
function ActionObj:start()
    self._active = true
end
---最初のactionからやり直す。
function ActionObj:restart()
    _key = 1
    self._active = true
    self._end = false
end
---@package
---@param timeout int
---@param firstTimeout int
---@param callback IntervalCallback
function ActionObj:_setInterval(timeout, firstTimeout, callback)
    self._interval_callbacks[#(self._interval_callbacks) + 1] = setmetatable({
        timeout = timeout,
        callback = callback,
        isActive = true,
        _time = firstTimeout,
    }, {
        __index = IntervalTimerObj,
    })
end
---@param timeout int
---@param firstTimeoutOrCallback integer
---@param callback IntervalCallback
---@overload fun(timeout: int, firstTimeoutOrCallback: IntervalCallback)
function ActionObj:setInterval(timeout, firstTimeoutOrCallback, callback)
    if callback then self:_setInterval(timeout, firstTimeoutOrCallback, callback)
    else self:_setInterval(timeout, timeout, firstTimeoutOrCallback --[[@as IntervalCallback]])
    end
end
---@param timeout int
---@param callback IntervalCallback
function ActionObj:setTimeout(timeout, callback)
    self:_setInterval(10000, timeout, function(obj)
        obj.isActive = false
        if callback then callback(obj) end
    end)
end
---@param callback fun(state: int)
function ActionObj:onStateChanged(callback)
    self._on_state_changed = callback
end

---@param actions ActionsEntry
---@return Action[]
local function flat_actions(actions)
    local ret = {}
    local idx = 1
    for _, value in pairs(actions) do
        local t = type(value)
        if t == "function" then
            ret[idx] = value
            idx = idx + 1
        elseif t == "table" then
            for _, v2 in pairs(value) do
                ret[idx] = v2
                idx = idx + 1
            end
        end
    end
    return ret
end

local actions_count = 0
---@param name string
---@param key_func ActionUpdateKeyFunc
---@param actions ActionsEntry
---@return ActionObj
local function register(name, key_func, actions)
    local _actions = flat_actions(actions)
    actions_count = actions_count + 1
    local obj = setmetatable({
        substate = 0,
        cooltime = 0,
        timeout = nil, -- cooltimeのalias
        name = "",
        key_enable = true,
        key_interval = 30,
        loop = false,
        skip = false,
        _pressed_timeout = 0,
        _active = true,
        _key_func = key_func,
        _prev_key_func_stat = nil,
        _end = false,
        _obj_name = name,
        _actions = _actions,
        _state = 1,
        _interval_callbacks = {},
        _len = #_actions,
        _state_updated = false,
        _state_updating_reserved = false,
        _tmp_func = nil,
        _on_state_changed = nil,
    }, {
        __index = ActionObj,
    })
    actions_objects_cnt = actions_objects_cnt + 1
    actions_objects[actions_objects_cnt] = obj
    obj:_setup()
    return obj
end

local function remove_all_actionObjs()
    actions_objects = {}
end

local function update_all_actionObjs_main()
    for _, obj in pairs(actions_objects) do
        obj:_update()
    end
end
local function update_all_actionObjs()
    success, mes = pcall(update_all_actionObjs_main)
    if not success then
        print(mes)
        remove_all_actionObjs()
    end
end

return {
    ---Key Func
    KF = key_func_lib,
    register = register,
    remove_all = remove_all_actionObjs,
    __update = update_all_actionObjs,
}
