/// Keep editable originals and superseded artwork in source, not in deployment.
class UnpublishedArtworkExcluder {
  const UnpublishedArtworkExcluder();

  bool shouldExclude(String path) {
    final value = path.replaceAll('\\', '/');
    if (_artworkDirectories.any(value.startsWith)) {
      return !_publishedArtwork.contains(value);
    }
    return _retiredImages.contains(value);
  }
}

const _artworkDirectories = [
  'images/hero/',
  'images/features/',
  'images/flock/',
  'images/nest/',
];

// Update this list when selecting new artwork for a public page.
const _publishedArtwork = {
  'images/hero/fleek-embracing-optimized.webp',
  'images/hero/commit-circuits.svg',
  'images/features/activity-ribbon-v4-optimized.webp',
  'images/flock/dash-exhausted.webp',
  'images/flock/fleek-right.webp',
  'images/flock/fleek-left-complete.webp',
  'images/flock/fleek-leader-complete.webp',
  'images/flock/storm-wall.webp',
  'images/nest/nest-with-eggs.webp',
  'images/nest/nest-logo-66x72.png',
};

const _retiredImages = {
  'images/flock-nav-logo.png',
  'images/flock_social-media.png',
  'images/nest_social-media.png',
};
