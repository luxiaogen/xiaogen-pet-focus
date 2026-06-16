#!/usr/bin/env python3
"""Generate a macOS-style app icon for FocusPet using the ikun chick sprite.

Produces a 1024x1024 PNG with a squircle (continuous corner) background,
soft gradient, drop shadow under the chick, and the chick centered.
This PNG is later converted to .icns via iconutil.
"""
import math
from PIL import Image, ImageDraw, ImageFilter

SRC = "Sources/FocusPet/Resources/Pets/ikunchick_0.png"
OUT = "AppIcon-source.png"
SIZE = 1024


def continuous_corner_mask(size: int, radius: float) -> Image.Image:
    """Approximate Apple's 'continuous' superellipse-like corner mask."""
    mask = Image.new("L", (size, size), 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle((0, 0, size - 1, size - 1), radius=radius, fill=255)
    # Smooth the mask to soften the corner into a continuous curve.
    return mask.filter(ImageFilter.GaussianBlur(radius=size * 0.012))


def make_background(size: int) -> Image.Image:
    """Warm cream-to-tomato diagonal gradient matching the app palette."""
    bg = Image.new("RGB", (size, size))
    # Approximate app palette:
    #   focusCream (1.0, 0.96, 0.89)  ->  top-left
    #   focusBlush (1.0, 0.82, 0.76)  ->  mid
    #   focusTomato (1.0, 0.39, 0.28) ->  bottom-right
    top = (255, 245, 227)        # focusCream
    mid = (255, 209, 194)        # focusBlush
    bot = (255, 99, 71)          # focusTomato
    px = bg.load()
    for y in range(size):
        for x in range(size):
            t = (x + y) / (2 * (size - 1))  # 0 (top-left) .. 1 (bottom-right)
            if t < 0.5:
                u = t / 0.5
                r = int(top[0] + (mid[0] - top[0]) * u)
                g = int(top[1] + (mid[1] - top[1]) * u)
                b = int(top[2] + (mid[2] - top[2]) * u)
            else:
                u = (t - 0.5) / 0.5
                r = int(mid[0] + (bot[0] - mid[0]) * u)
                g = int(mid[1] + (bot[1] - mid[1]) * u)
                b = int(mid[2] + (bot[2] - mid[2]) * u)
            px[x, y] = (r, g, b)
    return bg


def main() -> None:
    # 1. Background gradient (square, will be masked to squircle).
    bg = make_background(SIZE).convert("RGBA")

    # Subtle vignette: darken edges slightly for depth.
    vignette = Image.new("L", (SIZE, SIZE), 0)
    vd = ImageDraw.Draw(vignette)
    vd.ellipse((-SIZE * 0.15, -SIZE * 0.15, SIZE * 1.15, SIZE * 1.15), fill=255)
    vignette = vignette.filter(ImageFilter.GaussianBlur(radius=SIZE * 0.18))
    darken = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    # Blend a translucent black using inverse vignette as mask.
    inv_vig = Image.eval(vignette, lambda v: 255 - v)
    black_layer = Image.new("RGBA", (SIZE, SIZE), (120, 40, 25, 60))
    bg = Image.composite(black_layer, bg, inv_vig)

    # 2. Load chick sprite and scale it up (it's 256px, scale to ~78% of icon).
    chick = Image.open(SRC).convert("RGBA")
    target = int(SIZE * 0.74)
    chick = chick.resize((target, target), Image.LANCZOS)

    # Trim transparent borders to find real bounds, so we center precisely.
    bbox = chick.getbbox()
    if bbox:
        chick_cropped = chick.crop(bbox)
        # Re-pad to a square of the chick's max dimension so centering is exact.
        w, h = chick_cropped.size
        side = max(w, h)
        square = Image.new("RGBA", (side, side), (0, 0, 0, 0))
        square.paste(chick_cropped, ((side - w) // 2, (side - h) // 2), chick_cropped)
        chick = square.resize((target, target), Image.LANCZOS)

    # 3. Drop shadow for the chick.
    shadow_pad = 60
    shadow = Image.new("RGBA", (target + shadow_pad * 2, target + shadow_pad * 2), (0, 0, 0, 0))
    # Use the chick alpha as shadow shape.
    chick_alpha = chick.split()[-1]
    shadow_alpha = chick_alpha.filter(ImageFilter.GaussianBlur(radius=18))
    shadow_alpha = shadow_alpha.point(lambda v: min(255, int(v * 0.55)))
    shadow.paste((0, 0, 0, 255), (0, 0), shadow_alpha)
    # Offset shadow down a touch.
    shadow_offset = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    sx = (SIZE - shadow.width) // 2
    sy = (SIZE - shadow.height) // 2 + 26
    shadow_offset.paste(shadow, (sx, sy), shadow)

    # 4. Composite: bg -> shadow -> chick.
    canvas = bg.convert("RGBA")
    canvas = Image.alpha_composite(canvas, shadow_offset)
    cx = (SIZE - target) // 2
    cy = (SIZE - target) // 2 + 8
    canvas.paste(chick, (cx, cy), chick)

    # 5. Mask to squircle (Apple continuous corner ~ 22.37% of size).
    radius = SIZE * 0.2237
    mask = continuous_corner_mask(SIZE, radius)
    final = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    final.paste(canvas, (0, 0), mask)

    final.save(OUT, "PNG")
    print(f"Wrote {OUT} ({SIZE}x{SIZE})")


if __name__ == "__main__":
    main()
