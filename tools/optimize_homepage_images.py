"""Create lightweight homepage variants while preserving the original PNGs."""

from pathlib import Path

from PIL import Image


IMAGES = Path(__file__).resolve().parents[1] / "source/images"


def main():
    variants = [
        ("hero/fleek-embracing.png", "hero/fleek-embracing-optimized.webp", None, 92),
        ("features/activity-ribbon-v4.png", "features/activity-ribbon-v4-optimized.webp", 920, 90),
        ("nest/nest-with-eggs.png", "nest/nest-with-eggs.webp", None, 92),
        ("flock/fleeks-forward.png", "flock/fleeks-forward.webp", 1200, 92),
        ("flock/dashes-forward.png", "flock/dashes-forward.webp", 900, 92),
        ("flock/fleeks-forward-v2.png", "flock/fleeks-forward-v2.webp", 1200, 92),
        ("flock/dash-forward.png", "flock/dash-forward.webp", 600, 92),
        ("flock/storm-wall.png", "flock/storm-wall.webp", 1800, 86),
        ("flock/fleek-left-complete.png", "flock/fleek-left-complete.webp", (511, 390), 92),
        ("flock/fleek-leader-complete.png", "flock/fleek-leader-complete.webp", (1185, 570), 92),
    ]
    for source_name, output_name, width, quality in variants:
        source, output = IMAGES / source_name, IMAGES / output_name
        with Image.open(source) as image:
            image = image.convert("RGBA")
            if isinstance(width, tuple):
                # Independent sprites share the original formation's framing.
                image = image.resize(width, Image.Resampling.LANCZOS)
            elif width is not None and image.width > width:
                height = round(image.height * width / image.width)
                image = image.resize((width, height), Image.Resampling.LANCZOS)
            image.save(output, "WEBP", quality=quality, method=6, exact=True)
            print(f"{output_name}: {image.width}×{image.height}, {source.stat().st_size:,} → {output.stat().st_size:,} bytes")


if __name__ == "__main__":
    main()
