import 'dart:io';

import 'package:test/test.dart';

import '../bin/public_assets.dart';

void main() {
  const excluder = UnpublishedArtworkExcluder();
  bool excluded(String path) => excluder.shouldExclude(path);

  group('Published artwork >', () {
    test(
      'every image referenced by the actual site remains publishable',
      () async {
        final references = <String>{};
        final imageUrl = RegExp(r'''/images/[^\s"'()<>{}\[\]]+''');
        const textExtensions = [
          '.dart',
          '.md',
          '.scss',
          '.sass',
          '.js',
          '.yaml',
          '.webmanifest',
          '.xml',
        ];
        for (final root in ['source', 'lib']) {
          await for (final file in Directory(root).list(recursive: true)) {
            if (file is! File || !textExtensions.any(file.path.endsWith)) {
              continue;
            }
            for (final match in imageUrl.allMatches(
              await file.readAsString(),
            )) {
              references.add(match.group(0)!.substring(1));
            }
          }
        }
        expect(references.length, greaterThan(10));
        for (final path in references) {
          expect(File('source/$path').existsSync(), isTrue, reason: path);
          expect(
            excluded(path),
            isFalse,
            reason: 'Live reference excluded: $path',
          );
        }
      },
    );

    test('excludes originals, superseded variants and extraction metadata', () {
      for (final path in [
        'images/hero/fleek-embracing.png',
        'images/features/activity-ribbon-v1.png',
        'images/flock/fleek-leader-complete.png',
        'images/flock/fleek-leader.webp',
        'images/flock/fleeks-forward-v2.webp',
        'images/flock/fleek-formation.json',
        'images/nest/nest-with-eggs.png',
        'images/flock-nav-logo.png',
        'images/flock_social-media.png',
        'images/nest_social-media.png',
      ]) {
        expect(excluded(path), isTrue, reason: path);
      }
    });

    test(
      'preserves branding, social image, avatars, favicon and other assets',
      () {
        for (final path in [
          'images/flock-logo.png',
          'images/flock-nav-logo-66x72.png',
          'images/flock-social-hero.png',
          'images/nest-logo.png',
          'images/header-hr.png',
          'images/team/matt-carroll.jpg',
          'images/favicon/android-chrome-512x512.png',
          'images/favicon/site.webmanifest',
          'images/new-blog-illustration.png',
          'scripts/vendor/prism/prism-flock.min.js',
        ]) {
          expect(excluded(path), isFalse, reason: path);
        }
      },
    );
  });
}
