#!/usr/bin/env python3
"""Build a modern ICNS file from a 1024x1024 source PNG.

This is a small fallback for environments where `iconutil` rejects otherwise
valid iconsets. It writes PNG-backed ICNS entries for the standard sizes.
"""
from __future__ import annotations

import io
import struct
import sys
from pathlib import Path

from PIL import Image

ENTRIES = [
    ("icp4", 16),
    ("icp5", 32),
    ("icp6", 64),
    ("ic07", 128),
    ("ic08", 256),
    ("ic09", 512),
    ("ic10", 1024),
]


def png_bytes(image: Image.Image, size: int) -> bytes:
    resized = image.resize((size, size), Image.Resampling.LANCZOS)
    buffer = io.BytesIO()
    resized.save(buffer, format="PNG")
    return buffer.getvalue()


def build_icns(source: Path, output: Path) -> None:
    base = Image.open(source).convert("RGBA")
    chunks: list[bytes] = []

    for code, size in ENTRIES:
        data = png_bytes(base, size)
        chunks.append(code.encode("ascii") + struct.pack(">I", len(data) + 8) + data)

    payload = b"".join(chunks)
    output.write_bytes(b"icns" + struct.pack(">I", len(payload) + 8) + payload)


def main() -> None:
    if len(sys.argv) != 3:
        print("usage: build_app_icon_icns.py <source.png> <output.icns>", file=sys.stderr)
        raise SystemExit(2)

    build_icns(Path(sys.argv[1]), Path(sys.argv[2]))


if __name__ == "__main__":
    main()
