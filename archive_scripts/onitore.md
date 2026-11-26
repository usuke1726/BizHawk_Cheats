
# 鬼トレ

## video27

<details>
<summary>コード</summary>
<div>

### テキスト

```
文字コードはutf-16le

0x06994806
ケータイとか
パソコンとかって…
>
ケーワイとか
イタパソとかって…

※特殊フォントなので使える文字はごく限られる。

使える文字:
あいうえかきこけこさしすそたつてと
なにのはひまめらりるれやよわをん
がぎぐずぜでどば
イキクケコサスソタトニメモヤリルレワン
ギグズドパピ

0x06994828
知りたいことが
すぐわかるし
>
ヤりたいひとが
すぐさかるし


0x06994846
超!便利
>
便便便便便便便便便便便便便便便便
便便便便便便便便便便便便便便便便
便便便便便便便便便便便便便便便便
便便便便便便便便便便便便便便便便
便便便便便便便便便便便便便便便便
便便便便便便便便便便便便便便便便
便便便便便便便便便便便便便便便便

0x06994852
…と思っているアナタ！
>
…と思っていろアナタ！
(ひらがな全部、カタカナはアナタの3文字だけ使用可能)

0x0699486A
と～こ～ろ～が～
>
と～こ～ろ～で～

0x0699487C
どっこいなんです！
>
私っコイなんです！

0x06994890
この便利な道具のせいで
私たちは…
>
この便意な鬼道のせいで
いたちは…

0x069948B4
集中できなく
なっているのです！
>
変態できなく
なっているのです！

0x069948D6
あなたも心当たり
ありませんか？
>
あなたも心当たり
ありませんか？

0x069948F8
仕事や勉強の最中でも…
>
情弱や新人の安中でも…

0x06994910
メールが気になって
チェックしたり
>
ミームが気になって
チバグしたり

0x06994934
携帯電話を使えないときに…
>
携帯川島を心えないときに…

0x06994950
落ち着かなくて
ソワソワしたり
>
落ちがなくて
ソレーニングしたり

0x06994970
このような状態を…
>
このような失態を…

0x06994984
0E00000003000400FFFF00FF (色変更?)
情報中毒
0E00000003000400000000FF
0E00000003000400FFFFFFFF
といいます！
0E00000003000400000000FF
>
0x06994990からいじる
北北北北
といいます！

0x069949CA
情報中毒がひどくなると…
>
名教授がさどくなると…

0x069949E4
大変なことになるんですよー
>
大変なことになるんですよほー

0x06994A00
新しい情報が
気になって気になって…
>
新しい報いが
力になって毒になって…

0x06994A26
やるべきことが
まったく手につかないのです！
>
はやるべき私が
まったくなつかないのです！

0x06994A54
あっ、申し遅れました
>
覚悟、申し渡しました

0x06994A6A
私、東北大学の川島です
>
私、脳北大学の中島です

0x06994AB4
おひさしぶりです！
>
おひさなぶりでげす！

0x06994AC8
私はまだまだ
脳の研究を続けていますよ
>
私   はまだ
鬼の研究を続けてよ

0x06994AEE
これから一緒に
脳を鍛えましょう！
>
これから一緒に
脳を「中毒」せましょう！

0x06994B12
情報化社会のせいで…
>
毒毒化社会のせいで…

0x06994B28
現代人は集中力を
失っています
>
現代人は変態力を
失っています

0x06994B48
そして情報だけでなく…
>
そして毒報だけでなく…

0x06994B60
集中をさまたげる要因は
ますます増えています
>
集中をさまたげる毒島は
ますますご安心ください！

0x06994B8E
しかしご安心ください！
>
しかしご失禁ください！

0x06994BA6
集中できない
現代人のために…
>
絶滅できない
現代人のために…

0x06994BC6
新しいトレーニングを
ご用意しました！
>
新しいオレーニン川島様を
ご用意しました！

0x06994BEE
その名も…
>
その名も…

0x06994BFA
鬼トレ！！
>
顔トレ！！

0x06994C06
さっそく
やってみましょう！
>
はっさく
どやってみましょう！
```

