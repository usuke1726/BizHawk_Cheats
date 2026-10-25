
from pathlib import Path
import sys
sys.path.append(str(Path(__file__, "../").resolve()))
sys.path.append(str(Path(__file__, "../lib/").resolve()))
import argparse
import os
import cricodecs
import soundfile as sf
from filtering import do_filter

parser = argparse.ArgumentParser(prog="ahxfilter")

parser.add_argument("command", choices = ["dec", "enc", "filter"])
parser.add_argument("-i", "--input", type = str, required = True)
parser.add_argument("-o", "--output", type = str, required = True)

args = parser.parse_args()

CWD = os.getcwd()

in_file = Path(CWD, args.input).resolve()
out_file = Path(CWD, args.output).resolve()
tmp_file = Path(__file__, "../_tmp.wav").resolve()
tmp2_file = Path(__file__, "../_tmp2.wav").resolve()
print("com: ", args.command)
print(" in: ", in_file)
print("out: ", out_file)

if not in_file.is_file():
    raise ValueError(f"ファイル {in_file} が見つかりません")

if args.command == "dec":
    out_file.write_bytes(cricodecs.ahx.decode(in_file))
    exit(0)
elif args.command == "enc":
    conf = cricodecs.ahx.AhxEncodeConfig()
    conf.encoding_mode = 0x11
    out_bytes = cricodecs.ahx.encode(in_file.read_bytes(), conf)
    out_file.write_bytes(out_bytes)
    exit(0)
elif args.command != "filter":
    raise ValueError(f"不正なコマンド: {args.command}")


tmp_file.write_bytes(cricodecs.ahx.decode(in_file))

audio, sr = sf.read(tmp_file, dtype = "float32")
original_length = len(audio)

result = do_filter(audio, sr, original_length)

assert len(result) == original_length

# 元のサンプリングレートでWAVに保存
sf.write(tmp2_file, result, sr, subtype="PCM_16")

print(f"Sample rate: {sr}")
print(f"Duration: {original_length / sr:.6f} sec")
# print(f"Pitch shift: {PITCH_SEMITONES:+.1f} semitones")

conf = cricodecs.ahx.AhxEncodeConfig()
conf.encoding_mode = 0x11
out_bytes = cricodecs.ahx.encode(tmp2_file.read_bytes(), conf)
out_file.write_bytes(out_bytes)

