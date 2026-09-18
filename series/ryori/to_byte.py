
import sys
sys.dont_write_bytecode = True
from pathlib import Path
import re
sys.path.append(str(Path(__file__, "../..").resolve()))
from mushikin.to_byte import main

table = {
"<C:B>": "\x1a\x07\x00\x00\x00\x00\x01",
"<C:G>": "\x1a\x07\x00\x00\x00\x00\x02",
"<C:R>": "\x1a\x07\x00\x00\x00\x00\x03",
"<LF>": "\x1a\x05\x10\x00\x01",
}

def form_com(m):
    s = m.group(1)
    l = len(s)
    assert(l % 2 == 0)
    pre = "\x1a" + chr(l//2 + 2)
    return pre + "".join([chr(int(s[i:i+2], 16)) for i in range(0,l,2)])

def m(s):
    ann = s
    if s.startswith("<\\\\"):
        ann = s[s.find(">")+1:]
    for bef, aft in table.items():
        s = s.replace(bef, aft)
    s = re.sub("<COM:([0-F]+)>", form_com, s)
    return s, ann

main(f = m)
