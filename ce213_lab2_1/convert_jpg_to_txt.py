#!/usr/bin/env python3
from PIL import Image
import numpy as np
import argparse
from pathlib import Path

def img_to_txt(in_path: Path, out_path: Path, info_path: Path | None = None) -> None:
    img = Image.open(in_path).convert("L")  # 8-bit grayscale
    arr = np.array(img, dtype=np.uint8)
    h, w = arr.shape

    # Write: 1 byte (hex) per line, row-major
    with out_path.open("w", encoding="utf-8") as f:
        for v in arr.reshape(-1):
            f.write(f"{int(v):02x}\n")

    if info_path is not None:
        info_path.write_text(
            f"Image converted to 8-bit grayscale.\n"
            f"Width={w}\nHeight={h}\nTotalPixels={w*h}\n"
            f"Format: 1 hex byte per line, row-major.\n",
            encoding="utf-8"
        )

    print(f"Done.\nInput : {in_path}\nOutput: {out_path}\nSize  : {w}x{h} ({w*h} pixels)")

def main():
    parser = argparse.ArgumentParser(description="Convert image (jpg/png/...) to pic_input.txt (1 hex byte per line).")
    parser.add_argument("input", help="Input image path (e.g. image.jpg)")
    parser.add_argument("-o", "--output", default="pic_input.txt", help="Output txt path (default: pic_input.txt)")
    parser.add_argument("--info", default="pic_input_info.txt", help="Info file path (default: pic_input_info.txt). Use '' to disable.")
    args = parser.parse_args()

    in_path = Path(args.input)
    out_path = Path(args.output)

    info_path = None
    if args.info != "":
        info_path = Path(args.info)

    img_to_txt(in_path, out_path, info_path)

if __name__ == "__main__":
    main()