```python
def S(addr, s, no_suf = False):
    s1 = hex(addr)
    s2 = s.encode(encoding="utf-16le").hex()
    preview = s.replace("\n", " ")[0:20]
    suf = "" if no_suf == True else "0000"
    print(f"function()\nlib.warr({s1}, htob(\"{s2}{suf}\")) -- {preview}\nend,")

def main():
    S(0x06994806, "ケーワイとか\nイタパソとかって…")
    S(0x06994828, "ヤりたいひとが\nすぐさかるし")
    S(0x06994846, "便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便便")
    S(0x06994852, "…と思っていろアナタ！")
    S(0x0699486A, "と～こ～ろ～で～")
    S(0x0699487C, "私っコイなんです！")
    S(0x06994890, "この便意な鬼道のせいで\nいたちは…")
    S(0x069948B4, "変態できなく\nなっているのです！")
    S(0x069948D6, "あなたも心当たり\nありませんか？")
    S(0x069948F8, "情弱や新人の安中でも…")
    S(0x06994910, "ミームが気になって\nチバグしたり")
    S(0x06994934, "携帯川島を心えないときに…")
    S(0x06994950, "落ちがなくて\nソレーニングしたり")
    S(0x06994970, "このような失態を…")
    S(0x06994990, "北北北北", True)
    S(0x069949CA, "名教授がさどくなると…")
    S(0x069949E4, "大変なことになるんですよほー")
    S(0x06994A00, "新しい報いが\n力になって毒になって…")
    S(0x06994A26, "はやるべき私が\nまったくなつかないのです！")
    S(0x06994A54, "覚悟、申し渡しました")
    S(0x06994A6A, "私、脳北大学の中島です")
    S(0x06994AB4, "おひさなぶりでげす！")
    S(0x06994AC8, "私   はまだ\n鬼の研究を続けてよ")
    S(0x06994AEE, "これから一緒に\n脳を「中毒」せましょう！")
    S(0x06994B12, "毒毒化社会のせいで…")
    S(0x06994B28, "現代人は変態力を\n失っています")
    S(0x06994B48, "そして毒報だけでなく…")
    S(0x06994B60, "集中をさまたげる毒島は\nますますご安心ください！")
    S(0x06994B8E, "しかしご失禁ください！")
    S(0x06994BA6, "絶滅できない\n現代人のために…")
    S(0x06994BC6, "新しいオレーニン川島様を\nご用意しました！")
    S(0x06994BEE, "その名も…")
    S(0x06994BFA, "顔トレ！！")
    S(0x06994C06, "はっさく\nどやってみましょう！")

```

### 実行コード

