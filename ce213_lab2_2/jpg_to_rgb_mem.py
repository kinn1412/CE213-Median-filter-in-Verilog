import argparse
from pathlib import Path
import numpy as np
from PIL import Image

def main():
    ap = argparse.ArgumentParser(description="JPG -> rgb.mem (R8G8B8, 24-bit binary per line)")
    ap.add_argument("input", help="input image (.jpg/.jpeg/.png...)")
    ap.add_argument("-o", "--output", default="rgb.mem", help="output .mem file (default: rgb.mem)")
    ap.add_argument("--w", type=int, default=None, help="resize width (optional)")
    ap.add_argument("--h", type=int, default=None, help="resize height (optional)")
    args = ap.parse_args()

    in_path = Path(args.input)
    if not in_path.exists():
        raise FileNotFoundError(f"Not found: {in_path}")

    img = Image.open(in_path).convert("RGB")

    # Nếu cần ép kích thước, dùng --w và --h. Nếu không, bỏ qua.
    if (args.w is not None) or (args.h is not None):
        if args.w is None or args.h is None:
            raise ValueError("Nếu resize thì phải có đủ --w và --h")
        img = img.resize((args.w, args.h), resample=Image.BILINEAR)

    arr = np.array(img, dtype=np.uint8)         # H x W x 3
    h, w, _ = arr.shape
    flat = arr.reshape(-1, 3).astype(np.uint32) # N x 3

    rgb24 = (flat[:, 0] << 16) | (flat[:, 1] << 8) | flat[:, 2]  # N
    bin_lines = np.vectorize(lambda v: format(int(v), "024b"))(rgb24)

    out_path = Path(args.output)
    np.savetxt(out_path, bin_lines, fmt="%s")

    depth = w * h
    aw = int(np.ceil(np.log2(depth)))
    out_path.with_suffix(".txt").write_text(
        f"WIDTH={w}\nHEIGHT={h}\nDEPTH={depth}\nAW={aw}\nFORMAT=R8G8B8 (24-bit, binary per line)\n",
        encoding="utf-8"
    )

    print(f"Saved: {out_path}  (W={w}, H={h}, lines={depth}, AW={aw})")

if __name__ == "__main__":
    main()
