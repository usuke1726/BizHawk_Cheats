

local newMemReader, GetNameList_u32 = ___nitro_lib.newMemReader, ___nitro_lib.GetNameList_u32

---@class TrackDataFlags
---@field no_channels bool
---@field no_translation_channels bool
---@field translation_x_constant bool
---@field translation_y_constant bool
---@field translation_z_constant bool
---@field no_rotation_channel bool
---@field rotation_constant bool
---@field no_scale_channels bool
---@field scale_x_constant bool
---@field scale_y_constant bool
---@field scale_z_constant bool

---@class SampledCurve
---@field head_addr int
---@field start_frame int
---@field end_frame int
---@field width int
---@field log_rate int
---@field sample_off int

---@class TrackData
---@field head_addr int
---@field flags TrackDataFlags
---@field target_index int
---@field CurveX_Const DataPos_int
---@field CurveY_Const DataPos_int
---@field CurveZ_Const DataPos_int
---@field CurveRot_Const DataPos_int
---@field CurveScaleX_Const1 DataPos_int
---@field CurveScaleX_Const2 DataPos_int
---@field CurveScaleY_Const1 DataPos_int
---@field CurveScaleY_Const2 DataPos_int
---@field CurveScaleZ_Const1 DataPos_int
---@field CurveScaleZ_Const2 DataPos_int
---@field CurveX SampledCurve
---@field CurveY SampledCurve
---@field CurveZ SampledCurve
---@field CurveRot SampledCurve
---@field CurveScaleX SampledCurve
---@field CurveScaleY SampledCurve
---@field CurveScaleZ SampledCurve

---@return TrackData
local function get_Track(begin)
    local function SmpCrv(mem)
        local head = mem.i
        local v = mem:r32()
        local start_frame = (v & 0xffff0000) >> 16
        local end_frame = (v & 0xfff0) >> 4
        local width = (v & 0xc) >> 2
        local log_rate = (v & 0x3)
        return {
            head_addr = head,
            start_frame = start_frame,
            end_frame = end_frame,
            width = width,
            log_rate = log_rate,
            sample_off = mem:r32()
        }
    end
    local mem = newMemReader(begin)
    local flags = mem:r16()
    local flags_d = { -- 下位ビットから順に見る
        no_channels = (flags & 0x1) ~= 0,
        no_translation_channels = (flags & 0x6) ~= 0,
        translation_x_constant = (flags & 0x8) ~= 0,
        translation_y_constant = (flags & 0x10) ~= 0,
        translation_z_constant = (flags & 0x20) ~= 0,
        no_rotation_channel = (flags & 0xc0) ~= 0,
        rotation_constant = (flags & 0x100) ~= 0,
        no_scale_channels = (flags & 0x600) ~= 0,
        scale_x_constant = (flags & 0x800) ~= 0,
        scale_y_constant = (flags & 0x1000) ~= 0,
        scale_z_constant = (flags & 0x2000) ~= 0,
    }
    local dummy = mem:r()
    local target_index = mem:r()
    if flags_d.no_channels then
        return {
            head_addr = begin,
            flags = flags_d,
            target_index = target_index,
        }
    end
    local CurveX_Const
    local CurveY_Const
    local CurveZ_Const
    local CurveRot_Const
    local CurveScaleX_Const1
    local CurveScaleX_Const2
    local CurveScaleY_Const1
    local CurveScaleY_Const2
    local CurveScaleZ_Const1
    local CurveScaleZ_Const2
    local CurveX
    local CurveY
    local CurveZ
    local CurveRot
    local CurveScaleX
    local CurveScaleY
    local CurveScaleZ
    if not flags_d.no_translation_channels then
        if flags_d.translation_x_constant then CurveX_Const = mem:d32()
        else CurveX = SmpCrv(mem)
        end
        if flags_d.translation_y_constant then CurveY_Const = mem:d32()
        else CurveY = SmpCrv(mem)
        end
        if flags_d.translation_z_constant then CurveZ_Const = mem:d32()
        else CurveZ = SmpCrv(mem)
        end
    end
    if not flags_d.no_rotation_channel then
        if flags_d.rotation_constant then CurveRot_Const = mem:d32()
        else CurveRot = SmpCrv(mem)
        end
    end
    if not flags_d.no_scale_channels then
        if flags_d.scale_x_constant then CurveScaleX_Const1 = mem:d32() CurveScaleX_Const2 = mem:d32()
        else CurveScaleX = SmpCrv(mem)
        end
        if flags_d.scale_y_constant then CurveScaleY_Const1 = mem:d32() CurveScaleY_Const2 = mem:d32()
        else CurveScaleY = SmpCrv(mem)
        end
        if flags_d.scale_z_constant then CurveScaleZ_Const1 = mem:d32() CurveScaleZ_Const2 = mem:d32()
        else CurveScaleZ = SmpCrv(mem)
        end
    end
    return {
        head_addr = begin,
        flags = flags_d,
        target_index = target_index,
        CurveX_Const = CurveX_Const,
        CurveY_Const = CurveY_Const,
        CurveZ_Const = CurveZ_Const,
        CurveRot_Const = CurveRot_Const,
        CurveScaleX_Const1 = CurveScaleX_Const1,
        CurveScaleX_Const2 = CurveScaleX_Const2,
        CurveScaleY_Const1 = CurveScaleY_Const1,
        CurveScaleY_Const2 = CurveScaleY_Const2,
        CurveScaleZ_Const1 = CurveScaleZ_Const1,
        CurveScaleZ_Const2 = CurveScaleZ_Const2,
        CurveX = CurveX,
        CurveY = CurveY,
        CurveZ = CurveZ,
        CurveRot = CurveRot,
        CurveScaleX = CurveScaleX,
        CurveScaleY = CurveScaleY,
        CurveScaleZ = CurveScaleZ,
    }