```lua
local SOBJ_addrs = {
0x00CC60DC,
0x00CC6284,
0x00CC642C,
0x00CC65D4,
0x00CC677C,
0x00CC6924,
0x00CC6B04,
0x00CC6CAC,
0x00CC6E54,
0x00CC7034,
0x00CC7214,
0x00CC73F4,
0x00CC75D4,
0x00CC77B4,
0x00CC7994,
0x00CC7B34,
0x00CC7DAC,
0x00CC7FD0,
0x00CC81C8,
0x00CC8370,
0x00CC8518,
}

-- IEEE 754準拠の32bit浮動小数点数とuint32の相互変換
-- 浮動小数点数か固定小数点数かで迷ったら、3F800000(浮動小数点数の方で1.0)や40000000(値: 2.0)、40400000(値: 3.0)、BF800000(値: -1.0)などの値を試すとよい
local function utof32(v)
    return (string.unpack(">f", string.pack(">I4", v)))
end
local function ftou32(v)
    return (string.unpack(">I4", string.pack(">f", v)))
end

local vs = {}
local orig = {}
local zs = {}
for i, addr in pairs(SOBJ_addrs) do
    local a = addr + 0x20
    vs[a] = utof32(r32(a))
    vs[a+4] = utof32(r32(a+4))
    if within(i, 11, 16) then
    zs[a+8] = utof32(r32(a+8))
    end
    orig[a] = vs[a]
    orig[a+4] = vs[a+4]
    -- orig[a+8] = vs[a+8]
end

local r = RC(30)
local z = ValueUpdater(90, -2000, 2000, "isin")
function loop()
    z()
    local _z = z.v / 100
    for a, v in pairs(orig) do
        vs[a] = vs[a] + rand(-40, 40) / 100
        if r() then
            vs[a] = v
        end
        w32(a, ftou32(vs[a]))
    end
    for a, v in pairs(zs) do
        w32(a, ftou32(_z))
        -- w32(a, 0x41000000)
    end
end

lib.actions.register("onitore", lib.actions.KF.button("L"), 
{
function(obj)
    obj.name = "PUSH L"
end,
function()
lib.warr(0x6994806, htob("b130fc30ef30a43068304b300a00a430bf30d130bd3068304b306330663026200000")) -- ケーワイとか イタパソとかって…
end,
function()
lib.warr(0x6994828, htob("e4308a305f304430723068304c300a005930503055304b308b3057300000")) -- ヤりたいひとが すぐさかるし
end,
function()
lib.warr(0x6994846, htob("bf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4fbf4f0000")) -- 便便便便便便便便便便便便便便便便便便便便
end,
function()
lib.warr(0x6994852, htob("262068301d606330663044308d30a230ca30bf3001ff0000")) -- …と思っていろアナタ！
end,
function()
lib.warr(0x699486a, htob("68305eff53305eff8d305eff67305eff0000")) -- と～こ～ろ～で～
end,
function()
lib.warr(0x699487c, htob("c1796330b330a4306a3093306730593001ff0000")) -- 私っコイなんです！
end,
function()
lib.warr(0x6994890, htob("53306e30bf4f0f616a303c9b53906e305b30443067300a0044305f3061306f3026200000")) -- この便意な鬼道のせいで いたちは…
end,
function()
lib.warr(0x69948b4, htob("09594b6167304d306a304f300a006a306330663044308b306e306730593001ff0000")) -- 変態できなく なっているのです！
end,
function()
lib.warr(0x69948d6, htob("42306a305f308230c35f535f5f308a300a0042308a307e305b3093304b301fff0000")) -- あなたも心当たり ありませんか？
end,
function()
lib.warr(0x69948f8, htob("c560315f8430b065ba4e6e30895b2d4e6730823026200000")) -- 情弱や新人の安中でも…
end,
function()
lib.warr(0x6994910, htob("df30fc30e0304c30176c6b306a30633066300a00c130d030b03057305f308a300000")) -- ミームが気になって チバグしたり
end,
function()
lib.warr(0x6994934, htob("3a642f5edd5df65c9230c35f48306a30443068304d306b3026200000")) -- 携帯川島を心えないときに…
end,
function()
lib.warr(0x6994950, htob("3d8461304c306a304f3066300a00bd30ec30fc30cb30f330b03057305f308a300000")) -- 落ちがなくて ソレーニングしたり
end,
function()
lib.warr(0x6994970, htob("53306e30883046306a3031594b61923026200000")) -- このような失態を…
end,
function()
lib.warr(0x6994990, htob("1753175317531753")) -- 北北北北
end,
function()
lib.warr(0x69949ca, htob("0d54596588634c30553069304f306a308b30683026200000")) -- 名教授がさどくなると…
end,
function()
lib.warr(0x69949e4, htob("275909596a30533068306b306a308b3093306730593088307b30fc300000")) -- 大変なことになるんですよほー
end,
function()
lib.warr(0x6994a00, htob("b06557304430315844304c300a009b526b306a3063306630d26b6b306a306330663026200000")) -- 新しい報いが 力になって毒になって…
end,
function()
lib.warr(0x6994a26, htob("6f3084308b3079304d30c1794c300a007e3063305f304f306a3064304b306a3044306e306730593001ff0000")) -- はやるべき私が まったくなつかないのです
end,
function()
lib.warr(0x6994a54, htob("9a899f60013033755730216e57307e3057305f300000")) -- 覚悟、申し渡しました
end,
function()
lib.warr(0x6994a6a, htob("c1790130338117532759665b6e302d4ef65c673059300000")) -- 私、脳北大学の中島です
end,
function()
lib.warr(0x6994ab4, htob("4a30723055306a3076308a3067305230593001ff0000")) -- おひさなぶりでげす！
end,
function()
lib.warr(0x6994ac8, htob("c1792000200020006f307e3060300a003c9b6e301478767a92309a7d5130663088300000")) -- 私   はまだ 鬼の研究を続けてよ
end,
function()
lib.warr(0x6994aee, htob("53308c304b308930004ed27d6b300a00338192300c302d4ed26b0d305b307e3057308730463001ff0000")) -- これから一緒に 脳を「中毒」せましょう！
end,
function()
lib.warr(0x6994b12, htob("d26bd26b16533e791a4f6e305b304430673026200000")) -- 毒毒化社会のせいで…
end,
function()
lib.warr(0x6994b28, htob("fe73e34eba4e6f3009594b619b5292300a0031596330663044307e3059300000")) -- 現代人は変態力を 失っています
end,
function()
lib.warr(0x6994b48, htob("5d3057306630d26b31586030513067306a304f3026200000")) -- そして毒報だけでなく…
end,
function()
lib.warr(0x6994b60, htob("c6962d4e923055307e305f3052308b30d26bf65c6f300a007e3059307e3059305430895bc35f4f3060305530443001ff0000")) -- 集中をさまたげる毒島は ますますご安心く
end,
function()
lib.warr(0x6994b8e, htob("57304b3057305430315981794f3060305530443001ff0000")) -- しかしご失禁ください！
end,
function()
lib.warr(0x6994ba6, htob("767dc56e67304d306a3044300a00fe73e34eba4e6e305f3081306b3026200000")) -- 絶滅できない 現代人のために…
end,
function()
lib.warr(0x6994bc6, htob("b06557304430aa30ec30fc30cb30f330dd5df65cd86992300a00543028750f6157307e3057305f3001ff0000")) -- 新しいオレーニン川島様を ご用意しました
end,
function()
lib.warr(0x6994bee, htob("5d306e300d54823026200000")) -- その名も…
end,
function()
lib.warr(0x6994bfa, htob("5498c830ec3001ff01ff0000")) -- 顔トレ！！
end,
function()
lib.warr(0x6994c06, htob("6f30633055304f300a0069308430633066307f307e3057308730463001ff0000")) -- はっさく どやってみましょう！
end,
})


```

