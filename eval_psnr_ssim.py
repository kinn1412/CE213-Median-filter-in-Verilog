import sys
import numpy as np
from PIL import Image
from skimage.metrics import structural_similarity as ssim


def load_image(path: str, drop_alpha: bool = False) -> np.ndarray:
    """
    Load ảnh về numpy uint8.
    - drop_alpha=True: nếu ảnh có alpha (RGBA/LA/P with transparency) thì convert về RGB (bỏ alpha).
    """
    img = Image.open(path)

    if drop_alpha:
        if img.mode in ("RGBA", "LA") or (img.mode == "P" and "transparency" in img.info):
            img = img.convert("RGB")

    arr = np.array(img)
    if arr.dtype != np.uint8:
        arr = np.clip(arr, 0, 255).astype(np.uint8)
    return arr


def psnr(img1: np.ndarray, img2: np.ndarray, data_range: float = 255.0) -> float:
    x = img1.astype(np.float64)
    y = img2.astype(np.float64)
    mse = np.mean((x - y) ** 2)
    if mse == 0:
        return float("inf")
    return 20.0 * np.log10(data_range / np.sqrt(mse))


def ssim_score(img1: np.ndarray, img2: np.ndarray, data_range: float = 255.0) -> float:
    if img1.ndim == 2:  # grayscale
        return float(ssim(img1, img2, data_range=data_range))
    elif img1.ndim == 3:  # color (H,W,C)
        return float(ssim(img1, img2, data_range=data_range, channel_axis=2))
    else:
        raise ValueError(f"Unsupported image shape: {img1.shape}")


def main():
    if len(sys.argv) != 3:
        print("Usage: python eval_psnr_ssim.py <original_image> <reconstructed_image>")
        sys.exit(1)

    orig_path, rec_path = sys.argv[1], sys.argv[2]

    # Ảnh gốc: giữ nguyên
    orig = load_image(orig_path, drop_alpha=False)
    # Ảnh tái tạo: nếu có alpha thì drop về RGB
    rec = load_image(rec_path, drop_alpha=True)

    # Nếu rec vẫn là 4 kênh (hiếm) thì cắt alpha bằng numpy cho chắc
    if rec.ndim == 3 and rec.shape[2] == 4:
        rec = rec[:, :, :3]

    # Nếu orig có alpha mà bạn muốn giữ orig 3 kênh luôn, có thể bật đoạn dưới:
    if orig.ndim == 3 and orig.shape[2] == 4:
        orig = orig[:, :, :3]

    if orig.shape != rec.shape:
        raise ValueError(f"Ảnh không cùng kích thước/kênh: orig{orig.shape} vs rec{rec.shape}")

    data_range = 255.0  # đúng cho uint8

    psnr_val = psnr(orig, rec, data_range=data_range)
    ssim_val = ssim_score(orig, rec, data_range=data_range)

    print(f"Original mode/channels: shape={orig.shape}, dtype={orig.dtype}")
    print(f"Reconst  mode/channels: shape={rec.shape}, dtype={rec.dtype}")
    print(f"PSNR: {psnr_val:.4f} dB")
    print(f"SSIM: {ssim_val:.6f}")


if __name__ == "__main__":
    main()
