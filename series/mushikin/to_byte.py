
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

def _convert(s):
    for bef, aft in convert_table.items():
        s = s.replace(bef, aft)
    return s

def _encode(s):
    if not SEP_CHAR:
        return s.encode(encoding="sjis").hex()
    enc = [c.encode(encoding="sjis") for c in s]
    return " ".join(["".join([f"{c:02x}" for c in b]) for b in enc])

def _to_code(s, voice_mode, annotation):
    if voice_mode:
        s = s + "\n＋＋"
    try:
        ps = _encode(_convert(s)).upper()
        v_suf = "[V]" if voice_mode else ""
        if len(annotation) == 0:
            annotation = s
        suf = annotation[0:ANNOTATION_LENGTH].replace("\n", " ")
        if len(annotation) > ANNOTATION_LENGTH:
            annotation = f"{v_suf}{suf}..."
        else:
            annotation = f"{v_suf}{suf}"
        annotation = f" -- {annotation}"
        final_s = f"{annotation}\n\"{ps}\""
        return final_s
    except Exception as e:
        print(f"FAILED encoding (c: {c}, s: {s})")
        raise e

def _format_mes_default(s):
    """
    Returns:
        string formatted_text
        string? annotation
    """
    return s

def _to_full_text(addr, mes, voice_mode, format_mes):
    body = format_mes("\n".join(mes))
    if type(body) is tuple:
        text = body[0]
        annotation = body[1]
    else:
        text = body
        annotation = ""
    code = _to_code(text, voice_mode, annotation)
    t = f"{code}\n"
    return f"wr({addr},{t})"

basedir = Path(__file__, "..")
infile_def = basedir / ".to_byte.txt"
outfile_def = basedir / ".out.txt"

def main(infile = infile_def, outfile = outfile_def, f = _format_mes_default):
    empty = True
    addr = ""
    mes = []
    full_text = []
    voice_mode = False

    with open(infile, "r", encoding="utf-8") as _f:
        for line in _f:
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
                    full_text.append(_to_full_text(addr, mes, voice_mode, f))
                addr = ""
                mes = []
                empty = True
                voice_mode = False
        if (not empty):
            full_text.append(_to_full_text(addr, mes, voice_mode, f))

    # print("\n".join(full_text))
    with open(outfile, "w", encoding="utf8") as _f:
        print("\n".join(full_text), file = _f)

if __name__ == "__main__":
    main()
