from PIL import Image

img_in = Image.open(r"test.jpeg")
img_out = Image.new(mode="RGB", size=(320, 240))
assert (img_in.size == (320, 240)), "Input image should be 640x480"
px = img_in.load()
hex_img = ""
line_color_toggle = 0

def rgb_to_12bit_hex(pix):
    r,g,b = pix
    out = ((int(b/16) & 0xF) << 8) | ((int(g/16) & 0xF) << 4)  | (int(r/16) & 0xF)
    return (out, f'{out:x}'.upper())

for y in range(0, 240):
    row = ""

    for x in range(0, 320):
        cur_pixel = rgb_to_12bit_hex(px[x, y])
        row += cur_pixel[1] + " "
        img_out.putpixel((x,y), ((cur_pixel[0] & 0xF) * 16, ((cur_pixel[0] >> 4) & 0xF) * 16, ((cur_pixel[0] >> 8) & 0xF) * 16))

    hex_img += row + "\n"

img_out.show()

with open('vga_hex.mem', 'w') as f:
    f.write(hex_img)
