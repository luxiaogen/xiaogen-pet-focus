#!/usr/bin/env python3
"""Generate a clean macOS app icon for FocusPet.

The icon keeps the original white-capped chick mascot, but redraws it as a
simple flat character so the app still feels recognizable at small sizes.
"""
from __future__ import annotations

from PIL import Image, ImageDraw, ImageFilter

OUT = "AppIcon-source.png"
SIZE = 1024
SCALE = 2
CANVAS = SIZE * SCALE


def s(value: float) -> int:
    return int(round(value * SCALE))


def mix(a: tuple[int, int, int], b: tuple[int, int, int], t: float) -> tuple[int, int, int]:
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def rounded_mask(size: int, radius: int) -> Image.Image:
    mask = Image.new("L", (size, size), 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle((0, 0, size - 1, size - 1), radius=radius, fill=255)
    return mask


def background(size: int) -> Image.Image:
    top = (255, 240, 221)
    mid = (255, 196, 174)
    bottom = (248, 104, 87)

    image = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    px = image.load()
    for y in range(size):
        for x in range(size):
            t = (x * 0.58 + y * 0.82) / (size * 1.4)
            t = max(0, min(1, t))
            if t < 0.58:
                color = mix(top, mid, t / 0.58)
            else:
                color = mix(mid, bottom, (t - 0.58) / 0.42)
            px[x, y] = (*color, 255)

    shine = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shine)
    sd.ellipse((s(106), s(92), s(768), s(750)), fill=(255, 255, 255, 70))
    shine = shine.filter(ImageFilter.GaussianBlur(s(54)))
    return Image.alpha_composite(image, shine)


def draw_icon() -> Image.Image:
    canvas = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))

    bg = background(CANVAS)
    mask = rounded_mask(CANVAS, s(224))
    canvas.paste(bg, (0, 0), mask)

    draw = ImageDraw.Draw(canvas)

    # Soft card edge.
    draw.rounded_rectangle(
        (s(30), s(30), s(994), s(994)),
        radius=s(202),
        outline=(255, 255, 255, 125),
        width=s(9),
    )

    # Character shadow.
    shadow = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.ellipse((s(292), s(746), s(732), s(858)), fill=(80, 38, 28, 92))
    shadow = shadow.filter(ImageFilter.GaussianBlur(s(24)))
    canvas.alpha_composite(shadow)
    draw = ImageDraw.Draw(canvas)

    outline = (91, 59, 47, 190)
    dark = (46, 36, 34, 255)

    # Small body, kept visible so the mascot is less abstract than a face mark.
    draw.ellipse((s(328), s(532), s(696), s(848)), fill=(44, 36, 35, 255))
    draw.ellipse((s(328), s(532), s(696), s(848)), outline=outline, width=s(8))
    draw.rounded_rectangle((s(406), s(594), s(618), s(824)), radius=s(88), fill=(255, 255, 249, 255))
    draw.rounded_rectangle((s(286), s(610), s(394), s(760)), radius=s(54), fill=(44, 36, 35, 255))
    draw.rounded_rectangle((s(630), s(610), s(738), s(760)), radius=s(54), fill=(44, 36, 35, 255))
    draw.ellipse((s(374), s(804), s(500), s(878)), fill=(246, 132, 32, 255))
    draw.ellipse((s(524), s(804), s(650), s(878)), fill=(246, 132, 32, 255))

    # Chick head.
    face_box = (s(260), s(202), s(764), s(706))
    draw.ellipse(face_box, fill=(255, 214, 67, 255))
    draw.ellipse(face_box, outline=outline, width=s(9))

    # White cap and side tufts from the original mascot, simplified to broad shapes.
    cap = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    cd = ImageDraw.Draw(cap)
    cd.rounded_rectangle((s(336), s(156), s(688), s(358)), radius=s(90), fill=(255, 255, 249, 255))
    cd.ellipse((s(280), s(252), s(454), s(480)), fill=(255, 255, 249, 255))
    cd.ellipse((s(570), s(252), s(744), s(480)), fill=(255, 255, 249, 255))
    cd.polygon([(s(456), s(354)), (s(512), s(432)), (s(568), s(354))], fill=(255, 214, 67, 255))
    canvas.alpha_composite(cap)
    draw = ImageDraw.Draw(canvas)
    draw.arc((s(346), s(184), s(678), s(374)), 196, 344, fill=(95, 64, 52, 120), width=s(7))

    # Eyes and beak.
    for cx in (s(430), s(594)):
        draw.ellipse((cx - s(54), s(386), cx + s(54), s(508)), fill=(255, 255, 255, 255))
        draw.ellipse((cx - s(20), s(430), cx + s(20), s(474)), fill=dark)
        draw.ellipse((cx - s(8), s(420), cx + s(6), s(434)), fill=(255, 255, 255, 220))

    draw.ellipse((s(326), s(520), s(410), s(604)), fill=(255, 93, 73, 210))
    draw.ellipse((s(614), s(520), s(698), s(604)), fill=(255, 93, 73, 210))
    draw.rounded_rectangle((s(434), s(520), s(590), s(606)), radius=s(42), fill=(255, 144, 32, 255))
    draw.arc((s(458), s(532), s(566), s(596)), 20, 160, fill=(95, 54, 31, 190), width=s(7))

    # Tiny collar highlight; one small detail is enough for depth.
    draw.rounded_rectangle((s(426), s(620), s(598), s(646)), radius=s(13), fill=(255, 255, 249, 225))

    final = canvas.resize((SIZE, SIZE), Image.Resampling.LANCZOS)
    return final


def main() -> None:
    icon = draw_icon()
    icon.save(OUT, "PNG")
    print(f"Wrote {OUT} ({SIZE}x{SIZE})")


if __name__ == "__main__":
    main()