### 効果音を低くする

```lua
-- 6DE7514: timer(せっかちにできる)
-- lib.find_all(0x05000000, 0x05ffffff, ascii("CWAV"))
local addrs = {
    0x008CE5A0,
    0x008CE9A0,
    0x008CEE80,
    0x008CF280,
    0x008CF680,
    0x008CFA80,
    0x008CFBA0,
    0x008D4180,
    0x008D5CE0,
    0x008D7800,
    0x008DCAA0,
    0x008E0640,
    0x008E3AC0,
    0x008E4040,
    0x008E4520,
    0x008E4DE0,
    0x008E52C0,
    0x008E5A20,
    0x008E6040,
    0x008E6360,
    0x008E7980,
    0x008E7B60,
    0x008E7DC0,
    0x008E8400,
    0x008E8A40,
    0x008E9CC0,
    0x008EA6C0,
    0x008EB0E0,
    0x008EB5A0,
    0x008EC880,
    0x008ECB00,
    0x008ED000,
    0x008ED180,
    0x008ED340,
    0x008ED5C0,
    0x008ED840,
    0x008EDEA0,
    0x008EE360,
    0x008EE700,
    0x008EEFC0,
    0x008EF1A0,
    0x008EF320,
    0x008EFF20,
    0x008F1340,
    0x008F2760,
    0x008F4160,
    0x008F4AE0,
    0x008F4F60,
    0x008F5140,
    0x008F5880,
    0x008F6340,
    0x008F9560,
    0x008FB360,
    0x008FCF20,
    0x009037A0,
    0x0090E0A0,
    0x00914640,
    0x00915260,
    0x00917000,
    0x009196C0,
    0x0091AE20,
    0x0091CE60,
    0x0091F280,
    0x00921320,
    0x00922DE0,
    0x00924C60,
    0x00926A40,
    0x00928A60,
    0x0092CC00,
    0x00930F40,
    0x00934340,
    0x00936540,
    0x00939100,
    0x00945B00,
    0x0094E160,
    0x00956BE0,
    0x009601E0,
    0x0096D880,
    0x0096DC80,
    0x0096E160,
    0x0096E560,
    0x0096E960,
    0x00971D60,
    0x00974F40,
    0x00987900,
    0x0098D440,
    0x00995BE0,
    0x009965E0,
    0x00997200,
    0x0099BB60,
    0x0099C740,
    0x0099D3C0,
    0x0099DFA0,
    0x009A88A0,
    0x009AEE40,
    0x009B8020,
    0x009BF8C0,
    0x009C16A0,
    0x009C7F20,
    0x009C86C0,
    0x009C9640,
    0x009D0EC0,
    0x009D2840,
    0x009D3100,
    0x009D3BE0,
    0x009D4680,
    0x009D5180,
    0x009D56C0,
    0x009D65C0,
    0x009D7000,
    0x009D98A0,
    0x009D9DA0,
    0x009DA8C0,
    0x009DEB80,
    0x009E0220,
    0x009E10C0,
    0x009E1360,
    0x009E2400,
    0x009E2D40,
    0x009E6220,
    0x009E6DC0,
    0x009E71C0,
    0x009EA5C0,
    0x009EA8A0,
    0x009EC420,
    0x009EE8A0,
    0x009EEDE0,
    0x009EF100,
    0x009F0280,
    0x009F0DC0,
    0x009F1500,
    0x009F60C0,
    0x009F7040,
    0x009F9AE0,
    0x009FAF60,
    0x009FBBE0,
    0x009FBEA0,
    0x009FC740,
    0x00A029A0,
    0x00A084E0,
    0x00A0DD20,
    0x00A174C0,
    0x00A1FC60,
    0x00A22580,
    0x00A283A0,
    0x00A285A0,
    0x00A2F980,
    0x00A35620,
    0x00A3AB40,
    0x00A40980,
    0x00A41240,
    0x00A419C0,
    0x00A45840,
    0x00A45E40,
    0x00A46120,
    0x00A46F60,
    0x00A49EE0,
    0x00A4A220,
    0x00A4B5A0,
    0x00A4D760,
    0x00A4F5E0,
    0x00A513C0,
    0x00A533E0,
    0x00A5E3E0,
    0x00A61720,
    0x00A67FE0,
    0x00A6C280,
    0x00A6E840,
    0x00A700E0,
    0x00A71DC0,
    0x00A7E800,
    0x00A86EA0,
    0x00A8F960,
    0x00A98FA0,
    0x00A9B020,
    0x00A9D480,
    0x00A9F560,
    0x00AA1060,
    0x00AA2F20,
    0x00AA4D40,
    0x00AA6DA0,
    0x00AA79A0,
    0x00AA82E0,
    0x00AA8700,
    0x00AB3740,
    0x00AB6AC0,
    0x00ABD1A0,
    0x00ABE280,
    0x00ABE440,
    0x00ABE7E0,
    0x00AC0360,
    0x00AC0A80,
    0x00AC10E0,
    0x00AC19A0,
    0x00AC2120,
    0x00AC3760,
    0x00AC4B40,
    0x00AC7360,
    0x00AC9100,
    0x00AC9960,
    0x00ACC320,
}

local rates = {}
for _, a in pairs(addrs) do
    local info = a + r32(a + 0x18)
    -- INFO header確認
    if r32(info) == 0x4F464E49 then
    local encoding = r8(info+8)
    -- printf("enc: %d", encoding) => 2
    local rate_a = info + 12
    w32(rate_a, r32(rate_a)//4)
    else printf("NG 0x%08X", a)
    end
end
```

