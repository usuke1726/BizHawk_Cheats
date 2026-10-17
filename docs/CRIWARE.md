
# CRIWARE

## 使われている所

- FabStyle ボイス再生

## 雑メモ

- FabStyleの「あたし英語ダメなの」のボイスは、ROMの`0x08354600`に生データとして配置されている
    - どうやら、再生する直前にROMから直接データをとってきているようである。実際、再生する前にROMを書き換えたら音声がバグる
    - 単純に、`0x0212F3C0`を監視して、ボイスを再生する直前に現れる`80 00`から始まるデータを丸コピ、このデータでROM検索すれば良い
        - 例:
        ```lua
        local d = htob("800000201100000100005FE20001B8330000060000000000000000000000286329435249FFF5E0C066669180080000000001801653267851ACDA572E584F9E55718D9AE76BDEF7BDEF7BDEF7BBBBBBAD8D7BDEF839EF6BDEF7777775B1B0986EBDB02E5C28CFACF918A8A30B56C91B29") -- => found at 0x08354600
        for i = 5, 0x9 do
            local a = 0x01000000*i
            if lib.findr(a, a+0x00ffffff, d) then break end
        end
        ```
    - オーディオデータは、どうやらROM内の`0x05000000`くらいからあるみたい
    - sample rateはちょうど半分だったり、3の倍数なら2/3倍なら可能、大きくしたり小さくしすぎるとフリーズ
- fabstyleのデータは、MPEG-2 LSF Layer II CRC保護なし(先頭2バイトが`FF F5`なのがLayer IIの典型例。AHXのデータはMPEGそのもの。)
    - この部分の4バイト(上のボイス例だと`FF F5 E0 C0`)はMPEGとしてのヘッダらしい。
        - https://www.datavoyage.com/mpgscript/mpeghdr.htm
    - データを音声ファイルとして調査・加工したい！→vgmstreamを使う(ffmpegはフォーマット未対応)
        - https://vgmstream.org/
        - バイト列をダンプしてからwavに変換: `vgmstream -o out.wav .\in.ahx`
            - ただし逆のencodingはできない。あくまでdecode(ahx->wav)のみ。
            ```lua
            -- ダンプコードの例
            -- lib.findr(0x08354624, 0x08ffffff, ascii("CRI")) -- iendの場所を探す
            local begin = 0x08354600
            local iend = 0x0835DB6F
            local f = io.open(lib.path.output("_voice_tmp2.ahx"), "wb")
            f:write(longchars(lib.romrarr(begin, iend))) f:close()
            ```
    - あるいは https://github.com/Youjose/CriCodecs (pythonライブラリ)
        - https://github.com/Youjose/CriCodecs/blob/main/USAGE.md こっちならAHXへのencodingも可能?


## ピッチシフトを行うアイデア(GPT)


<details open>
<summary>GPT</summary>
<div>

今回の条件では、AHXファイルをPCMにデコードし、指定区間だけ時間長を維持したピッチシフトを行い、AHXに再エンコードしてバイト列を再構築する方式を提案します。

重要なのは、単にAHXのバイト列の一部を書き換えるのではなく、最終的に再生可能なAHXファイルを作り直すことです。元のAHXのヘッダーやフレーム構造、ループ情報などを維持できるかどうかは、使用されているAHXの仕様とエンコーダーに依存します。

## 推奨する処理パイプライン

1. AHXファイルを解析

ヘッダー・フレーム境界・サンプル数・ループ情報を確認

2. AHXデコーダーでPCM化

ステレオ／モノラルとサンプリングレートを保持

3. 区間指定ピッチシフト

時間長を維持し、境界にクロスフェードを適用

4. AHXエンコーダーで再圧縮

音声フレームと必要なメタデータを生成

5. 出力AHXを検証

再デコードし、再生時間・音程・ループを確認

## 1. 使用するツール

実装環境が「その他」とのことなので、特定の言語に依存しにくいコマンドラインツールを中心に組み立てます。

