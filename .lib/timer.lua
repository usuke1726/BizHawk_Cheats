
---@alias Callback fun(obj: TimerObj)
---@alias VUO_xfun fun(obj: ValueUpdaterObj): number
---@alias VUO_calc fun(obj: ValueUpdaterObj): int?
---@alias VUO_calcEntry VUO_calc | "lerp" | "isin" | "icos" | "sq" | "sqrt" | "pingpong" | "rpingpong"

---@type table<string, VUO_calc>
local VUOCalcEntryFunctions = {
    ["lerp"] = function(obj)
        return obj:lerp()
    end,
    ["isin"] = function(obj)
        return obj:isin()
    end,
    ["icos"] = function(obj)
        return obj:icos()
    end,
    ["sq"] = function(obj)
        return obj:lerp(obj:sq())
    end,
    ["sqrt"] = function(obj)
        return obj:lerp(obj:sqrt())
    end,
}
---@type table<string, fun(_obj: ValueUpdaterObj): VUO_calc>
local VUOCalcEntryFunctions_withSetup = {
    ["pingpong"] = function(_obj)
        _obj:x_pingpong()
        return function(obj)
            return obj:lerp()
        end
    end,
    ["rpingpong"] = function(_obj)
        _obj:x_reversePingpong()
        return function(obj)
            return obj:lerp()
        end
    end,
}
---@param entry string
---@param obj ValueUpdaterObj
---@return VUO_calc?
local function resolve_string_entry(entry, obj)
    local f = VUOCalcEntryFunctions[entry]
    if f then return f end
    local f2 = VUOCalcEntryFunctions_withSetup[entry]
    if f2 then return f2(obj) end
    return nil
end

---@class VUO
---@field add fun(d: int): VUO_calc 現在の値に`d`だけ加算する関数を返却する
---@field addrand fun(min: int, max: int): VUO_calc 現在の値に`rand(min, max)`だけ加算する関数を返却する
---
---calc関数を生成するユーティリティ
VUO = {
    add = function(d)
        return function(obj)
            return obj.v + d
        end
    end,
    addrand = function(min, max)
        return function(obj)
            return obj.v + rand(min, max)
        end
    end,
}

local OF_Behavior_loop <const> = 0
local OF_Behavior_clamp <const> = 1

---@class ValueUpdaterObj
---@field i int
---@field n int
---@field v int
---@field active bool
---@field protected min int?
---@field protected max int?
---@field protected _dmin int ダミーの`min`
---@field protected _dmax int ダミーの`max`
---@field protected _overflow_behavior 0 | 1
---@field protected _v int
---@field protected _x_func VUO_xfun
---@field protected _calc VUO_calc
---@field protected _write fun(v: int, status: int?)
---@overload fun(): int?
local ValueUpdaterObj = {}

---@param use_nil? bool
---@return int
---@return int?
---@overload fun(self: ValueUpdaterObj, use_nil: true): int?, int?
function ValueUpdaterObj:next(use_nil)
    if self._v == nil then self._v = 0 end
    local def = (not use_nil) and self._v or nil
    if not self.active then return def, nil end
    assert(self._calc, "calc プロパティが指定されていません")
    self.i = (self.i + 1) % self.n
    local v = self._calc(self)
    if not v then return def, nil end
    local status = nil
    local min, max = self.min, self.max
    if min and v < min then status = -1
    elseif max and v > max then status = 1
    end
    if self._overflow_behavior == OF_Behavior_clamp then
        v = math.clamp(v, min, max)
    elseif min and max then
        v = math.mod(v, min, max)
    end
    self._v = v
    self.v = v
    return v, status
end
---@return int?
function ValueUpdaterObj:update()
    local v, status = self:next(true)
    if v and self._write then
        self._write(v, status)
    end
    return status
end
---@param behavior "loop" | "clamp"
---@return ValueUpdaterObj
function ValueUpdaterObj:overflow_behavior(behavior)
    self._overflow_behavior = behavior == "loop" and OF_Behavior_loop or OF_Behavior_clamp
    return self
end
---指定した値を `v` に格納する。
---@param v int
---@return ValueUpdaterObj
function ValueUpdaterObj:init(v)
    self._v = v
    self.v = v
    return self
