

## 音声加工の方法

1. ahxファイルをwavファイルに変換
    ```powershell
    ahxfilter dec -i ./some_audio.ahx -o ./some_audio.wav
    ```
    - 大まかな `ahxfilter` の処理は以下の通り:
        ```python
        from pathlib import Path
        import cricodecs

        # デコード(ahx => wav)の場合
        out_file.write_bytes(cricodecs.ahx.decode(in_file))
        # エンコード(wav => ahx)の場合
        conf = cricodecs.ahx.AhxEncodeConfig()
        conf.encoding_mode = 0x11
        out_bytes = cricodecs.ahx.encode(in_file.read_bytes(), conf)
        out_file.write_bytes(out_bytes)
        ```
2. Audacityでwavファイルを加工し、別のwavファイル(ここでは`out.wav`)に書き出し
    - サンプルレートは `24546Hz` で！！
    - エンコーディングは規定のまま Signed 16-bit PCMでOK
3. wavファイルをahxに変換
    ```powershell
    ahxfilter enc -i ./out.wav -o ./out.ahx
    ```

### まるごとデコード

```powershell
# fab_voices ディレクトリにて
01..14 | %{"{0:D2}" -f $_} | %{ahxfilter dec -i "./i$_.ahx" -o "./wavs/i$_.wav"}
```

### まるごとエンコード

```powershell
# video** ディレクトリにて
01..14 | %{"{0:D2}" -f $_} | %{ahxfilter enc -i "./o$_.wav" -o "./o$_.ahx"}
```
