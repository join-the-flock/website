# Flock website

The site is statically pre-rendered with Jaspr 0.23.5. `lib/site.dart` supplies
the Jaspr component tree, navigation, commit cards and Markdown page loading;
`lib/page_markup.dart` preserves the approved HTML shells and illustrations.
`bin/main.dart` renders each URL through Jaspr’s server renderer, compiles SCSS,
copies published assets and generates `/rss_feed.xml`. Dependencies are locked in `pubspec.lock` for reproducible deployment.
No Dart client runtime
or SPA router is shipped: existing scripts keep their page-load behavior.

Content stays in `source/**/*.md`. Directory `_data.yaml` files provide layout
and section-menu defaults. Frontmatter-only `*.page.yaml` files define the home,
blog index and redirects. Styles and interaction scripts remain in `source/`.
The static output and deployment artifact remain `build/`. Dart 3.8+ is required.


Run `dart pub get`, then `jaspr serve` from the `website/` directory for local
development. The server reads content, styles, scripts and artwork from source;
commit data remains cached. Use `dart run bin/main.dart` to build the static site.
Local builds automatically reuse the last successful commit snapshot. Saving
files and rebuilding does not request GitHub again. If no snapshot exists, the
first build fetches it once; the cache remains in use until explicitly refreshed.

Use `dart run bin/main.dart --refresh-commits` to refresh commits and build, or
`dart run bin/main.dart --cached-commits` to require an existing snapshot and
guarantee no GitHub requests. These two options cannot be combined.

When refreshing, the build fetches the latest 20 commits from
`join-the-flock/flock-patches` on `main` and `flutter/flutter` on `master` using
GitHub's commits API.
It writes `source/data/recent-commits.json`, which the Jaspr build copies to
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
`lib/site.dart`, with styles in
`source/styles/hero.scss` and animation code in `source/scripts/hero/`.
Initial cards are rendered from the build snapshot, including real authors,
avatars and commit links. The homepage does not simulate or poll for new commits.
Its existing arrival animations accept `flock-commit` and `flutter-commit` custom
events on `.hero` for future updates.

`design/embracing-hero/` retains the original standalone prototype and simulation
controls for design experiments.

The homepage product sections live in `lib/page_markup.dart`, with scoped styling
in `source/styles/features.scss`. The FVM example toggles between valid Flutter
and Flock configurations through `source/scripts/features.js`; full installation
instructions remain available at `/flock/get-started`.

## Social sharing image

All pages use `source/images/flock-social-hero.jpg` through the shared
`socialMarkup()` component. To refresh it after a hero design change, build
the site, run `node tools/capture_social_image.cjs`, then rebuild to copy the
new image into the distribution. It saves both a PNG master and the smaller JPEG
used for sharing. The capture tool requires Playwright and
Chromium; `FLOCK_CHROME_PATH` can point to an installed Chrome executable.

The tool captures the actual hero at 1200×630 with reduced motion enabled for
a consistent frame. Capture-only CSS hides the navigation and each commit's
children with `visibility: hidden`, preserving card dimensions and text wrapping.
It checks those dimensions before saving. These overrides never affect visitors.

## Optimized artwork

The hero and ribbon use optimized WebP variants. The original PNGs remain in
`source/images/hero/` and `source/images/features/`. Run
`dart run tools/optimize_images.dart --only homepage nest flock` (after `dart pub get`)
to regenerate the current variants. Fleek keeps its full 1560×1008
resolution and original alpha; the ribbon is 920px wide for a sharp 2× rendering
at its 460px display width.

About and Blog share the photo hero treatment in `source/styles/image-hero.scss`:
centered images grow to 1400px wide, with a height-based minimum to prevent gaps,
soft side fades, and a dark blurred backdrop. Blog adds a bottom fade into the
hero canvas. The 1920px WebP assets are retained in `source/images/about/` and
`source/images/blog/`; regenerate them with
`dart run tools/optimize_images.dart --only about blog`. These exports read their
full-resolution originals from the sibling `branding/` directory by default;
use `--branding-dir` to choose another location. Deployment
uses the checked-in WebP files and does not need that branding directory.

`bin/public_assets.dart` selects the active artwork published from the hero,
features, Flock and Nest image directories. Originals and earlier variants stay
in source but are excluded from deployment. Update the selection when changing
the artwork used by a public page. Other branding, avatars, social images and
favicon files remain published normally.

`dart run tools/optimize_images.dart --only sharing avatars` regenerates the sharing JPEG from
its PNG master and the 192px WebP avatars from the original JPEG portraits.
Original assets remain available for editing and existing published URLs.
See [tools/README.md](tools/README.md) for all maintained tools, export groups,
dependencies, and preview options.

Prism's bundle and MIT license are served locally from
`source/scripts/vendor/prism/`. Its maintenance notes are in
`design/vendor/prism.md`, outside the published source directory.

Retired Flock contributor URLs remain available as static HTML redirects:
the issue guide points to the Nest issue form, and the setup/change guides point
to the Nest repository. Their template is `redirectMarkup()` in `lib/page_markup.dart`.

## Nest hero

Nest uses `nestMarkup()` in `lib/page_markup.dart` for all section pages, with a desktop sidebar and
the same sticky mobile navigation and scroll restoration as Flock. The menu is
configured in `source/nest/_data.yaml`: Overview, Patches, and GitHub Workflows.
Overview, Patches and GitHub Workflows retain their Markdown content. `/nest/` redirects to `/nest/overview/`.
Mobile section navigation is shared through the Jaspr menu component and
`source/scripts/section-navigation.js`.

The high-resolution Nest logo master is retained in
`design/logos/nest/nest-logo-v1.png`. The site serves the 66×72 transparent PNG at
`source/images/nest/nest-logo-66x72.png`, displayed in the same 33×36 desktop
and 28×31 mobile logo box as Flock. Regenerate it with
`dart run tools/export_nest_logo.dart` (after `dart pub get`). Nest's logo and title use
the shared brand component and page-heading spacing, without a divider or tagline.

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

## Migration verification

To compare a preserved older distribution against the current build, run
`dart run tools/check_migration.dart /path/to/previous-build`. This checks all
existing HTML routes by normalized DOM and compares stylesheet, script and
artwork bytes. Run `dart analyze bin lib test tools`, `dart test` and
`node --test test/hero_glow_test.cjs` for the maintained checks.

Jaspr’s debug renderer may print a missing `.client.dart` warning. This site
intentionally has no Jaspr client entrypoint; its existing JavaScript modules
provide all interactive behavior. No client bundle is missing.