end
---@return bool
function ValueUpdaterObj:v_not_ready()
    return self._v == nil
end
---@param calc VUO_calcEntry
---@return ValueUpdaterObj
function ValueUpdaterObj:calc(calc)
    if type(calc) == "string" then
        self._calc = assert(resolve_string_entry(calc, self), "invalid calc id: " .. calc)
    else
        self._calc = calc
    end
    return self
end
---@param write fun(v: int, status: int?)
---@return ValueUpdaterObj
function ValueUpdaterObj:write(write)
    self._write = write
    return self
end
--- `write`処理として`w8`を設定する
---@param addr int
---@return ValueUpdaterObj
function ValueUpdaterObj:w8(addr)
    return self:write(function(v) w8(addr, v) end)
end
--- `write`処理として`w16`を設定する
---@param addr int
---@return ValueUpdaterObj
function ValueUpdaterObj:w16(addr)
    return self:write(function(v) w16(addr, v) end)
end
--- `write`処理として`w32`を設定する
---@param addr int
---@return ValueUpdaterObj
function ValueUpdaterObj:w32(addr)
    return self:write(function(v) w32(addr, v) end)
end

---@param min int?
---@param max int?
---@return integer
---@return integer
local function _dummy_minmax(min, max)
    if min and max then return min, max
    elseif min then return min, min + 100
    elseif max then return max - 100, max
    else return 0, 100
    end
end
---@param min (int | "nil")?
---@param max (int | "nil")?
---@return ValueUpdaterObj
function ValueUpdaterObj:minmax(min, max)
    if min then
        self.min = type(min) == "number" and min or nil
    end
    if max then
        self.max = type(max) == "number" and max or nil
    end
    if self.min and self.max then
        assert(self.min < self.max, string.format("it must be max > min (min: %d, max: %d)", self.min, self.max))
    end
    self._dmin, self._dmax = _dummy_minmax(self.min, self.max)
    return self
end
---@return integer? min
---@return integer? max
function ValueUpdaterObj:get_minmax()
    return self.min, self.max
end

---@return number
function ValueUpdaterObj:x()
    return self._x_func(self)
end
---@package
---@return number
function ValueUpdaterObj:x_orig()
    return self.i / self.n
end
---@param x_func VUO_xfun
---@return ValueUpdaterObj
function ValueUpdaterObj:x_with(x_func)
    self._x_func = assert(x_func, "nil ValueUpdaterObj.x_func given")
    return self
end
---`x`の向きを逆(0→1ではなく1→0)にする。
---@return ValueUpdaterObj
function ValueUpdaterObj:x_reverse()
    return self:x_with(function(obj)
        return (obj.n - 1 - obj.i) / obj.n
    end)
end
---`x`を0→1→0という風に線形で折り返す。
---@return ValueUpdaterObj
function ValueUpdaterObj:x_pingpong()
    return self:x_with(function(obj)
        local x = obj:x_orig()
        return 1 - math.abs(2*x - 1)
    end)
end
---`x`を1→0→1という風に線形で折り返す。
---@return ValueUpdaterObj
function ValueUpdaterObj:x_reversePingpong()
    return self:x_with(function(obj)
        local x = obj:x_orig()
        return math.abs(2*x - 1)
    end)
end
---`x`に放物線関数を用いる。(`1-(2x-1)^2`)
---@return ValueUpdaterObj
function ValueUpdaterObj:x_parabola()
    return self:x_with(function(obj)
        local x = obj:x_orig() * 2 - 1
        return 1 - x * x
    end)
end
---`x`に上下逆の放物線関数を用いる。(`(2x-1)^2`)
---@return ValueUpdaterObj
function ValueUpdaterObj:x_reverseParabola()
    return self:x_with(function(obj)
        local x = obj:x_orig() * 2 - 1
        return x * x
    end)
end

