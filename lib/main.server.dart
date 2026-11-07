import 'dart:io';

import 'package:flock_website/site.dart';
import 'package:jaspr/server.dart';
import 'package:path/path.dart' as p;
import 'package:sass/sass.dart' as sass;

import 'styles.dart';
import 'public_assets.dart';
import 'recent_commits.dart';

/// Jaspr CLI entrypoint. Content and assets are read from source so edits do
/// not require refreshing the GitHub commit snapshot.
Future<void> main() async {
  await prepareRecentCommits();
  Jaspr.initializeApp();
  ServerApp.addMiddleware(
    (handler) => (request) async {
      final path = p.normalize(Uri.decodeComponent(request.url.path));
      if (p.isAbsolute(path) || path == '..' || path.startsWith('../')) {
        return Response.notFound('Not found');
      }
      if (path.startsWith('styles/') && path.endsWith('.css')) {
        final importer = SiteStyles();
        for (final file in Directory(
          'source/styles',
        ).listSync().whereType<File>()) {
          if (['.sass', '.scss'].contains(p.extension(file.path))) {
            importer.sources[p.basename(file.path)] = file.readAsStringSync();
          }
        }
        final stem = p.basenameWithoutExtension(path);
        final source =
            importer.sources['$stem.scss'] ?? importer.sources['$stem.sass'];
        if (source != null) {
          return Response.ok(
            sass.compileStringToResult(source, importer: importer).css,
            headers: {'content-type': 'text/css'},
          );
        }
      }
      if (['images/', 'scripts/', 'data/'].any(path.startsWith)) {
        final file = File('source/$path');
        if (const UnpublishedArtworkExcluder().shouldExclude(path) ||
            !file.existsSync()) {
          return Response.notFound('Not found');
        }
        const types = {
          '.js': 'application/javascript',
          '.json': 'application/json',
          '.webp': 'image/webp',
          '.png': 'image/png',
          '.jpg': 'image/jpeg',
          '.jpeg': 'image/jpeg',
          '.svg': 'image/svg+xml',
          '.ico': 'image/x-icon',
          '.webmanifest': 'application/manifest+json',
          '.xml': 'application/xml',
        };
        return Response.ok(
          file.openRead(),
          headers: {
            'content-type':
                types[p.extension(path)] ?? 'application/octet-stream',
          },
        );
      }
      return handler(request);
    },
  );
  runApp(const SiteApplication());
}

class SiteApplication extends StatelessComponent {
  const SiteApplication({super.key});

  @override
  Component build(BuildContext context) {
    final pages = loadPages();
    if (kGenerateMode) {
      for (final page in pages) {
        ServerApp.requestRouteGeneration(page.path);
      }
    }
    final requested = Uri.parse(context.url).path;
    final path = requested.endsWith('/') ? requested : '$requested/';
    for (final page in pages) {
      if (page.path == path) return Website(page, pages, loadCommits());
    }
    context.setStatusCode(404);
    return Component.text('Page not found');
  }
}
