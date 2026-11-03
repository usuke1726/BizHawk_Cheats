
from pathlib import Path
import sys
sys.path.append(str(Path(__file__, "../").resolve()))
sys.path.append(str(Path(__file__, "../lib/").resolve()))
import argparse
import os
import cricodecs

parser = argparse.ArgumentParser(prog="ahxconv")

parser.add_argument("in/out", nargs="*", help="-i/-o で指定しない場合、第1引数をin、第2引数をoutとして解釈する (第3引数以降は無視)")
parser.add_argument("-i", "--input", type = str)
parser.add_argument("-o", "--output", type = str)

args = parser.parse_intermixed_args()

def ERR(mes):
    print(f"エラー：{mes}")
    exit(1)

in_arg = args.input
out_arg = args.output
in_out_arg = args.__getattribute__("in/out")
if in_out_arg:
    l = len(in_out_arg)
    if l >= 1:
        if not args.input:
            in_arg = in_out_arg.pop(0)
        elif not args.output:
            out_arg = in_out_arg.pop(0)
    if l >= 2:
        if not args.input and not args.output:
            out_arg = in_out_arg.pop(0)

if not in_arg and not out_arg:
    ERR(f"入力ファイルと出力ファイルを指定してください\n\n{parser.format_help()}")
elif not in_arg:
    ERR(f"入力ファイルを指定してください\n\n{parser.format_help()}")
elif not out_arg:
    ERR(f"出力ファイルを指定してください\n\n{parser.format_help()}")

CWD = os.getcwd()

in_file = Path(CWD, in_arg).resolve()
out_file = Path(CWD, out_arg).resolve()
tmp_file = Path(__file__, "../_tmp.wav").resolve()
tmp2_file = Path(__file__, "../_tmp2.wav").resolve()
print(" in: ", in_file)
print("out: ", out_file)

if not in_file.is_file():
    ERR(f"ファイル {in_file} が見つかりません")

in_ext = in_file.suffix.lower()
out_ext = out_file.suffix.lower()
is_adx = False
if in_ext == ".wav":
    # encoding (wav => ahx/adx)
    if out_ext == ".ahx":
        pass
    elif out_ext == ".adx":
        is_adx = True
    else:
        ERR(f"出力ファイルの拡張子は ahxかadx でないといけません ({out_ext})")
    if is_adx:
        conf = cricodecs.adx.AdxEncodeConfig()
        out_bytes = cricodecs.adx.encode(in_file.read_bytes(), conf)
        out_file.write_bytes(out_bytes)
    else:
        conf = cricodecs.ahx.AhxEncodeConfig()
        conf.encoding_mode = 0x11
        out_bytes = cricodecs.ahx.encode(in_file.read_bytes(), conf)
        out_file.write_bytes(out_bytes)
else:
    # decoding (ahx/adx => wav)
    if in_ext == ".ahx":
        pass
    elif in_ext == ".adx":
        is_adx = True
    else:
        ERR(f"不正な入力ファイル拡張子: {in_ext}")
    if is_adx:
        out_file.write_bytes(cricodecs.adx.decode(in_file))
    else:
        out_file.write_bytes(cricodecs.ahx.decode(in_file))

print("Done.")
