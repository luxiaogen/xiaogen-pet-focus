#!/usr/bin/env python3
"""Generate a minimal clock-style macOS app icon for FocusPet."""
from __future__ import annotations

import math

from PIL import Image, ImageDraw, ImageFilter

OUT = "AppIcon-source.png"
SIZE = 1024
SCALE = 2
CANVAS = SIZE * SCALE


def s(value: float) -> int:
    return int(round(value * SCALE))


def rounded_mask(size: int, radius: int) -> Image.Image:
    mask = Image.new("L", (size, size), 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle((0, 0, size - 1, size - 1), radius=radius, fill=255)
    return mask


def background() -> Image.Image:
    image = Image.new("RGBA", (CANVAS, CANVAS), (108, 184, 205, 255))

    glow = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    draw = ImageDraw.Draw(glow)
    draw.ellipse((s(128), s(104), s(756), s(732)), fill=(232, 252, 255, 48))
    glow = glow.filter(ImageFilter.GaussianBlur(s(82)))
    return Image.alpha_composite(image, glow)


def point(center: tuple[int, int], radius: int, degrees: float) -> tuple[int, int]:
    angle = math.radians(degrees - 90)
    return (
        int(round(center[0] + math.cos(angle) * radius)),
        int(round(center[1] + math.sin(angle) * radius)),
    )


def draw_icon() -> Image.Image:
    canvas = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    canvas.paste(background(), (0, 0), rounded_mask(CANVAS, s(224)))

    shadow = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    shadow_draw.ellipse((s(236), s(702), s(788), s(842)), fill=(22, 78, 94, 54))
    shadow = shadow.filter(ImageFilter.GaussianBlur(s(26)))
    canvas.alpha_composite(shadow)

    draw = ImageDraw.Draw(canvas)
    center = (s(512), s(512))
    face_box = (s(244), s(216), s(780), s(752))
    outer = (55, 74, 82, 235)
    face = (255, 253, 241, 255)
    accent = (255, 142, 38, 255)
    tick = (55, 74, 82, 125)

    draw.ellipse((s(230), s(202), s(794), s(766)), fill=(255, 255, 255, 44))
    draw.ellipse(face_box, fill=face)
    draw.ellipse(face_box, outline=outer, width=s(14))

    # A small Pomodoro accent, kept separate from the clock hands.
    draw.arc((s(284), s(256), s(740), s(712)), -92, 28, fill=accent, width=s(22))

    for degrees in (0, 90, 180, 270):
        start = point(center, s(198), degrees)
        end = point(center, s(226), degrees)
        draw.line((start, end), fill=tick, width=s(10))

    minute_end = point(center, s(156), 10)
    hour_end = point(center, s(112), 315)
    draw.line((center, minute_end), fill=outer, width=s(18))
    draw.line((center, hour_end), fill=outer, width=s(22))
    draw.ellipse((center[0] - s(24), center[1] - s(24), center[0] + s(24), center[1] + s(24)), fill=accent)

    return canvas.resize((SIZE, SIZE), Image.Resampling.LANCZOS)


def main() -> None:
    icon = draw_icon()
    icon.save(OUT, "PNG")
    print(f"Wrote {OUT} ({SIZE}x{SIZE})")


if __name__ == "__main__":
    main()
