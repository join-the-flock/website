# Independent Fleek sprites

The live hero uses complete, independently generated left and leader sprites, plus the isolated right Fleek. Built-in image generation restored the covered edges using the prompts below. Original high-resolution outputs are saved as `source/images/flock/fleek-left-complete.png` and `fleek-leader-complete.png`; optimized WebP variants are used on the page.

The formation uses a 1200 × 600 SVG coordinate system. Live coordinates are recorded in `source/images/flock/fleek-formation.json`. The medium bird is slightly higher and farther left to keep its face clear of the leader's restored wing throughout their bounded drift. The SVG permits overflow so the complete wing and crest remain visible.

Historical polygon cutouts shared parts of the overlapping wings and are unsuitable for independent motion. `tools/split_fleek_formation.py` reproduces those static cutouts for reference only; the live hero uses the completed variants instead.

## Left Fleek repair prompt

This is an extracted sprite of ONE Fleek. Complete ONLY the missing part of the bird where its lower-right body/foot/tail was cut off by an overlapping foreground bird. Keep all existing visible pixels and details as faithfully as possible: exact face, eye direction, crest, banking angle, wing positions, colors, feather pattern and proportions. The bird remains front-facing in flight, counterclockwise banked, with both eyes visible. Restore a natural complete body, two tucked dark clawed feet and tail, matching the original character's anatomy and illustrative style.
Do not add another bird or another wingbeat. Keep the bird in exactly its current position and scale inside the same framing. Do not center or enlarge it. Preserve all existing wing edges, including the raised right wing. The result is one whole, independently movable bird on true transparent background, with no diagonal cut through its body and no remnants of other birds. No extra objects, no text, no outer glow, no background or ground.

## Leader repair prompt

Edit this ONE bird sprite. Restore the missing outer tip of its left wing (on viewer's left), which is cut off by an overlapping bird in the source. Preserve the bird's face, clockwise banking angle, body, feet, tail, right wing and all colors. Keep the bird at the same scale and position inside this wide canvas. The complete wing extends naturally up and left from the existing feathers. One front-facing flying pink and purple Fleek, cyan eyes, transparent background, no other birds, text, glow, or scenery. Keep the existing pose and feather details as faithfully as possible.

