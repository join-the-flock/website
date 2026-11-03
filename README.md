# Flock website

Run `dart pub get`, then `dart run bin/main.dart` to build the site.
Local builds automatically reuse the last successful commit snapshot. Saving
files and rebuilding does not request GitHub again. If no snapshot exists, the
first build fetches it once; the cache remains in use until explicitly refreshed.

Use `dart run bin/main.dart --refresh-commits` to refresh commits and build, or
`dart run bin/main.dart --cached-commits` to require an existing snapshot and
guarantee no GitHub requests. These two options cannot be combined.

When refreshing, the build fetches the latest 20 commits on `master` from
`join-the-flock/flock-patches` and `flutter/flutter` using GitHub's commits API.
It writes `source/data/recent-commits.json`, which Static Shock copies to
`build/data/recent-commits.json` (served at `/data/recent-commits.json`).

The JSON contains newest-first `flock` and `flutter` arrays, source repositories
and branches, and the snapshot generation time. Each commit includes its SHA,
subject, GitHub URL, author name, optional GitHub login/avatar, and author and
committer timestamps. Unlinked Git authors retain their original name.

Set `GITHUB_TOKEN` to use authenticated requests. GitHub Actions supplies its
build token automatically; public repositories also work without a token.
Deployment explicitly uses `--refresh-commits`, so published builds fetch fresh
data. A requested refresh fails if either upstream request fails or returns no
commits, rather than publishing a partial feed. The previous snapshot is retained
on failure, allowing subsequent local builds to keep working without retrying
GitHub. The website does not poll GitHub in a visitor's browser.

Run `dart run bin/recent_commits.dart` to refresh just the snapshot, or
`dart test test/recent_commits_test.dart` to run the feed tests.

The homepage renders its approved hero and navigation from
`source/_includes/components/homeHero.jinja`, with styles in
`source/styles/hero.scss` and animation code in `source/scripts/hero/`.
Initial cards are rendered from the build snapshot, including real authors,
avatars and commit links. The homepage does not simulate or poll for new commits.
Its existing arrival animations accept `flock-commit` and `flutter-commit` custom
events on `.hero` for future updates. Golden Goose and Plume remain disabled
navigation placeholders until their destinations exist.

`design/embracing-hero/` retains the original standalone prototype and simulation
controls for design experiments.

The homepage product sections live in `homeFeatures.jinja`, with scoped styling
in `source/styles/features.scss`. The FVM example toggles between valid Flutter
and Flock configurations through `source/scripts/features.js`; full installation
instructions remain available at `/flock/get-started`.

## Social sharing image

All pages use `source/images/flock-social-hero.png` through the shared
`socialImage.jinja` component. To refresh it after a hero design change, build
the site, run `node tools/capture_social_image.cjs`, then rebuild to copy the
new image into the distribution. The capture tool requires Playwright and
Chromium; `FLOCK_CHROME_PATH` can point to an installed Chrome executable.

The tool captures the actual hero at 1200×630 with reduced motion enabled for
a consistent frame. Capture-only CSS hides the navigation and each commit's
children with `visibility: hidden`, preserving card dimensions and text wrapping.
It checks those dimensions before saving. These overrides never affect visitors.

## Optimized artwork

The hero and ribbon use optimized WebP variants. The original PNGs remain in
`source/images/hero/` and `source/images/features/`. Run
`python3 tools/optimize_homepage_images.py` (requires Pillow) to regenerate
the variants, including the Nest hero artwork and Flock flight formations. Fleek keeps its full 1560×1008
resolution and original alpha; the ribbon is 920px wide for a sharp 2× rendering
at its 460px display width.

`bin/public_assets.dart` selects the active artwork published from the hero,
features, Flock and Nest image directories. Originals and earlier variants stay
in source but are excluded from deployment. Update the selection when changing
the artwork used by a public page. Other branding, avatars, social images and
favicon files remain published normally.

Prism's bundle and MIT license are served locally from
`source/scripts/vendor/prism/`. Its maintenance notes are in
`design/vendor/prism.md`, outside the published source directory.

Retired Flock contributor URLs remain available as static HTML redirects:
the issue guide points to the Nest issue form, and the setup/change guides point
to the Nest repository. Their template is `layouts/redirect.jinja`.

## Nest hero

`source/styles/nest.scss` controls the shorter responsive hero. Its transparent
nest-and-eggs centerpiece uses `source/images/nest/nest-with-eggs.webp`; the
high-resolution PNG and cutout prompt are preserved. `source/scripts/nest-hero.js`
draws the surrounding code streams and sparks with Canvas 2D. It renders at
about 30fps with a capped pixel ratio, pauses beyond a 200px viewport buffer or
in hidden tabs, and renders a still frame for reduced-motion preferences.

## Hero rendering compatibility

Desktop uses the animated WebGL edge glow with premultiplied alpha, so transparent
pixels cannot contribute pink or blue color to the page. Touch-first devices use
native CSS shadows around the combined Fleek/Flock group instead; the Canvas 2D
Matrix background remains animated. The same native glow is used if WebGL is
unavailable, shader compilation fails, or the graphics context is lost.

Run `node --test test/hero_glow_test.cjs` to check fallback selection. Deployment
runs these checks alongside the Dart tests.
