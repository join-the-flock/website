import 'dart:convert';
import 'dart:io';

import 'package:flock_website/site.dart';
import 'package:html/parser.dart';
import 'package:jaspr/server.dart';
import 'package:test/test.dart';

import '../bin/main.dart' show writeRss;

void main() {
  final pages = loadPages();
  setUpAll(Jaspr.initializeApp);

  test('all public routes are unique, including legacy redirects', () {
    expect(pages.length, 21);
    expect(pages.map((p) => p.path).toSet().length, pages.length);
    expect(pages.where((p) => p.data['layout'] == 'redirect').length, 4);
    expect(pages.where((p) => p.data['layout'] == 'post').length, 8);
  });

  test('section pages inherit their menus and preserve Markdown code', () {
    final page = pages.singleWhere((p) => p.path == '/flock/get-started/');
    expect(page.data['show_hero'], true);
    expect((page.data['side_menu'] as Map)['base_path'], '/flock');
    expect(parse(page.content).querySelectorAll('pre code').length, 3);
    expect(parse(page.content).querySelector('h1')?.text, 'Get Started');
  });

  test(
    'Jaspr preserves document metadata, navigation and card geometry hooks',
    () async {
      final page = pages.singleWhere((p) => p.path == '/');
      final commit = {
        'sha': 'example',
        'url': 'https://github.com/example/commit/1',
        'message': '<script> & "quoted"',
        'authorName': 'Example',
        'authoredAt': '2026-11-06T00:00:00Z',
      };
      final result = await renderComponent(
        Website(page, pages, {
          'flock': [commit, commit],
          'flutter': [commit],
        }),
        standalone: true,
      );
      final document = parse(utf8.decode(result.body));
      expect(
        document.querySelector('head meta[property="og:image"]'),
        isNotNull,
      );
      expect(document.querySelectorAll('.stack .commit').length, 2);
      expect(document.querySelectorAll('.stack .commit[hidden]').length, 1);
      expect(document.querySelector('.commit h2')?.text, commit['message']);
      expect(document.querySelectorAll('.commit script'), isEmpty);
      expect(document.querySelector('.brand')?.attributes['href'], '/');
      expect(document.querySelectorAll('.nav-links a').length, 4);
      expect(document.querySelectorAll('site-homehero'), isEmpty);
    },
  );

  test('RSS preserves its public URL with valid absolute article links', () {
    final file = File('build/rss_feed.xml');
    final previous = file.existsSync() ? file.readAsBytesSync() : null;
    try {
      Directory('build').createSync();
      writeRss(pages);
      final rss = file.readAsStringSync();
      expect(RegExp('<item>').allMatches(rss).length, 8);
      expect(rss, contains('https://getflocked.dev/blog/posts/'));
      expect(rss, isNot(contains('blog///')));
    } finally {
      if (previous != null) {
        file.writeAsBytesSync(previous);
      } else {
        file.deleteSync();
      }
    }
  });
}
