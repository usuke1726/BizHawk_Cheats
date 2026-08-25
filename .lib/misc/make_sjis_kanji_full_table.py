
from pathlib import Path

p = Path(__file__, "../_sjis_kanji_full_table.lua")

with open(p, "w", encoding="utf-8") as f:
    f.write("\nlocal TABLE = {\n")
    for a in range(8, 0x19):
        b = 0x8000 + (a << 8)
        for c in range(0x40, 0xFF):
            addr = b + c
            if addr > 0x9875:
                break
            try:
                c = addr.to_bytes(2, "big").decode(encoding="sjis")
                f.write(f"[{hex(addr)}] = \"{c}\",\n")
            except:
                pass
    f.write("}\n\nreturn TABLE\n")
