#!/usr/bin/env python3
import argparse
from pathlib import Path
import numpy as np
from PIL import Image
import re

HEX2_RE = re.compile(r"^[0-9a-fA-F]{2}$")

def parse_pixel(token: str, fill: int) -> int | None:
    s = token.strip()
    if not s:
        return None
    if s.startswith("#") or s.startswith("//"):
        return None

    low = s.lower()
    if low in ("x", "xx", "z", "zz", "??"):
        return fill

    # Accept exactly 2 hex digits (recommended format)
    if HEX2_RE.match(s):
        return int(s, 16)

    # Fallback: if user accidentally has "0x7f" or "7Fh"
    low = low.replace("0x", "")
    if low.endswith("h"):
        low = low[:-1]
    low = low.strip()

    if HEX2_RE.match(low):
        return int(low, 16)

    # Not parseable
    return None

def load_hex_lines(path: Path, expected: int, fill: int) -> tuple[np.ndarray, int, int]:
    lines = path.read_text(encoding="utf-8", errors="ignore").splitlines()
    vals = []
    bad = 0
    replaced = 0

    for line in lines:
        px = parse_pixel(line, fill)
        if px is None:
            # if line has content but not parseable => bad
            if line.strip() and not (line.strip().startswith("#") or line.strip().startswith("//")):
                bad += 1
            continue

        if line.strip().lower() in ("x", "xx", "z", "zz", "??"):
            replaced += 1

        vals.append(px)
        if len(vals) >= expected:
            break

    # If still not enough pixels, pad with fill
    if len(vals) < expected:
        missing = expected - len(vals)
        vals.extend([fill] * missing)
        replaced += missing

    return np.array(vals, dtype=np.uint8), bad, replaced

def main():
    ap = argparse.ArgumentParser(description="Convert pic_output.txt (hex byte per line) to grayscale image.")
    ap.add_argument("input_txt", help="Input txt file (e.g., pic_output.txt)")
    ap.add_argument("-W", "--width", type=int, required=True, help="Image width in pixels")
    ap.add_argument("-H", "--height", type=int, required=True, help="Image height in pixels")
    ap.add_argument("-o", "--output", default="pic_output.png", help="Output image path (default: pic_output.png)")
    ap.add_argument("--fill", type=int, default=0, help="Fill value (0..255) used for unknown/invalid pixels (default: 0)")
    args = ap.parse_args()

    if not (0 <= args.fill <= 255):
        raise SystemExit("ERROR: --fill must be 0..255")

    inp = Path(args.input_txt)
    out = Path(args.output)

    expected = args.width * args.height
    data, bad_lines, replaced = load_hex_lines(inp, expected=expected, fill=args.fill)

    img_arr = data.reshape((args.height, args.width))
    img = Image.fromarray(img_arr, mode="L")
    img.save(out)

    print(f"Done.\nInput : {inp}\nOutput: {out}\nSize  : {args.width}x{args.height}")
    if bad_lines or replaced:
        print(f"Note: bad_lines_skipped={bad_lines}, unknown_or_padded_replaced={replaced} (fill={args.fill})")

if __name__ == "__main__":
    main()
