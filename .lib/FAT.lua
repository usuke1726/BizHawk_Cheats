
---@class FNTFile
---@field is_dir bool
---@field name string
---@field id int
---@field parent_dir_id int
---@field file_fat_addr int
---@field file_begin int
---@field file_end int

---@class FNTDirectory
---@field id int
---@field name string
---@field parent_id int
---@field is_root bool
---@field files FNTFile[]

local ROOT_DIR_ID = 0xF000
local ROOT_DIR_DUMMY_NAME = "/"

---@param RAMFNTaddr? int
local function get_FNTaddr(RAMFNTaddr)
    if RAMFNTaddr then return RAMFNTaddr end
    local ROMFNTaddr = r32r(0x40)
    local ROMFNTsize = r32r(0x44)
    local RAMFNTfound, a = lib.find(0x02000000, 0x023fffff, lib.romrarr(ROMFNTaddr, ROMFNTaddr + math.min(ROMFNTsize - 1, 0x3f)), nil, nil, true)
    if RAMFNTfound then
        printf("RAM FNT found at 0x%08X", a)
        return a
    else return ROMFNTaddr
    end
end
---@param RAMFATaddr? int
local function get_FATaddr(RAMFATaddr)
    if RAMFATaddr then return RAMFATaddr end
    local ROMFATaddr = r32r(0x48)
    local ROMFATsize = r32r(0x4C)
    local RAMFATfound, a = lib.find(0x02000000, 0x023fffff, lib.romrarr(ROMFATaddr, ROMFATaddr + math.min(ROMFATsize - 1, 0x3f)), nil, nil, true)
    if RAMFATfound then
        printf("RAM FAT found at 0x%08X", a)
        return a
    else return ROMFATaddr
    end
end

---@param RAMFNTaddr? int
---@param RAMFATaddr? int
---@return FNTDirectory[]
---@return FNTFile[]
local function read_FNT(RAMFNTaddr, RAMFATaddr)
    local FNT_addr = get_FNTaddr(RAMFNTaddr)
    local FAT_addr = get_FATaddr(RAMFATaddr)

    ---@type {addr: int, first_file_id: int, parent_id: int}[]
    local entries = {}
    local first_entry_addr
    local _i = FNT_addr
    while true do
        if first_entry_addr and _i >= first_entry_addr then break end
        local entry_addr = r32(_i) + FNT_addr
        local first_file_id = r16(_i+4)
        local parent_id = r16(_i+6)
        first_entry_addr = first_entry_addr or entry_addr
        table.insert(entries, {
            addr = entry_addr,
            first_file_id = first_file_id,
            parent_id = parent_id,
        })
        _i = _i + 8
    end
    local n = #entries
    local data = {}
    local all_files = {}
    ---@type {name: string, id: int}[]
    local directories = {}
    for i = 1, n do
        local files = {}
        local idx = 0
        local entry = entries[i]
        local end_adr = (entries[i+1] or {addr = nil}).addr
        local a = entry.addr
        local current_dir_name, current_dir_id
        if i == 1 then
            current_dir_name = ROOT_DIR_DUMMY_NAME
            current_dir_id = ROOT_DIR_ID
        else
            local _dir = assert(directories[i-1], "folder out of bounds")
            current_dir_name = _dir.name
            current_dir_id = _dir.id
        end
        while true do
            if end_adr then if a >= end_adr then break end
            else if r8(a) == 0 and r8(a+1) == 0 then break end
            end
            local len = r8(a)
            if len == 0 and end_adr and a+1 >= end_adr then
                break
            end
            local is_dir = false
            if len > 0x80 then
                is_dir = true
                len = len & 0x7f
            end
            local s = {}
            for j = 1, len do
                table.insert(s, string.char(r8(a + j)))
            end
            a = a + len + 1
            local s2 = table.concat(s, "")
            if is_dir then
                local id = r8(a) | (r8(a+1) << 8)
                table.insert(directories, {name = s2, id = id})
                table.insert(files, {
                    is_dir = true,
                    name = s2,
                    id = id,
                    file_fat_addr = 0,
                    file_begin = 0,
                    file_end = 0,
                    parent_dir_id = current_dir_id,
                })
                a = a + 2
            else
                local id = entry.first_file_id + idx
                local file_fat_addr = FAT_addr + 8 * (id)
                local begin, iend = r32(file_fat_addr), r32(file_fat_addr+4)
                local file = {
                    is_dir = false,
                    name = s2,
                    id = id,
                    file_fat_addr = file_fat_addr,
                    file_begin = begin,
                    file_end = iend,
                    parent_dir_id = current_dir_id,
                }
                table.insert(files, file)
                table.insert(all_files, file)
            end
            idx = idx + 1
        end
        if i == 1 then
            table.insert(data, {
                id = current_dir_id,
                name = current_dir_name,
                parent_id = 0,
                is_root = true,
                files = files,
            })
        else
            table.insert(data, {
                id = current_dir_id,
                name = current_dir_name,
                parent_id = entry.parent_id,
                is_root = false,
                files = files,
            })
        end
    end
    return data, all_files
end

---@param filename string
---@param data FNTDirectory[]
---@return FNTFile?
local function find_file(filename, data)
    for _, d in pairs(data) do
        for _, f in pairs(d.files) do
            if f.name == filename then
                return f
            end
        end
    end
    return nil
end

---@param target FNTFile | string
---@param data FNTDirectory[]
---@return string
local function full_path(target, data)
    local f
    if type(target) == "string" then
        f = assert(find_file(target, data), "not found ".. target)
    else f = target
    end
    local names = {f.name}
    local id = f.parent_dir_id
    while true do
        if id == ROOT_DIR_ID then break end
        local dir = Array.find(data, function(d) return d.id == id end)
        if not dir then
            error(string.format("not found folder with id 0x%X", id))
        end
        table.insert(names, dir.name)
        id = dir.parent_id
    end
    local n = #names
    local _names = {}
    for i = 1, n do
        _names[i] = names[n-i+1]
    end
    return "/" .. table.concat(_names, "/")
end

---@param filename WriterQuery
---@param RAMFNTaddr? int
---@param RAMFATaddr? int
local function dump_files(filename, RAMFNTaddr, RAMFATaddr)
    local F = lib.path.w(filename)
    local data = read_FNT(RAMFNTaddr, RAMFATaddr)
    for i, d in pairs(data) do
        F:wl("=======================")
        if not d.is_root then
            F:wl("*** DIR \"%s\"", d.name)
        end
        for _, file in pairs(d.files) do
            if file.is_dir then
                F:wl("FOLDER 0x%X \"%s\"", file.id, file.name)
            else
                F:wl("file 0x%X \"%s\" (ROM 0x%08X -- 0x%08X (FAT 0x%08X))", file.id, file.name, file.file_begin, file.file_end, file.file_fat_addr)
            end
        end
    end
    F:close()
end

return {
    read_FNT = read_FNT,
    find_file = find_file,
    dump_files = dump_files,
    full_path = full_path,
}
