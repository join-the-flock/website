"""Create lightweight homepage variants while preserving the original PNGs."""

from pathlib import Path

from PIL import Image


IMAGES = Path(__file__).resolve().parents[1] / "source/images"


def main():
    variants = [
        ("hero/fleek-embracing.png", "hero/fleek-embracing-optimized.webp", None, 92),
        ("features/activity-ribbon-v4.png", "features/activity-ribbon-v4-optimized.webp", 920, 90),
    ]
    for source_name, output_name, width, quality in variants:
        source, output = IMAGES / source_name, IMAGES / output_name
        with Image.open(source) as image:
            image = image.convert("RGBA")
            if width is not None and image.width > width:
                height = round(image.height * width / image.width)
                image = image.resize((width, height), Image.Resampling.LANCZOS)
            image.save(output, "WEBP", quality=quality, method=6, exact=True)
            print(f"{output_name}: {image.width}×{image.height}, {source.stat().st_size:,} → {output.stat().st_size:,} bytes")


if __name__ == "__main__":
    main()
