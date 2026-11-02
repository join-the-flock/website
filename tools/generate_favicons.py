"""Create website icon assets from the approved nav logo. Requires Pillow."""

import json
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
DEST = ROOT / "source/images/favicon"
BACKGROUND = "#0d0912"


def icon(logo, size, inset=0.06, background=None):
    canvas = Image.new("RGBA", (size, size), background or (0, 0, 0, 0))
    artwork = logo.copy()
    edge = size - 2 * max(1, round(size * inset))
    artwork.thumbnail((edge, edge), Image.Resampling.LANCZOS)
    canvas.alpha_composite(artwork, ((size - artwork.width) // 2, (size - artwork.height) // 2))
    return canvas


def safari_mask(image):
    """Convert the logo's alpha to black vector geometry for Safari's mask."""
    alpha = image.getchannel("A")
    pixels = alpha.load()
    active = {}
    rectangles = []
    for y in range(image.height + 1):
        runs = set()
        x = 0
        while y < image.height and x < image.width:
            if pixels[x, y] < 128:
                x += 1
                continue
            start = x
            while x < image.width and pixels[x, y] >= 128:
                x += 1
            runs.add((start, x))
        for run in active.keys() - runs:
            start_y = active.pop(run)
            rectangles.append((run[0], start_y, run[1] - run[0], y - start_y))
        for run in runs - active.keys():
            active[run] = y
    paths = " ".join(f"M{x} {y}h{w}v{h}h{-w}z" for x, y, w, h in rectangles)
    return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {image.width} {image.height}"><path fill="#000" d="{paths}"/></svg>\n'


def main():
    DEST.mkdir(parents=True, exist_ok=True)
    logo = Image.open(ROOT / "source/images/flock-nav-logo.png").convert("RGBA")
    logo = logo.crop(logo.getchannel("A").point(lambda a: 255 if a >= 128 else 0).getbbox())
    for size in (16, 32):
        icon(logo, size).save(DEST / f"favicon-{size}x{size}.png", optimize=True)
    icon(logo, 64).save(DEST / "favicon.ico", sizes=[(16, 16), (32, 32), (48, 48), (64, 64)])
    icon(logo, 180, 0.10, BACKGROUND).convert("RGB").save(DEST / "apple-touch-icon.png", optimize=True)
    for size in (192, 512):
        icon(logo, size).save(DEST / f"android-chrome-{size}x{size}.png", optimize=True)
    icon(logo, 150, 0.10, BACKGROUND).convert("RGB").save(DEST / "mstile-150x150.png", optimize=True)
    (DEST / "safari-pinned-tab.svg").write_text(safari_mask(icon(logo, 512)))
    manifest = {
        "name": "Flock",
        "short_name": "Flock",
        "icons": [
            {"src": f"/images/favicon/android-chrome-{size}x{size}.png", "sizes": f"{size}x{size}", "type": "image/png"}
            for size in (192, 512)
        ],
        "theme_color": BACKGROUND,
        "background_color": BACKGROUND,
        "display": "standalone",
    }
    (DEST / "site.webmanifest").write_text(json.dumps(manifest, indent=2) + "\n")
    (DEST / "browserconfig.xml").write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<browserconfig><msapplication><tile>'
        '<square150x150logo src="/images/favicon/mstile-150x150.png"/>'
        f'<TileColor>{BACKGROUND}</TileColor>'
        '</tile></msapplication></browserconfig>\n'
    )


if __name__ == "__main__":
    main()