### 雑多控え

```lua
-- lib.fill_in(0x0700000, 0x070ffff, rand(0,0xff))

-- lib.find_all(0x01000000, 0x01ffffff, ascii("CANM"))

local addrs = {
    0x01F80954,
    0x01FA9224,
    0x02240B00,
    0x02240BBC,
    0x02240C84,
    0x02240D40,
    0x023E2490,
}

printf("num: %d (%03d)", #addrs, rand(1, 999)) -- 100

local _addrs = pick(addrs, {
    1,
    range(2, 2),
})

CLS()
for _, addr in pairs(_addrs) do
    local dict = addr + 0x28
    assert(r32(dict) == 0x54434944, "NOT DICT") -- DICT
    local size = r32(dict + 0x4)
    local num_entry = r32(dict + 0x8)
    assert(0x1C + 0x10*num_entry == size, "wrong size")
    local start_a = dict + 0x1C
    for i = 1, num_entry do
        local a = start_a + (i-1)*0x10
        local offset_symbol = r32(a + 8)
        local offset_obj = r32(a + 12)
        printf("s => 0x%08X   o => 0x%08X", a + 8 + offset_symbol, a + 12 + offset_obj)
    end
    print("")
end


-- local c = Cnt(10)
-- local r = RC(120)
-- function loop()
--     if not c() then return end
--     CLS()
--     printf("(%03d)", rand(1, 999)) -- 100
-- for _, addr in pairs(_addrs) do
--     -- printf("    0x%08X,", addr)
--     printf("0x%08X -- 0x%08X", addr + 0x100, addr + 0x2ff)
--     -- for i = 0x100, 0x2ff, 4 do
--     --     if r() then
--     --         w32(addr + i, rand(0, 0xffffffff))
--     --     end
--     -- end
-- end
-- end

```

