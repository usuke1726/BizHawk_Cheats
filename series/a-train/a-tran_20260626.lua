
package.path = os.getenv("BizHawk_ULibPath") .. package.path
lib = require "lib"

tachie_data = require "_tachie_data"

local faces = {
    lib.htob(tachie_data.shoken_smile),
    lib.htob(tachie_data.shoken_norm),
    lib.htob(tachie_data.shoken_surp),
    lib.htob(tachie_data.hisho_norm),
    lib.htob(tachie_data.hisho_smile),
    lib.htob(tachie_data.hisho_surp),

    lib.htob(tachie_data.keiri_smile),
    lib.htob(tachie_data.keiri_norm),
    lib.htob(tachie_data.keiri_surp),
    lib.htob(tachie_data.gyomu_smile),
    lib.htob(tachie_data.gyomu_norm),
    lib.htob(tachie_data.gyomu_surp),
    lib.htob(tachie_data.shasho_smile),
    lib.htob(tachie_data.shasho_norm),
    lib.htob(tachie_data.shasho_surp),
    lib.htob(tachie_data.ginko_smile),
    lib.htob(tachie_data.ginko_norm),
    lib.htob(tachie_data.ginko_surp),
    lib.htob(tachie_data.kouji_smile),
    lib.htob(tachie_data.kouji_norm),
    lib.htob(tachie_data.kouji_surp),
}


local r = Cnt(60)
local lady_r = RC(90)
local r_c2 = Cnt(1)
local lady = false
local n = #faces
local prev = -1
local is_first = true

local function update_face()
    if lady_r() then
        lady = not lady
        lady_r:N(lady and 30 or 90)
    end
    if not r() then return end
    if r_c2() then
        r:N(math.max(r.n - math.ceil(r.n * 0.2), 5))
        r_c2:N(math.min(r_c2.n + 1, 30))
    end
    local i
    while true do
        if is_first then
            is_first = false
            i = 1
        end
        i = rand(1, lady and 6 or n)
        if i ~= prev then break end
    end
    local f = faces[i]
    prev = i
    lib.warr(0x06608f80, f) -- smile
    lib.warr(0x06626380, f) -- surprise
    lib.warr(0x06623780, f) -- normal
end


-- ======================
-- ====== イルーム ======
-- ======================

local head = 0x03ce8660
local d = 0x40
-- 微分音: 0x0C (signed 2byte LE)
-- pitch: 0x13 (1 byte)
-- vib speed: 0x15 (1 byte, 大きいほど遅い)
-- vib depth: 0x16 (signed 2 byte LE, 負の値で音が上がる)

local function irume1()
    local addrs = {}
    for i = 0, 16 do addrs[i+1] = head + d*i end
    local rl = RL(990)
    return function()
        w8(addrs[1] + 0xa, 0x80)
        if rl() then
            w16(addrs[1] + 0x16, 0xfe00)
        end
    end
end


local function irume2()
    local addrs = {}
    for i = 0, 16 do addrs[i+1] = head + d*i end
    local _r = RC(20)
    return function()
        w8(addrs[1] + 0xa, 0x80)
        w16(addrs[1] + 0x16, 0xfe00)
        for i = 1, 16 do
            if _r() then
                w8(addrs[i+1] + 0x13, stou8(rand(-4, 4)))
                w16(addrs[i+1] + 0xc, stou16(rand(-100, 100)))
            end
        end
    end
end

local function irume3()
    local addrs = {}
    for i = 0, 16 do addrs[i+1] = head + d*i end
    local _r = RC(20)
    return function()
        w8(addrs[1] + 0xa, 0x80)
        w16(addrs[1] + 0x16, 0xfe00)
        for i = 1, 16 do
            w8(addrs[i+1] + 0xa, 0x30)
            if _r() then
                w8(addrs[i+1] + 0x13, stou8(rand(-4, 4)))
                w16(addrs[i+1] + 0xc, stou16(rand(-100, 100)))
            end
        end
    end
end

-- ====================================
-- ====== ゲームオーバー画面バグ ======
-- ====================================