end

---@param begin int
---@param anim_idx int
---@param w Writer
---@param addrs_tr int[]
---@param addrs_rot int[]
---@param addrs_scl int[]
local function read_Animation(begin, anim_idx, w, addrs_tr, addrs_rot, addrs_scl)
    local mem = newMemReader(begin)
    local stamp = string.char(mem:r(4))
    if stamp ~= "J\x00AC" then
        w:wl(string.format("wrong addr: \"J\\0AC\" is not contained at 0x%08X", begin))
        return
    end
    local num_frames = mem:r16()
    local num_tracks = mem:r16()
    local unknown_v1 = mem:r32()
    local pivot_mat_off = mem:r32()
    local basis_mat_off = mem:r32()
    local track_offs = {}
    local tracks = {}
    w:wl(string.format("\n## Animation %d at 0x%08X\n  - %d frames, %d tracks\n  - pivot_mat => 0x%08X\n  - basis_mat => 0x%08X", anim_idx, begin, num_frames, num_tracks, begin + pivot_mat_off, begin + basis_mat_off))
    local function dataStr(is_constant, const, norm)
        if is_constant then return string.format("C%08X", const.addr), const.addr
        else return string.format("s%08X", norm.head_addr), norm.head_addr
        end
    end
    for i = 1, num_tracks do
        track_offs[i] = mem:r16()
        local track = get_Track(begin + track_offs[i])
        tracks[i] = track
        w:wl(string.format("\nTrack %d (at 0x%08X)", i, track.head_addr))
        if track.flags.no_channels then w:wl("  (no_channels)")
        else
            local _printed = false
            if not track.flags.no_translation_channels then
                _printed = true
                local x, ax = dataStr(track.flags.translation_x_constant, track.CurveX_Const, track.CurveX)
                local y, ay = dataStr(track.flags.translation_y_constant, track.CurveY_Const, track.CurveY)
                local z, az = dataStr(track.flags.translation_z_constant, track.CurveZ_Const, track.CurveZ)
                w:wl(string.format("[TR] %s %s %s", x, y, z))
                table.insert(addrs_tr, ax)
                table.insert(addrs_tr, ay)
                table.insert(addrs_tr, az)
            end
            if not track.flags.no_rotation_channel then
                _printed = true
                local rot, arot = dataStr(track.flags.rotation_constant, track.CurveRot_Const, track.CurveRot)
                w:wl(string.format("[Rot] %s", rot))
                table.insert(addrs_rot, arot)
            end
            if not track.flags.no_scale_channels then
                _printed = true
                local x, ax = dataStr(track.flags.scale_x_constant, track.CurveScaleX_Const1, track.CurveScaleX)
                local y, ay = dataStr(track.flags.scale_y_constant, track.CurveScaleY_Const1, track.CurveScaleY)
                local z, az = dataStr(track.flags.scale_z_constant, track.CurveScaleZ_Const1, track.CurveScaleZ)
                w:wl(string.format("[SCL] %s %s %s", x, y, z))
                table.insert(addrs_scl, ax)
                table.insert(addrs_scl, ay)
                table.insert(addrs_scl, az)
            end
            if not _printed then
                w:wl("[Nothing]")
            end
        end
    end
end

---@alias JNT0ReadResult { addrs_tr: int[], addrs_rot: int[], addrs_scl: int[] }

---アニメーションデータの情報をダンプする
---@param begin int `"JNT0"`があるアドレス
---@param writer_query WriterQuery ファイル名(`string`)または標準出力(`bool?`)
---@return JNT0ReadResult
local function read_JNT0(begin, writer_query)
    local w = lib.path.w(writer_query)
    local mem = newMemReader(begin)
    local stamp = string.char(mem:r(4))
    local empty_res = {addrs_tr = {}, addrs_rot = {}, addrs_scl = {}}
    if stamp ~= "JNT0" then
        local _b = btos({string.byte(stamp, 1, #stamp)})
        w:wl(string.format("wrong addr: \"JNT0\" is not contained at 0x%08X (value: %s)", begin, _b))
        w:close()
        return empty_res
    end
    local filesize = mem:r32()
    local animations = GetNameList_u32(mem)
    if not animations then
        w:close()
        return empty_res
    end
    w:wl(string.format("# JNT0\n  - range: 0x%08X -- 0x%08X (bound: 0x%X)\n  - %d Animation%s\n", begin, begin + filesize, filesize, animations.count, (animations.count > 1 and "s" or "") ))
    local addrs_tr, addrs_rot, addrs_scl = {}, {}, {}
    for i = 1, animations.count do
        local offset = animations.data[i].v
        read_Animation(begin + offset, i, w, addrs_tr, addrs_rot, addrs_scl)
    end
    w:close()
    return {
        addrs_tr = addrs_tr,
        addrs_rot = addrs_rot,
        addrs_scl = addrs_scl,
    }
end

---@param begin? int
---@param inclusiveEnd? int
---@param silent? bool
---@return bool, int
local function find_JNT0(begin, inclusiveEnd, silent)
    begin = begin or 0x02000000
    inclusiveEnd = inclusiveEnd or (begin + 0x003fffff)
    return lib.find(begin, inclusiveEnd, ascii("JNT0"), 4, nil, silent)
end

return {
    read_JNT0 = read_JNT0,
    find_JNT0 = find_JNT0,
}