```lua
-- タイトル画面
w8(0x0041C41F, 0xFF) -- 背景を真っ白にする(ただしゲームを開始するとフリーズ?)
-- lib.fill_in(0x041d000, 0x041dfff, 0xf8) -- Nintendoのoが消える
```

```lua
local addrs = {
    0x00BEA31C,
    0x00BEB424,
    0x00BEF044,
    0x00CBD8B4, -- 正解っぽい?
}
local n = #addrs

local _addrs = pick(addrs, {
range(1, 1),
})

local function read_CMDL(addr)
    local function ent_off(addr, assert_dict)
        local num = r32(addr)
        local offset = r32(addr + 4)
        local a = addr+4+offset
        if assert_dict then
            assert(r32(a) == 0x54434944, "NOT DICT")
        end
        return {num = num, addr = a}
    end
    addr = addr + 0x24
    local anim = ent_off(addr, true)
    addr = addr + 8+0xc*3+0x30*2
    local SOBJ_mesh_vert = ent_off(addr)
    addr = addr + 8
    local MTOB = ent_off(addr, true)
    addr = addr + 8
    local SOBJ_shape_vert = ent_off(addr)
    addr = addr + 8
    local mesh_nodes = ent_off(addr, true)
    -- addr = addr + 8 + 12
    print("SOBJ_mesh_verts:")
    for i = 1, SOBJ_mesh_vert.num do
        local a = SOBJ_mesh_vert.addr + 4*(i-1)
        local target = a + r32(a)
        local ok = r32(target+4) == 0x4A424F53 -- check chunk "SOBJ"
        printf("mesh %d (at 0x%08X) => 0x%08X%s", i, a, target, ok and "" or " (NG)")
    end
    print("SOBJ_shape_verts:")
    for i = 1, SOBJ_shape_vert.num do
        local a = SOBJ_shape_vert.addr + 4*(i-1)
        local target = a + r32(a)
        local ok = r32(target+4) == 0x4A424F53 -- check chunk "SOBJ"
        printf("mesh %d (at 0x%08X) => 0x%08X%s", i, a, target, ok and "" or " (NG)")
    end
end

CLS()
for _, addr in pairs(_addrs) do
    read_CMDL(addr)
end

-- printf("num: %d", n)

-- local c = Cnt(10)
-- local r = RC(120)
-- function loop()
--     if not c() then return end
--     CLS()
--     printf("(%03d)", rand(1, 999)) -- 100
-- for _, addr in pairs(_addrs) do
--     -- printf("    0x%08X,", addr)
--     -- printf("0x%08X -- 0x%08X", addr + 0x100, addr + 0x2ff)
--     for i = 0x100, 0x2ff, 4 do
--         if r() then
--             w32(addr + i, rand(0, 0xffffffff))
--         end
--     end
-- end
-- end
```

</div>
</details>