候補は [CriCodecs](<https://github.com/Youjose/CriCodecs>) です。AHXのデコードとエンコードに対応しており、CLIとPython APIを提供しています。エンコード時にはモードやプロファイルを指定できます。

処理を次の3つに分離します。

- AHXのデコード・エンコード：CriCodecs
- ピッチシフト：librosa
- PCMデータの読み書き：SoundFile

まずはPythonで試作し、必要ならC++などに移植するのが現実的です。

## 2. セットアップ

Pythonが利用できる環境で、次を実行します。

bash
```
python -m pip install cricodecs librosa soundfile numpy
```

CriCodecsのCLIがインストールされていることを確認します。

bash
```
cricodecs --help
```

また、入力ファイルを単独でデコードできることを確認します。

bash
```
cricodecs input.ahx -o decoded.wav
```

この段階でデコードできなければ、暗号化やファイル形式の判定などを先に解決する必要があります。

## 3. ピッチ変更の実装例

以下は、指定した区間を半音単位でピッチ変更し、音声全体の長さと対象区間の長さを維持するためのPython実装例です。

例では2〜3秒の区間を2半音上げます。境界には20ミリ秒のクロスフェードを入れます。

python
```

from pathlib import Path
import subprocess

import librosa
import numpy as np
import soundfile as sf

INPUT_AHX = Path("input.ahx")
DECODED_WAV = Path("decoded.wav")
EDITED_WAV = Path("edited.wav")
OUTPUT_AHX = Path("output.ahx")

START_SEC = 2.0
END_SEC = 3.0
PITCH_SEMITONES = 2.0
CROSSFADE_SEC = 0.020

# 元のAHXをWAVにデコード
subprocess.run(
    ["cricodecs", str(INPUT_AHX), "-o", str(DECODED_WAV)],
    check=True,
)

# PCMを読み込む。shapeは (samples,) または
# (samples, channels)
audio, sr = sf.read(DECODED_WAV, dtype="float32")
original_length = len(audio)

start = round(START_SEC * sr)
end = round(END_SEC * sr)

if not (0 <= start < end <= original_length):
    raise ValueError("指定区間が音声の範囲外です")

# 対象区間だけピッチシフトする。
# librosaは通常、入力の長さと同じ長さの結果を返す。
segment = audio[start:end]
shifted = librosa.effects.pitch_shift(
    y=segment.T if audio.ndim == 2 else segment,
    sr=sr,
    n_steps=PITCH_SEMITONES,
)

if audio.ndim == 2:
    shifted = shifted.T

if len(shifted) != len(segment):
    raise RuntimeError("ピッチシフト後の長さが一致しません")

# 対象区間を置き換える
result = audio.copy()
result[start:end] = shifted

# 境界をクロスフェードしてクリックノイズを軽減
fade = min(round(CROSSFADE_SEC * sr), len(segment) // 2)

if fade > 0:
    ramp = np.linspace(0.0, 1.0, fade, dtype=np.float32)
    shape = (fade, 1) if audio.ndim == 2 else (fade,)

    ramp = ramp.reshape(shape)

    # 区間の先頭：元音声から加工音声へ
    result[start:start + fade] = (
        audio[start:start + fade] * (1.0 - ramp)
        + shifted[:fade] * ramp
    )

    # 区間の末尾：加工音声から元音声へ
    result[end - fade:end] = (
        shifted[-fade:] * (1.0 - ramp)
        + audio[end - fade:end] * ramp
    )

assert len(result) == original_length

# 元のサンプリングレートでWAVに保存
sf.write(EDITED_WAV, result, sr, subtype="PCM_16")

print(f"Sample rate: {sr}")
print(f"Duration: {original_length / sr:.6f} sec")
print(f"Pitch shift: {PITCH_SEMITONES:+.1f} semitones")

# AHXに再エンコード
# mode/profileは元ファイルに合わせて調整すること
subprocess.run(
    [
        "cricodecs", "--encode", "-f", "ahx",
        str(EDITED_WAV), "-o", str(OUTPUT_AHX),
        "--mode", "0x11",
        "--profile", str(sr),
    ],
    check=True,
)

print(f"Output: {OUTPUT_AHX}")
```

このコードは処理の骨格を示したものです。CriCodecsのバージョンによってCLIオプションやAHXプロファイルの受け付け方が異なる可能性があるため、実際の環境で `cricodecs --help` を確認してください。特に、`--profile` に元のサンプリングレートをそのまま指定できるかは、使用するビルドで検証が必要です。

また、librosaのピッチシフトは音声区間の長さを維持しますが、音質が完全に元のままというわけではありません。

## 4. 再エンコード時に注意する点

ここが今回の実装で最も重要です。

### AHXのモードとプロファイル

CriCodecsのドキュメントでは、AHXエンコードにモード `0x10` と `0x11`、および組み込みの割り当てプロファイルがあるとされています。したがって、例にある `--mode 0x11 --profile ...` は、入力ファイルの設定を確認したうえで調整してください。サンプリングレートとプロファイルは必ずしも同じ概念ではありません。

### 元のAHXとの互換性

再エンコードしたファイルが正常にデコードできても、元の再生環境で必ず再生できるとは限りません。特に、次の項目を確認してください。

- 元ファイルのAHXモードとエンコード設定
- サンプリングレートとチャンネル数
- ヘッダーに記録されるサンプル数
- ループ開始位置・終了位置
- 暗号化やゲーム固有の再生条件

元のファイルがループ再生用なら、ループ位置の情報も再構築する必要があります。再エンコードによってサンプル数やフレーム構造が変わる場合、元のバイト列からヘッダーだけをコピーする方法は安全ではありません。

## 5. 出力ファイルの検証

処理後は、最低限、次の検証を行ってください。

1. `output.ahx` を再度WAVにデコードできること。
2. 再デコード後の音声全体の長さが元音声と一致すること。
3. 指定区間の音程が変わり、その前後の音程がほぼ維持されていること。
4. ファイルの先頭・末尾やループ境界にノイズが発生していないこと。
5. 実際のゲームや再生環境で正常に再生できること。

なお、WAV段階で元のサンプル数を維持することと、AHX再エンコード後に同一のサンプル数・再生時間を実現することは別問題です。エンコーダーがフレーム単位でパディングする場合は、追加の調整が必要になります。

## 6. 実用上のおすすめ

今回の目的なら、まずはCriCodecsでAHXをデコード・再エンコードできるかを確認し、上記の処理を小さなテストファイルで検証するのがよいです。

特に、元のAHXと同じ形式・設定で出力する必要があるのか、それともAHXとして再生できればよいのかによって、実装の難易度が大きく変わります。元のゲームとの完全な互換性が必要なら、使用しているAHXのバージョンやモードを特定したうえで、エンコーダーの出力形式まで検証する必要があります。

</div>
</details>

→結局、「WAVにdecode→audacityで加工→書き出したwavをahxにencode」が一番安定した方法だった。video19ではその方法を採用。


## 参考サイト

- ADX/AHXのformat
    - https://wiki.multimedia.cx/index.php/CRI_ADX_file
    - https://encyclopedia.pub/entry/28003