local function mame_omae()

    -- lib.fill_in(0x06500000, 0x065fffff, 0xff)
    -- lib.fill_in(0x06504000, 0x06504fff, 0xff)

    -- G: 0x06503680, 3780, 3800
    local g_a = {
    -- 0x06503680,
    0x06503780,
    0x06503880,
    0x06503980,
    0x06504380,
    0x06504400,
    }
    local vs = {}
    for _, a in pairs(g_a) do
        for i = 0, 0x7f, 4 do
            local ad = a + i
            if within(i, 0x20, 0x7f) then
                local _i = i - 0x20
                if within(a, 0x06503780, 0x06503980) then
                    local offset = a - 0x06503780
                    -- 上段
                    _i = within(_i, 0, 0x1f) and _i + 0x3860 or _i - 0x20 + 0x3b80
                    local _a = _i + offset + 0x06500000
                    vs[ad] = r32(_a)
                else
                    -- 下段
                    local offset = a - 0x06504380
                    _i = within(_i, 0, 0x1f) and _i + 0x44e0 or _i - 0x20 + 0x4580
                    local _a = _i + offset + 0x06500000
                    vs[ad] = r32(_a)
                end
            else
                vs[ad] = 0x00000000
            end
        end
    end
    for a, v in pairs(vs) do
        w32(a, v)
    end

    -- M 
    -- 3860--7f
    -- 3960--7f
    -- 3a60--7f

    -- M右側
    -- 3b80--bf
    -- 3c80--bf
    -- 3d80--bf

    -- M下左側
    -- 44e0--ff

    -- M下右側
    -- 4580--bf

    vs = {}
    local ve_a = {
    0x06503fa0,
    0x065040a0,
    0x065041a0,
    }
    for _, a in pairs(ve_a) do
        for i = 0, 0xbf, 4 do
            local ad = a + i
            vs[ad] = r32(ad - 0x3fa0 + 0x37a0)
        end
    end
    for i = 0, 0x5f do
        vs[i + 0x065047a0] = r32(i + 0x065043a0)
        vs[i + 0x06504880] = r32(i + 0x06504480)
    end
    for a, v in pairs(vs) do
        w32(a, v)
    end

    -- MA
    -- 37a0--385f
    -- 38a0--395f
    -- 39a0--3a5f
    -- 下段
    -- 43a0--43ff
    -- 4480--44df

    -- VE
    -- 3fa0--405f
    -- 40a0--415f
    -- 41a0--425f
    -- 下段
    -- 47a0--47ff
    -- 4880--48df

    vs = {}
    local r_a = {
    0x06504060,
    0x06504160,
    0x06504260,
    }
    for _, a in pairs(r_a) do
        for i = 0, 0x5f, 4 do
            local offset = a - 0x06504060
            local ad = within(i, 0, 0x1f) and a + i or 0x065042c0 + (offset // 4) + i - 0x20
            vs[ad] = r32(0x06503bc0 + offset + i)
            if within(i, 0, 0x1f) then
                vs[ad] = vs[ad] & 0xffff0000
            end
        end
    end
    for i = 0, 0x5f, 4 do
        local a = 0x065048e0
        local ad = within(i, 0, 0x1f) and a + i or a - 0x48e0 + 0x4980 + i - 0x20
        local ad2 = within(i, 0, 0x3f) and 0x065045c0 + i or 0x06504680 + i - 0x40
        vs[ad] = r32(ad2)
    end
    for a, v in pairs(vs) do
        w32(a, v)
    end

    -- E
    -- 3bc0--3c1f (5f)
    -- 3cc0--3d1f
    -- 3dc0--3e1f

    -- R
    -- 左
    -- 4060--407f
    -- 4160--417f
    -- 4260--427f
    -- 右
    -- 42c0--42ff
    -- 4300--433f
    -- 4340--437f
    -- 下段左
    -- 48e0--48ff
    -- 下段右
    -- 4980--49bf
end

local function atatata()
    -- 仮想座標から物理アドレスへ
    local function change_pos1(x, y)
        local w1 = 4
        local w2 = 16
        local h = 8
        local nh = 2
        local B2base = (x // w2) * w2 * h * nh
        local B1base = ((x % w2) // w1) * h * w1 + (y // h) * w2 * h
        local offset = x % w1 + (y % h) * w1
        return B2base + B1base + offset
    end

    -- 仮想座標から物理アドレスへ
    local function change_pos2(x, y)
        -- local a, b, c = block_span, blockline_span, block_width
        local a, b, c = 0x20, 0x320, 0x04
        local W = c * (b // a)
        local v = W*y + x
        local v2, v3 = v % b, v // b
        local A1, A2 = v2 % W, v2 // W
        local C1, C2 = A1 % c, A1 // c
        local V1 = A2*c + C2*a + C1
        return (v3*b + V1) + 0x06505080
    end
    local function change_pos(x, y)
        local w1 = 4
        local w2 = 16
        local h = 8
        local nh = 2
        local B2_num = 6
        if within(x, 0, w2 * B2_num - 1) and within(y, 0, h*nh-1) then
            -- つまり、x in [0..95], y in [0..15]
            return change_pos1(x, y) + 0x06504a00
        elseif within(y, h*nh-1, h*(nh+1)-1) then
            -- つまり、x in [0..99], y in [16..23]
            return change_pos2(x, y - 16)
        else error("not implemented yet")
        end
    end
    local vs = {}
    for x = 0, 95 do
        for y = 0, 23 do
            if within(x, 25, 30) then
            vs[change_pos(x, y)] = r8(change_pos(x - 22, y))
            elseif within(x, 31, 93) then
                local _w = (x - 10) % 5 + 15
                -- local _w = (x - 10) % 4 + 15 -- BOTSU
                vs[change_pos(x, y)] = r8(change_pos(_w, y))
            end
        end
    end
    for a, v in pairs(vs) do
        local _a = a & 0xfffffffc
        local offset = a & 0x3
        local _v = v << (offset * 8)
        local mask = 0xffffffff ~ (0xff << (offset * 8))
        local __v = (r32(_a) & mask) | _v
        w32(_a, __v)
    end
end

-- =============================================================
-- =============================================================
-- =============================================================
-- =============================================================
-- =============================================================


local actions = {
function()
print("GAME INFO SETUP DONE ")
-- 青葉未払手数料
lib.warr(0x2128f9c, lib.htob("529749842a6755624b6270659965"))
-- 俺ップ
lib.warr(0x20fe9fa, lib.htob("fa4fc330d730"))
-- ゲーム幕府
lib.warr(0x20ff9e4, lib.htob("b230fc30e030555e9c5e"))
end,

function()
print("GAME SELECT SETUP DONE ")
-- 今はマだップ選択しかできゃ～～～ん！？
lib.warr(0x2347596, lib.htob("ca4e6f30de306030c330d73078909e6257304b3067304d3083305eff5eff5eff933001ff1fff0000"))
-- ここで他の買収もできるようになります。
lib.warr(0x23475be, lib.htob("533053306730d64e6e30b78cce53823067304d308b30883046306b306a308a307e30593002300000"))
-- マッ金利では、社長がごま塩をふることに
lib.warr(0x23475f0, lib.htob("de30c330d191295267306f3001303e7977954c3054307e306958923075308b30533068306b300000"))
-- なる値域を叫ぶことができます。
lib.warr(0x2347618, lib.htob("6a308b302450df579230eb537630533068304c3067304d307e30593002300000"))
-- #bl青葉#gr食域シボーズのゲップでは、ゲーボの
lib.warr(0x2347642, lib.htob("230062006c0052974984230067007200df98df57b730dc30fc30ba306e30b230c330d73067306f300130b230fc30dc306e300000"))
-- 溜め方や劇中歌を聞きながら並べますよ。
lib.warr(0x2347676, lib.htob("9c6e8130b965843087522d4e4c6b92305e804d306a304c308930264e79307e305930883002300000"))
-- シげリオマップに挑発する朕に、ぜひ
lib.warr(0x23476a8, lib.htob("b7305230ea30aa30de30c330d7306b3011637a7659308b3015676b3001305c3072300000"))
-- 局所整域マップで遊んでみてくださいね。
lib.warr(0x23476cc, lib.htob("405c40627465df57de30c330d73067304a90933067307f3066304f306030553044306d300230"))
-- 遊びたい自社株が決まりましたら、
lib.warr(0x234770a, lib.htob("4a9073305f304430ea813e792a684c307a6c7e308a307e3057305f30893001300000"))
-- #blゲーム開始#grボインをタッチしてください。
lib.warr(0x234772e, lib.htob("230062006c00b230fc30e0308b95cb59230067007200dc30a430f3309230bf30c330c130573066304f3060305530443002300000"))
-- ゲームの取引に興奮できましたか？
lib.warr(0x213f2a0, lib.htob("b230fc30e0306e30d653155f6b3008826e5967304d307e3057305f304b301fff0000"))
-- #blパーム開始#grボタンで安全圏を撤去します。
lib.warr(0x213f2e4, lib.htob("230062006c00d130fc30e0308b95cb59230067007200dc30bf30f3306730895b68510f579230a464bb5357307e30593002300000"))
end,

function()
print("START SCREEN")
lib.irume.start(irume2)
end,

function()
print("INTRO SETUP DONE")
lib.irume.start(irume3)
-- あたたまめして、この度は社長ご就忍、
lib.warr(0x237f190, lib.htob("42305f305f307e30813057306630013053306e30a65e6f303e7977955430315ccd5f01300000"))
w8(0x237f18c, 0x5) -- chara 5
-- だめでとうございまっ！
lib.warr(0x237f1b8, lib.htob("603081306730683046305430563044307e30633001ff0000"))
-- 当グレープが、この食品の借入整備に
lib.warr(0x237f1da, lib.htob("535fb030ec30fc30d7304c30013053306e30df98c1546e301f506551746599506b300000"))
w8(0x237f1d6, 0x5) -- chara 5
-- 馬乗りをあげたのは法人税のことでした。
lib.warr(0x237f1fe, lib.htob("ac99574e8a309230423052305f306e306f30d56cba4e0e7a6e3053306830673057305f3002300000"))
-- なるほど、この売上で車内公開産業が
lib.warr(0x237f230, lib.htob("6a308b307b306930013053306e30f2580a4e6730ca8e85516c518b9523756d694c300000"))
w8(0x237f22c, 0x5) -- chara 5
-- 誘致される福利厚生促進よっしゃあッ！
lib.warr(0x237f254, lib.htob("988af48155308c308b308f7929529a531f75c34f329088306330573083304230c33001ff0000"))
-- 果して、子会社との共同債務超過により、
lib.warr(0x237f286, lib.htob("9c67573066300130505b1a4f3e7968306e3071510c54b550d952858d4e906b3088308a3001300000"))
w8(0x237f282, 0x5) -- chara 5
-- グローバル電話マンが採掘場で超合体。
lib.warr(0x237f2ae, lib.htob("b030ed30fc30d030eb30fb96718ade30f3304c30a163986334586730858d0854534f02300000"))
-- 新有価証券のウップとなられた男す。
lib.warr(0x237f2e0, lib.htob("b0650967a14f3c8a38526e30a630c330d73068306a3089308c305f303775593002300000"))
w8(0x237f2dc, 0x0) -- chara 0
-- 大きな状態アイコンが純資産よ。
lib.warr(0x237f304, lib.htob("27594d306a30b6724b61a230a430b330f3304c30147dc78c237588300230"))
-- 社長も大いにプッシャーを感じて
lib.warr(0x237f32e, lib.htob("3e7977958230275944306b30d730c330b730e330fc3092301f6158306630"))
w8(0x237f32a, 0x0) -- chara 0
-- Ｈらっしゃることでしょうね。
lib.warr(0x237f352, lib.htob("28ff89306330573083308b305330683067305730873046306d3002300000"))
-- 私も秘書ッマンとして一緒りますので、
lib.warr(0x237f37c, lib.htob("c1798230d879f866c330de30f330683057306630004ed27d8a307e3059306e30673001300000"))
w8(0x237f378, 0x0) -- chara 0
-- どうぞよろしくお倒産します。
lib.warr(0x237f3a4, lib.htob("693046305e3088308d3057304f304a301250237557307e30593002300000"))
-- どこにも負けないくらい立派な現金預金に
lib.warr(0x237f3ce, lib.htob("693053306b308230a08c51306a3044304f3089304430cb7a3e6d6a30fe73d1911098d1916b300000"))
w8(0x237f3ca, 0x0) -- chara 0
-- 突貫させていきましょうね。
lib.warr(0x237f3f6, lib.htob("817aab8c55305b30663044304d307e305730873046306d3002300000"))
-- それでは、社歌の力を必要としている
lib.warr(0x237f41c, lib.htob("5d308c3067306f3001303e794c6b6e309b529230c55f818968305730663044308b300000"))
w8(0x237f418, 0x1) -- chara 1
-- 地域へと早速ご案内かますね。
lib.warr(0x237f440, lib.htob("3057df5778306830e9651f905430486885514b307e3059306d3002300000"))
-- この己が、これから繰上返済を行って
lib.warr(0x237f474, lib.htob("53306e30f15d4c30013053308c304b308930707e0a4ed48f086e92304c88633066300000"))
w8(0x237f470, 0x1) -- chara 1
-- いただく菊地です。
lib.warr(0x237f498, lib.htob("44305f3060304f30ca8330576730593002300000"))
-- 小さな鳥ですが、数年前からリモート化が
lib.warr(0x237f4b6, lib.htob("0f5c55306a30e59c673059304c3001307065745e4d524b308930ea30e230fc30c83016534c300000"))
w8(0x237f4b2, 0x2) -- chara 2
-- 進められています。
lib.warr(0x237f4de, lib.htob("3290813089308c30663044307e30593002300000"))
-- このため、利益供与を全部する計画も
lib.warr(0x237f4fc, lib.htob("53306e305f30813001302952ca769b4f0e4e92306851e89059308b30088a3b7582300000"))
w8(0x237f4f8, 0x2) -- chara 2
-- 売却中です。
lib.warr(0x237f520, lib.htob("f25874532d4e6730593002300000"))
-- 社長には、このお路線大絶賛計画を歌に
lib.warr(0x237f53a, lib.htob("3e7977956b306f30013053306e304a30ef8dda7d2759767ddb8c088a3b7592304c6b6b300000"))
w8(0x237f536, 0x3) -- chara 3
-- 乗せるための手腕が破産されています。
lib.warr(0x237f562, lib.htob("574e5b308b305f3081306e304b6255814c303478237555308c30663044307e30593002300000"))
-- それでは、まずは未払男前税特別開発して
lib.warr(0x237f594, lib.htob("5d308c3067306f3001307e305a306f302a67556237754d520e7a797225528b957a76573066300000"))
w8(0x237f590, 0x3) -- chara 3
-- いただけますでしょうか。
lib.warr(0x237f5bc, lib.htob("44305f30603051307e30593067305730873046304b3002300000"))
-- 地域の視察は#re十億借入金#grで行います。
lib.warr(0x237f5e6, lib.htob("3057df576e309689df5b6f30230072006500415304511f506551d19123006700720067304c8844307e30593002300000"))
w8(0x237f5e2, 0x4) -- chara 4
-- 押下方向に画面が隣町へ社員旅行します。
lib.warr(0x237f616, lib.htob("bc620b4eb96511546b303b7562974c30a3963a7578303e79e154c5654c8857307e30593002300000"))
-- 陸海空をタッチすることでも新宿は
lib.warr(0x237f648, lib.htob("7896776d7a7a9230bf30c330c13059308b305330683067308230b065bf5b6f300000"))
w8(0x237f644, 0x4) -- chara 4
-- 粘着ロールできますよ。
lib.warr(0x237f66c, lib.htob("987c4077ed30fc30eb3067304d307e305930883002300000"))
-- #bl俺ボタン#gr、#bl魂ボタン#grを押すと
lib.warr(0x237f692, lib.htob("230062006c00fa4fdc30bf30f3302300670072000130230062006c00429bdc30bf30f3302300670072009230bc62593068300000"))
w8(0x237f68e, 0x6) -- chara 6
-- 特別ボーナスを依頼できます。
lib.warr(0x237f6c6, lib.htob("79722552dc30fc30ca30b93092309d4f3c9867304d307e30593002300000"))
-- 広告が終わったら、下画面のシスコンに
lib.warr(0x237f704, lib.htob("835e4a544c30427d8f3063305f30893001300b4e3b7562976e30b730b930b330f3306b300000"))
w8(0x237f700, 0x6) -- chara 6
-- 帰るチしてくださいね。
lib.warr(0x237f72c, lib.htob("305e8b30c130573066304f306030553044306d300230"))
-- それでは、いってろ。
lib.warr(0x237f74e, lib.htob("5d308c3067306f3001304430633066308d3002300030003000300030003000300000"))
w8(0x237f74a, 0x5) -- chara 5
end,

function()
    print("update_face SETUP DONE")
    -- 画面操作可能になったら即ゲームオーバーにする
    w32(0x0215E378, 0xffffffff)
    return function()
        update_face()
    end
end,

function()
    print("gameover SETUP DONE")
    local state = 0
    return function()
        if state == 0 then
            if r8(0x021c862A) == 0x11 then
                print("FIRED")
                state = 1
                lib.timer.setTimeout(2, atatata)
                lib.timer.setTimeout(20, mame_omae)
            end
        end
    end
end,
}


local prev_L = false
local cooltime = 0
local _action_func = nil
local _action_i = 0
function loop()
    if cooltime > 0 then cooltime = cooltime - 1 end
    if (not prev_L) and cooltime <= 0 and DS.key.get("L") then
        cooltime = 30
        prev_L = true
        _action_i = _action_i + 1
        if _action_i <= #actions then
            _action_func = actions[_action_i]()
        else
            _action_func = nil
            print("END")
        end
    elseif prev_L and cooltime <= 0 and (not DS.key.get("L")) then
        prev_L = false
    end
    if _action_func then pcall(_action_func) end
end

lib.irume.start(irume1)

CLS()

while true do
    lib.main()
    emu.frameadvance()
end
