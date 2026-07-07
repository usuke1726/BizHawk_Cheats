
---@alias Callback fun(obj: TimerObj)

---@class CounterObjBase
---@field i int
---@field n int
---@field fired bool
---@field active bool
---@field callback fun(i: int)?
---@field next fun(self: CounterObjBase): int, bool
---@field N fun(self: CounterObjBase, n: int): CounterObjBase
---@overload fun(): bool

---@class CounterObj : CounterObjBase
---@field i int
---@field n int
---@field fired bool
---@field active bool
---@overload fun(): bool
local CounterObj = {}

---@class CounterDoubleObj : CounterObj
---@field i int
---@field i0 int
---@field n int
---@field n0 int
---@field fired bool
---@field active bool
---@overload fun(): bool
local CounterDoubleObj = {}

---@class CounterOnceObj : CounterObjBase
---@field i int
---@field n int
---@field fired bool
---@field active bool
---@field protected _fired_once bool
---@overload fun(): bool
local CounterOnceObj = {}

---@class TimerRelayObj : CounterObjBase
---@field i int
---@field n int
---@field fired bool
---@field active bool
---@field protected _fired_once bool
---@overload fun(): bool
local TimerRelayObj = {}

---@class RndCounterObj : CounterObjBase
---@field i int
---@field n int
---@field fired bool
---@field active bool
---@overload fun(): bool
local RndCounterObj = {}

---@return bool fired
function CounterObj:call()
    if (not self.active) then return false end
    local i, fired = self:next()
    if fired and self.callback then
        self.callback(i)
    end
    return fired
end
---@return int i, bool fired
function CounterObj:next()
    self.i = (self.i + 1) % self.n
    self.fired = self.i == 0
    return self.i, self.fired
end
---@param n int
---@return CounterObj self
function CounterObj:N(n)
    self.n = math.max(n, 1)
    self.i = 0
    return self
end
---@return bool fired
function CounterDoubleObj:call()
    if (not self.active) then return false end
    local i, fired = self:next()
    if fired and self.callback then
        self.callback(i)
    end
    return fired
end
---@return int i, bool fired
function CounterDoubleObj:next()
    self.i0 = (self.i0 + 1) % self.n0
    if self.i0 == 0 then
        self.i = (self.i + 1) % self.n
    end
    self.fired = (self.i == 0) and (self.i0 == 0)
    return self.i, self.fired
end
---@param n int
---@return CounterDoubleObj self
function CounterDoubleObj:N(n)
    self.n = math.max(n, 1)
    self.i = 0
    return self
end

---@return bool fired
function CounterOnceObj:call()
    self.fired = false
    if (not self.active) or self._fired_once then return false end
    local i, fired = self:next()
    if fired then
        self._fired_once = true
        self.active = false
        if self.callback then
            self.callback(i)
        end
    end
    return fired
end
---@return int i, bool fired
function CounterOnceObj:next()
    self.i = (self.i + 1) % self.n
    self.fired = self.i == 0
    return self.i, self.fired
end
---@param n int
---@return CounterOnceObj self
function CounterOnceObj:N(n)
    self.n = math.max(n, 1)
    self.i = 0
    return self
end
---@param n? int
function CounterOnceObj:restart(n)
    if n then self:N(n) end
    self.i = 0
    self._fired_once = false
    self.active = true
end

---@return bool fired
function TimerRelayObj:call()
    if (not self.active) or self._fired_once then return self.fired end
    local i, fired = self:next()
    if fired then
        self._fired_once = true
        self.active = false
        if self.callback then
            self.callback(i)
        end
    end
    return fired
end
---@return int i, bool fired
function TimerRelayObj:next()
    self.i = (self.i + 1) % self.n
    self.fired = self.i == 0
    return self.i, self.fired
end
---@param n int
---@return TimerRelayObj self
function TimerRelayObj:N(n)
    self.n = math.max(n, 1)
    self.i = 0
    return self
end
---@param n? int
function TimerRelayObj:restart(n)
    if n then self:N(n) end
    self.i = 0
    self._fired_once = false
    self.active = true
end

---@return bool fired
function RndCounterObj:call()
    if (not self.active) then return false end
    local i, fired = self:next()
    if fired and self.callback then
        self.callback(i)
    end
    return fired
end
---@return int i, bool fired
function RndCounterObj:next()
    self.i = rand(1, self.n)
    self.fired = self.i == 1
    return self.i, self.fired
end
---@param n int
---@return RndCounterObj self
function RndCounterObj:N(n)
    self.n = math.max(n, 1)
    return self
end

---0から`n-1`までの`n`個の整数を順番にループし、0に戻ったタイミングで発火するカウンタを作成
---@param n int
---@param callback? fun()
---@return CounterObj
local function _Cnt(n, callback)
    if n <= 0 then error(string.format("n must be positive (given %d)", n)) end
    return setmetatable({
        i = 0,
        n = n,
        fired = false,
        active = true,
        callback = callback,
    }, {
        __index = CounterObj,
        ---@param self CounterObj
        __call = function(self) return self:call() end
    })
end

---`n0`カウントおきに0から`n-1`までの`n`個の整数を順番にループし、0に戻ったタイミングで発火するカウンタを作成
---@param n int
---@param n0 int
---@param callback? fun()
---@return CounterDoubleObj
local function _CntDouble(n0, n, callback)
    if n <= 0 then error(string.format("n must be positive (given %d)", n)) end
    if n0 <= 0 then error(string.format("n0 must be positive (given %d)", n0)) end
    return setmetatable({
        i = 0,
        i0 = 0,
        n = n,
        n0 = n0,
        fired = false,
        active = true,
        callback = callback,
    }, {
        __index = CounterDoubleObj,
        ---@param self CounterDoubleObj
        __call = function(self) return self:call() end
    })
