
import sys
from pathlib import Path
sys.dont_write_bytecode = True
args = sys.argv

ANNOTATION_LENGTH = 15
SEP_CHAR = len(args) >= 2 and args[1] == "sep"

convert_table = {
    "/": "／",
    "'": "’",
    "_": "＿",
    "|": "｜",
    "～": "〜",
    "0": "０", "1": "１", "2": "２", "3": "３", "4": "４", "5": "５", "6": "６", "7": "７", "8": "８", "9": "９",
}

def convert(s):
    for bef, aft in convert_table.items():
        s = s.replace(bef, aft)
    return s

def encode(s):
    if not SEP_CHAR:
        return s.encode(encoding="sjis").hex()
    enc = [c.encode(encoding="sjis") for c in s]
    return " ".join(["".join([f"{c:02x}" for c in b]) for b in enc])

def main(s, voice_mode):
    if voice_mode:
        s = s + "\n＋＋"
    try:
        ps = encode(convert(s)).upper()
        v_suf = "[V]" if voice_mode else ""
        suf = s[0:ANNOTATION_LENGTH].replace("\n", " ")
        if len(s) > ANNOTATION_LENGTH:
            annotation = f"{v_suf}{suf}..."
        else:
            annotation = f"{v_suf}{suf}"

        annotation = f" -- {annotation}"
        final_s = f"{annotation}\n\"{ps}\""
        return final_s
    except Exception as e:
        print(f"FAILED encoding (c: {c}, s: {s})")
        raise e
    
def to_full_text(addr, mes, voice_mode):
    code = main("\n".join(mes), voice_mode)
    t = f"{code}\n"
    return f"wr({addr},{t})"

empty = True
addr = ""
mes = []
full_text = []
voice_mode = False

basedir = Path(__file__, "..")
infile = basedir / ".to_byte.txt"
outfile = basedir / ".out.txt"

with open(infile, "r", encoding="utf-8") as f:
    for line in f:
        l = line.strip(" ").replace("\r", "").replace("\n", "")
        if l == "#END":
            break
        if l == "#V":
            voice_mode = True
            continue
        if empty and l.startswith("0x"):
            addr = l.split(":")[0].strip()
            empty = False
            continue
        if len(l) > 0:
            mes.append(l)
            empty = False
        else:
            if (not empty):
                full_text.append(to_full_text(addr, mes, voice_mode))
            addr = ""
            mes = []
            empty = True
            voice_mode = False
    if (not empty):
        full_text.append(to_full_text(addr, mes, voice_mode))

# print("\n".join(full_text))
with open(outfile, "w", encoding="utf8") as f:
    print("\n".join(full_text), file = f)