local easing_back_c1 <const> = 1.70158
local easing_back_c2 <const> = easing_back_c1 + 1.525
local easing_back_c3 <const> = easing_back_c1 + 1
---@type table<string, {in: VUO_xfun, out: VUO_xfun, inout: VUO_xfun}>
local easing_functions = {
    ["sin"] = {
        ["in"] = function(obj)
            local x = obj:x_orig()
            return 1 - math.cos(x*math.pi/2)
        end,
        ["out"] = function(obj)
            local x = obj:x_orig()
            return math.sin(x*math.pi/2)
        end,
        ["inout"] = function(obj)
            local x = obj:x_orig()
            return (1-math.cos(x*math.pi))/2
        end,
    },
    ["quad"] = {
        ["in"] = function(obj)
            local x = obj:x_orig()
            return x * x
        end,
        ["out"] = function(obj)
            local x = 1 - obj:x_orig()
            return 1 - x * x
        end,
        ["inout"] = function(obj)
            local x = obj:x_orig()
            local x2 = -2 * x + 2
            return x < 0.5 and 2 * x * x or 1 - x2 * x2 / 2
        end,
    },
    ["cubic"] = {
        ["in"] = function(obj)
            local x = obj:x_orig()
            return x * x * x
        end,
        ["out"] = function(obj)
            local x = 1 - obj:x_orig()
            return 1 - x * x * x
        end,
        ["inout"] = function(obj)
            local x = obj:x_orig()
            local x2 = -2 * x + 2
            return x < 0.5 and 4 * x * x * x or 1 - x2 * x2 * x2 / 2
        end,
    },
    ["back"] = {
        ["in"] = function(obj)
            local x = obj:x_orig()
            local x2 = x * x
            return easing_back_c3 * x * x2 - easing_back_c1 * x2
        end,
        ["out"] = function(obj)
            local x = obj:x_orig() - 1
            local x2 = x * x
            return 1 + easing_back_c3 * x * x2 + easing_back_c1 * x2
        end,
        ["inout"] = function(obj)
            local x = obj:x_orig()
            local a = (easing_back_c2 + 1)
            local x2, b, c
            if x < 0.5 then
                x2 = 2 * x
                b, c = -1, 0
            else
                x2 = 2 * x - 2
                b, c = 1, 2
            end
            return (x2 * x2 * (
                a*x2 + b*easing_back_c2
            ) + c) / 2
        end,
    }
}
--- ease関数を指定する。
--- (https://easings.net/ja を参考。)
---@param type "sin" | "quad" | "cubic" | "back"
---@param inout? "in" | "out" | "inout" default: `"inout"`
---@return ValueUpdaterObj
function ValueUpdaterObj:x_ease(type, inout)
    inout = inout or "inout"
    return self:x_with(easing_functions[type][inout])
end

---@param x? number `nil`なら`self:x()`を用いる
---@return int
function ValueUpdaterObj:lerp(x)
    return math.ilerp(self._dmin, self._dmax, x or self:x())
end
---@return number
function ValueUpdaterObj:sq()
    local x = self:x()
    return x * x
end
---@return number
function ValueUpdaterObj:sqrt()
    return math.sqrt(self:x())
end

---引数有の場合、`[-scale, scale]`の範囲を、無しの場合は`[min, max]`の範囲をとる。
---@param scale number?
---@return int
function ValueUpdaterObj:isin(scale)
    if scale then
        return math.isin(self:x(), scale)
    else
        return math.ilerp(self._dmin, self._dmax, math.sin01(self:x()))
    end
end
---引数有の場合、`[-scale, scale]`の範囲を、無しの場合は`[min, max]`の範囲をとる。
---@param scale number?
---@return int
function ValueUpdaterObj:icos(scale)
    if scale then
        return math.icos(self.i / self.n, scale)
    else
        return math.ilerp(self._dmin, self._dmax, math.cos01(self:x()))
    end
end

---@param n int?
---@param min int?
---@param max int?
---@param calc? VUO_calcEntry
---@return ValueUpdaterObj
local function _ValueUpdater(n, min, max, calc)
    n = n or 1
    assert(n > 0, "n must be positive")
    ---@type ValueUpdaterObj
    local obj = setmetatable({
        i = 0,
        n = n,
        min = nil,
        max = nil,
        v = 0,
        _v = nil,
        _x_func = function(obj)
            return obj.i / obj.n
        end,
        _calc = nil,
        _write = nil,
        _overflow_behavior = OF_Behavior_clamp,
        active = true,
    }, {
        __index = ValueUpdaterObj,
        __call = ValueUpdaterObj.update,
    })
    if calc then obj:calc(calc) end
    return obj:minmax(min, max)
end
ValueUpdater = _ValueUpdater

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
