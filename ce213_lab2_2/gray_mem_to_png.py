import argparse
from pathlib import Path
import numpy as np
from PIL import Image

def is_bin_line(s: str) -> bool:
    s = s.strip()
    if not s:
        return False
    # chỉ chấp nhận chuỗi toàn 0/1 (8-bit hoặc 24-bit...)
    return all(c in "01" for c in s)

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("gray_mem", help="gray.mem (binary per line, may contain headers/comments)")
    ap.add_argument("--w", type=int, required=True)
    ap.add_argument("--h", type=int, required=True)
    ap.add_argument("-o", "--output", default="out_gray.png")
    args = ap.parse_args()

    lines = Path(args.gray_mem).read_text(encoding="utf-8", errors="ignore").splitlines()
    data_lines = [ln.strip() for ln in lines if is_bin_line(ln)]

    need = args.w * args.h
    if len(data_lines) < need:
        raise ValueError(f"Không đủ pixel: cần {need} dòng nhị phân, nhưng chỉ có {len(data_lines)} dòng hợp lệ.")

    # lấy đúng số pixel cần (nếu file dư thì cắt)
    data_lines = data_lines[:need]

    # auto-detect bit width
    bitlen = len(data_lines[0])
    if any(len(x) != bitlen for x in data_lines[:1000]):  # kiểm tra nhanh
        raise ValueError("Các dòng nhị phân không đồng nhất độ dài bit.")

    if bitlen == 8:
        vals = np.fromiter((int(s, 2) for s in data_lines), dtype=np.uint8, count=need)
        img = vals.reshape(args.h, args.w)          # grayscale L
        Image.fromarray(img, mode="L").save(args.output)
    elif bitlen == 24:
        # nếu bạn lỡ xuất gray.mem dạng 24-bit, lấy 8 bit MSB làm Y (hoặc bạn có thể chọn byte nào)
        vals24 = np.fromiter((int(s, 2) for s in data_lines), dtype=np.uint32, count=need)
        y = ((vals24 >> 16) & 0xFF).astype(np.uint8)  # lấy byte cao
        img = y.reshape(args.h, args.w)
        Image.fromarray(img, mode="L").save(args.output)
    else:
        raise ValueError(f"Không hỗ trợ bit width = {bitlen}. (Mong đợi 8 hoặc 24)")

    print("Saved:", args.output)

if __name__ == "__main__":
    main()