end

---@param n int
---@param n0 int
---@param callback? fun()
---@overload fun(n: int, callback?: fun()): CounterObj
---@return CounterDoubleObj
---0から`n-1`までの`n`個の整数を順番にループし、0に戻ったタイミングで発火するカウンタを作成する。
---
---ただし、引数先頭に数値を2つ指定した場合、1つ目を引数`n0`とし、\
---`n0`カウントおきに上記のループを行うカウンタを生成する。
local function _CntMain(n0, n, callback)
    if n and type(n) == "number" then return _CntDouble(n0, n, callback)
    elseif n == nil or type(n) == "function" then return _Cnt(n0, n)
    else error("[Cnt] Invalid arguments")
    end
end

---`n`カウント後に1度きりだけ発火するカウンタを作成する。
---@param n int
---@param callback? fun()
---@return CounterOnceObj
local function _CntOnce(n, callback)
    if n <= 0 then error(string.format("n must be positive (given %d)", n)) end
    return setmetatable({
        i = 0,
        n = n,
        fired = false,
        active = true,
        _fired_once = false,
        callback = callback,
    }, {
        __index = CounterOnceObj,
        ---@param self CounterOnceObj
        __call = function(self) return self:call() end
    })
end

---`n`カウント後に発火し、以降ずっと発火し続けるリレーカウンタを作成する。
---@param n int
---@param callback? fun()
---@return TimerRelayObj
local function _RL(n, callback)
    if n <= 0 then error(string.format("n must be positive (given %d)", n)) end
    return setmetatable({
        i = 0,
        n = n,
        fired = false,
        active = true,
        _fired_once = false,
        callback = callback,
    }, {
        __index = TimerRelayObj,
        ---@param self TimerRelayObj
        __call = function(self) return self:call() end
    })
end

---1から`n`の整数をランダムにとり、1になったら発火するカウンタを作成
---@param n int
---@param callback? fun()
---@return RndCounterObj
local function _RC(n, callback)
    if n <= 0 then error(string.format("n must be positive (given %d)", n)) end
    return setmetatable({
        i = 0,
        n = n,
        fired = false,
        active = true,
        callback = callback,
    }, {
        __index = RndCounterObj,
        ---@param self RndCounterObj
        __call = function(self) return self:call() end
    })
end
Cnt = _CntMain
CntOnce = _CntOnce
RL = _RL
RC = _RC

---@class TimerObj
---@field isActive bool
---@field callback Callback
---@field timeout int
local TimerObj = {}
---@type table<int, TimerObj>
local timers = {}
local timer_id = 0

function TimerObj:_update()
    if (not self.isActive) then return end
    if self._time > 0 then self._time = self._time - 1
    else
        local callback = self.callback
        if callback then callback(self) end
        self._time = self.timeout
    end
end
local function update()
    for k, timer in pairs(timers) do
        timer:_update()
    end
end
local function clearAllTimers()
    timers = {}
end
local function clearTimeout(id)
    timers[id] = nil
end
local function clearInterval(id)
    timers[id] = nil
end
---@param timeout int
---@param firstTimeout int
---@param callback Callback
---@return integer
local function _setInterval(timeout, firstTimeout, callback)
    timer_id = timer_id + 1
    timers[timer_id] = setmetatable({
        timeout = timeout,
        callback = callback,
        isActive = true,
        _time = firstTimeout,
    }, {
        __index = TimerObj,
    })
    return timer_id
end
---@param time int
---@param callback Callback
---@return integer
local function setTimeout(time, callback)
    local new_id = timer_id + 1
    return _setInterval(10000, time, function(obj)
        clearTimeout(new_id)
        if callback then callback(obj) end
    end)
end
---@param timeout int
---@param firstTimeoutOrCallback int
---@param callback Callback
---@return int
---@overload fun(timeout: int, firstTimeoutOrCallback: Callback): int
local function setInterval(timeout, firstTimeoutOrCallback, callback)
    if callback then return _setInterval(timeout, firstTimeoutOrCallback, callback)
    else return _setInterval(timeout, timeout, firstTimeoutOrCallback --[[@as Callback]])
    end
end


---@alias TimerActionsAction fun(counter: CounterObjBase): bool?
---@alias TimerActionsValues { counter: CounterObjBase, action: TimerActionsAction }

---@class TimerActionsObj
---@field active bool
---@field protected _actions TimerActionsValues[]
---@overload fun()
local TimerActionsObj = {}

function TimerActionsObj:update()
    if not self.active then return end
    for _, v in pairs(self._actions) do
        if v.counter() then
            local f = v.action(v.counter)
        end
    end
end

---@param counter CounterObjBase
---@param action TimerActionsAction
---@return TimerActionsObj self
function TimerActionsObj:set(counter, action)
    self._actions[#self._actions+1] = {
        counter = counter,
        action = action,
    }
    return self
end

---発火時間と実行アクションをまとめて管理するオブジェクトを生成する。
---@return TimerActionsObj
local function timerActions()
    return setmetatable({
        active = true,
        _i = 0,
        _actions = {},
    }, {
        __index = TimerActionsObj,
        ---@param self TimerActionsObj
        __call = function(self)
            self:update()
        end,
    })
end

__timer = {
    setTimeout = setTimeout,
    setInterval = setInterval,
    clearTimeout = clearTimeout,
    clearInterval = clearInterval,
    clearAllTimers = clearAllTimers,
    Cnt = _CntMain,
    CntOnce = _CntOnce,
    RL = _RL,
    RC = _RC,
    actions = timerActions,
    __update = update,
}
return __timer
