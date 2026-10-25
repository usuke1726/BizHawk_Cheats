
import sys
from pathlib import Path
import jaconv
import re

sys.dont_write_bytecode = True
args = sys.argv

ANNOTATION_LENGTH = 15
SEP_CHAR = len(args) >= 2 and args[1] == "sep"

convert_table = {
}

basedir = Path(__file__, "..")
infile_def = basedir / ".to_byte.txt"
outfile_def = basedir / ".out.txt"

special_chars = {
    "ー": "815b",
    "・": "8145",
    "　": "8140",
    "「": "8175",
    "」": "8176",
    "）": "816a",
    "、": "8141",
    "。": "8142",
    "？": "8148",
    "！": "8149",
}
kata = re.compile('[ァ-ヶ]')
def read(mes):
    ret = []
    is_katakana = False
    is_color_mode = False
    is_special_char = False
    for s in mes:
        is_katakana = False
        r = ""
        for c in s:
            if is_special_char:
                is_special_char = False
                if c == "C" or c == "c":
                    is_color_mode = True
                else:
                    raise ValueError(f"Unknown Special char \"{c}\"")
                continue
            if is_color_mode:
                assert re.fullmatch(r"[0-9a-fA-F]", c), f"wrong color value: \"{c}\""
                is_color_mode = False
                r += f"1b433{c}"
                continue
            if kata.search(c):
                if not is_katakana:
                    is_katakana = True
                    r += "1b4b"
            elif is_katakana:
                is_katakana = False
                r += "1b48"
            if c == "\\":
                is_special_char = True
                continue
            if c in special_chars:
                r += special_chars[c]
            else:
                enc = jaconv.z2h(jaconv.hira2kata(c), kana=True, digit=True, ascii=True).encode(encoding="sjis")
                r += "".join([f"{_c:02x}" for _c in enc])
        ret.append(r)
    return "0a".join(ret)

def to_data(addr, mes, is_rom):
    r = read(mes)
    annotation = " ".join(mes)
    suf = annotation[0:ANNOTATION_LENGTH].replace("\n", " ")
    if len(annotation) > ANNOTATION_LENGTH:
        annotation = f"{suf}..."
    else:
        annotation = f"{suf}"
    annotation = f" -- {annotation}"
    if is_rom:
        r = f"function()\nlib.romwarr({addr}, htob({annotation}\n\"{r}050505\"\n))\nend,"
    else:
        r = f"function()\nlib.warr({addr}, htob({annotation}\n\"{r}050505\"\n))\nend,"
    return r

def main(infile = infile_def, outfile = outfile_def):
    empty = True
    addr = ""
    data = []
    addr_given = False
    is_rom = False
    mes = []

    with open(infile, "r", encoding="utf-8") as _f:
        for line in _f:
            l = line.strip(" ").replace("\r", "").replace("\n", "")
            if l == "#END":
                break
            if l == "#ROM":
                is_rom = True
                continue
            if empty and l.startswith("0x"):
                addr = l.split(":")[0].strip()
                addr_given = True
                empty = False
                continue
            if len(l) > 0:
                mes.append(l)
                empty = False
            else:
                if (not empty):
                    assert(addr_given)
                    data.append(to_data(addr, mes, is_rom))
                    is_rom = False
                mes = []
                addr = ""
                addr_given = False
                empty = True
        if (not empty):
            assert(addr_given)
            data.append(to_data(addr, mes, is_rom))

    with open(outfile, "w", encoding="utf8") as _f:
        print("\n".join(data), file = _f)

if __name__ == "__main__":
    main()

