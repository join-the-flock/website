import 'dart:convert';
import 'dart:io';

import 'package:jaspr/server.dart';
import 'package:path/path.dart' as p;
import 'package:sass/sass.dart' as sass;
import 'package:flock_website/styles.dart';

import 'package:flock_website/site.dart';
import 'public_assets.dart';
import 'recent_commits.dart';

/// Pre-render every public URL with Jaspr. No client runtime is needed: the
/// site's existing scripts progressively enhance the rendered documents.
Future<void> main(List<String> arguments) async {
  await prepareRecentCommits(
    cachedOnly: arguments.contains('--cached-commits'),
    refresh: arguments.contains('--refresh-commits'),
  );
  final pages = loadPages(preview: arguments.contains('preview'));
  final commits = loadCommits();
  final destination = Directory('build');
  if (destination.existsSync()) destination.deleteSync(recursive: true);
  destination.createSync();
  Jaspr.initializeApp();
  for (final page in pages) {
    final response = await renderComponent(
      Website(page, pages, commits),
      standalone: true,
    );
    if (response.statusCode != 200) {
      throw StateError('Failed to render ${page.path}');
    }
    final target = File('build${page.path}index.html');
    target.parent.createSync(recursive: true);
    target.writeAsStringSync('<!doctype html>\n${utf8.decode(response.body)}');
  }
  final importer = SiteStyles();
  for (final file in Directory('source/styles').listSync().whereType<File>()) {
    if (!['.sass', '.scss'].contains(p.extension(file.path))) continue;
    importer.sources[p.basename(file.path)] = file.readAsStringSync();
  }
  for (final entry in importer.sources.entries) {
    final target = File(
      'build/styles/${p.basenameWithoutExtension(entry.key)}.css',
    );
    target.parent.createSync(recursive: true);
    target.writeAsStringSync(
      sass.compileStringToResult(entry.value, importer: importer).css,
    );
  }
  const excluder = UnpublishedArtworkExcluder();
  for (final file in Directory(
    'source',
  ).listSync(recursive: true).whereType<File>()) {
    final relative = p.relative(file.path, from: 'source');
    final publish =
        ['images/', 'data/', 'scripts/'].any(relative.startsWith) ||
        ['.html', '.jpeg'].contains(p.extension(relative));
    if (!publish || excluder.shouldExclude(relative)) continue;
    final target = File('build/$relative');
    target.parent.createSync(recursive: true);
    file.copySync(target.path);
  }
  writeRss(pages);
  stdout.writeln('Jaspr rendered ${pages.length} pages to build/.');
}

void writeRss(List<SitePage> pages) {
  final posts = pages.where((p) => p.path.startsWith('/blog/posts/')).toList()
    ..sort(
      (a, b) =>
          '${b.data['publishDate']}'.compareTo('${a.data['publishDate']}'),
    );
  String xml(Object? value) => const HtmlEscape().convert('$value');
  final items = posts
      .map(
        (post) =>
            '''<item><title>${xml(post.data['title'])}</title>
<link>https://getflocked.dev${post.path}</link><description>${xml(post.data['description'])}</description>
<author>${xml((post.data['author'] as Map?)?['name'] ?? '')}</author>
<guid>https://getflocked.dev${post.path}</guid>
<pubDate>${HttpDate.format(DateTime.parse('${post.data['publishDate']}').toUtc())}</pubDate></item>''',
      )
      .join('\n');
  File('build/rss_feed.xml').writeAsStringSync(
    '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0"><channel><title>Flock and Nest</title><link>https://getflocked.dev/blog/</link>
<description>By the Flutter community, for the Flutter community.</description>$items</channel></rss>''',
  );
}
