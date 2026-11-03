"""Reproduce historical static cutouts. Occluded edges are not safe for motion.

The live hero uses the completed left/leader sprites instead of these cutouts.
"""

import json
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter


DIRECTORY = Path(__file__).resolve().parents[1] / "source/images/flock"


def main():
    source = Image.open(DIRECTORY / "fleeks-forward-v2.webp").convert("RGBA")
    assert source.size == (1200, 600)
    left = Image.new("L", source.size)
    ImageDraw.Draw(left).polygon(
        [(0, 0), (510, 0), (510, 222), (339, 222), (319, 264),
         (310, 298), (300, 320), (310, 360), (280, 402), (0, 402)],
        fill=255,
    )
    right = Image.new("L", source.size)
    ImageDraw.Draw(right).rectangle((829, 0, 1199, 284), fill=255)
    leader = ImageChops.invert(ImageChops.lighter(left, right))
    alpha = source.getchannel("A")
    opaque = alpha.point(lambda value: 255 if value == 255 else 0)
    manifest = {"width": 1200, "height": 600, "birds": {}}
    composite = Image.new("RGBA", source.size)

    for name, region in [("right", right), ("left", left), ("leader", leader)]:
        # Overlap opaque seam pixels to avoid interpolation gaps at display sizes.
        region = ImageChops.lighter(region, ImageChops.multiply(region.filter(ImageFilter.MaxFilter(5)), opaque))
        layer = source.copy()
        layer.putalpha(ImageChops.multiply(alpha, region))
        # Discard hidden RGB from the other birds as well as their alpha.
        layer.paste((0, 0, 0, 0), mask=layer.getchannel("A").point(lambda value: 255 if value == 0 else 0))
        bounds = layer.getchannel("A").getbbox()
        crop = layer.crop(bounds)
        crop.save(DIRECTORY / f"fleek-{name}.png", optimize=True)
        crop.save(DIRECTORY / f"fleek-{name}.webp", "WEBP", lossless=True, method=6, exact=True)
        x, y, right_edge, bottom = bounds
        manifest["birds"][name] = {"x": x, "y": y, "width": right_edge - x, "height": bottom - y}
        composite.alpha_composite(crop, (x, y))

    background = Image.new("RGBA", source.size, "#0d0912")
    before = Image.alpha_composite(background, source).convert("RGB")
    after = Image.alpha_composite(background, composite).convert("RGB")
    assert ImageChops.difference(before, after).getbbox() is None, "Separated artwork must recompose exactly"
    (DIRECTORY / "fleek-extraction.json").write_text(json.dumps(manifest, indent=2) + "\n")
    print(json.dumps(manifest, indent=2))
    print("Recomposed layers match the existing artwork pixel for pixel.")


if __name__ == "__main__":
    main()
