from PIL import Image

in_path  = "D:\\Personal\\AI_Learning\\pic_output.png"     # đổi thành đường dẫn ảnh của bạn
out_path = "output.png"

with Image.open(in_path) as img:
    # Resize đúng kích thước (width, height)
    resized = img.resize((430, 554), resample=Image.LANCZOS)
    resized.save(out_path)

print("Done:", out_path)
