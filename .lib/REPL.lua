
local setup_done = false
local server_active = false
local connecting = false

local function setup()
    setup_done = true
    local info = comm.socketServerGetInfo()
    if #info == 0 then return end
    server_active = true
    comm.socketServerSetTimeout(3)
    -- comm.socketServerSetTimeout(10)
    return true
end

---@type table<string, fun(body: string)>
local commands = {
    ["do"] = function(body)
        local preview = #body > 40 and string.sub(body, 1, 20) .. "..." .. string.sub(body, #body - 20) or body
        print("DO " .. preview)
        fun, err_mes = load(body)
        if fun then
            success, mes = pcall(fun)
            if not success then
                print("Runtime Error: " .. tostring(mes))
            end
        else print("User Error: " .. err_mes)
        end
    end,
}

---@param s string
local function try_parse(s)
    local n = #s
    local idx = string.find(s, ":")
    if idx == nil or idx == 1 or idx > 5 then
        print("(Message [idx: " .. tostring(idx or "nil") .. "]) " .. s)
        return
    end
    local command = string.sub(s, 1, idx - 1)
    local body = string.sub(s, idx + 1)
    local matched = false
    for key, fun in pairs(commands) do
        if key == command then
            matched = true
            fun(body)
            break
        end
    end
    if not matched then
        print("(Message [command: \"" .. command .. "\"]) " .. s)
    end
end

local function main()
    if not setup_done then setup() end
    if not server_active then return end
    connecting = comm.socketServerIsConnected()
    if not connecting then return end
    local s = comm.socketServerResponse()
    if s and #s > 0 then
        try_parse(s)
    end
end

return {
    main_loop = main,
}
