from PIL import Image
import statistics
import os
import sys

try:
    image_path = sys.argv[1]
    img = Image.open(image_path).convert('L')
    w, _ = img.size
    colors = list(img.getdata())[w*14:w*41]
    mean = statistics.mean(colors)
except Exception as e:
    os.system("echo change color error: {}".format(e))
else:
    if mean > 255 / 2:
        os.system("sed -i 's/^foreground = #D9E0EE/;; foreground = #D9E0EE/;t;s/^;; foreground = #1E1E29/foreground = #1E1E29/' $HOME/.config/polybar/catppuccin/colors.ini")
    else:
        os.system("sed -i 's/^foreground = #1E1E29/;; foreground = #1E1E29/;t;s/^;; foreground = #D9E0EE/foreground = #D9E0EE/' $HOME/.config/polybar/catppuccin/colors.ini")

    os.system("polybar-msg cmd restart")

