import 'dart:convert';
import 'dart:io';

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html;
import 'package:jaspr/server.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:yaml/yaml.dart';

import 'page_markup.dart';

/// A content page, independent of the rendering framework's route lifecycle.
class SitePage {
  SitePage(this.path, this.data, this.content);
  final String path;
  final Map<String, dynamic> data;
  final String content;
}

Map<String, dynamic> yamlMap(String input) =>
    Map<String, dynamic>.from(loadYaml(input) ?? {});

List<SitePage> loadPages({bool preview = false}) {
  final pages = <SitePage>[];
  for (final file in Directory(
    'source',
  ).listSync(recursive: true).whereType<File>()) {
    final relative = file.path.substring('source/'.length);
    if (relative.startsWith('_') ||
        !(relative.endsWith('.md') || relative.endsWith('.page.yaml'))) {
      continue;
    }
    var text = file.readAsStringSync();
    final match = RegExp(
      r'^(?:---\r?\n([\s\S]*?)\r?\n---|<!--\r?\n([\s\S]*?)-->)\s*',
    ).firstMatch(text);
    final data = <String, dynamic>{};
    var directory = File(file.path).parent;
    final inherited = <Map<String, dynamic>>[];
    while (directory.path != '.' && directory.path.startsWith('source')) {
      final defaults = File('${directory.path}/_data.yaml');
      if (defaults.existsSync()) {
        inherited.insert(0, yamlMap(defaults.readAsStringSync()));
      }
      directory = directory.parent;
    }
    for (final defaults in inherited) {
      data.addAll(defaults);
    }
    if (relative.endsWith('.page.yaml')) {
      data.addAll(yamlMap(text));
      text = '';
    } else if (match != null) {
      data.addAll(yamlMap(match[1] ?? match[2]!));
      text = text.substring(match.end);
    }
    if (!preview && data['draft'] == true) continue;
    final stem = relative.replaceFirst(RegExp(r'(\.md|\.page\.yaml)$'), '');
    final url = stem == 'index'
        ? '/'
        : '/${stem.endsWith('/index') ? stem.substring(0, stem.length - 5) : '$stem/'}';
    data['url'] = url;
    final content = relative.endsWith('.md')
        ? md.markdownToHtml(
            text,
            blockSyntaxes: [const md.HeaderWithIdSyntax()],
          )
        : text;
    pages.add(SitePage(url, data, content));
  }
  return pages;
}

/// Server-rendered Jaspr page. Existing JavaScript owns the progressive
/// enhancements, so navigation and animation behavior do not change.
class Website extends StatelessComponent {
  const Website(this.page, this.pages, this.commits, {super.key});
  final SitePage page;
  final List<SitePage> pages;
  final Map<String, dynamic> commits;

  @override
  Component build(BuildContext context) {
    final data = page.data;
    final layout = data['layout'] as String? ?? '';
    final markup = page.path == '/'
        ? homeMarkup(data)
        : page.path == '/blog/'
        ? blogMarkup(data)
        : switch (layout) {
            'guide' => guideMarkup(data),
            'nest' => nestMarkup(data),
            'post' => postMarkup(data),
            'redirect' => redirectMarkup(data),
            _ => pageMarkup(data),
          };
    final document = html.parse(markup);
    return _node(document.documentElement!);
  }

  Component _node(dom.Node node) {
    if (node is dom.Text) return Component.text(node.data);
    if (node is! dom.Element) return const Component.fragment([]);
    final slot = node.localName!;
    if (slot.startsWith('site-')) {
      return switch (slot) {
        'site-content' => _fragment(page.content),
        'site-navbar' => _nav(),
        'site-footer' => _fragment(footerMarkup(page.data)),
        'site-socialimage' => _fragment(socialMarkup(page.data)),
        'site-homefeatures' => _fragment(featuresMarkup(page.data)),
        'site-homehero' => _hero(),
        'site-brand' => _brand(section: page.path.startsWith('/nest/')),
        'site-sectionnav' => _menu(mobile: true),
        'site-sidemenu' => _menu(mobile: false),
        'site-posts' => _posts(),
        _ => throw StateError('Unknown page slot: $slot'),
      };
    }
    return Component.element(
      tag: slot,
      attributes: Map<String, String>.from(node.attributes),
      children: node.nodes.map(_node).toList(),
    );
  }

  Component _fragment(String source) =>
      Component.fragment(html.parseFragment(source).nodes.map(_node).toList());

  Component _brand({bool section = false, bool tagline = false}) {
    final name = section ? 'Nest' : 'Flock';
    return _fragment(
      '<a class="brand" href="${section ? '/nest/overview' : '/'}" aria-label="$name home">'
      '<img src="${section ? '/images/nest/nest-logo-66x72.png' : '/images/flock-nav-logo-66x72.png'}" width="33" height="36" alt="">'
      '<span>$name</span>${tagline ? '<span class="brand-tagline"><span aria-hidden="true">|</span> Flutter++</span>' : ''}</a>',
    );
  }

  Component _nav() => Component.element(
    tag: 'header',
    attributes: {'class': 'site-header'},
    children: [
      Component.element(
        tag: 'nav',
        attributes: {'class': 'site-nav', 'aria-label': 'Main navigation'},
        children: [
          _brand(tagline: true),
          Component.element(
            tag: 'div',
            attributes: {'class': 'nav-links'},
            children: [
              for (final entry in {
                'Flock': '/flock/get-started',
                'Nest': '/nest/overview',
                'Blog': '/blog',
                'About': '/about',
              }.entries)
                Component.element(
                  tag: 'a',
                  attributes: {
                    'href': entry.value,
                    if (page.path.startsWith('/${entry.key.toLowerCase()}/'))
                      'aria-current': entry.key == 'About' ? 'page' : 'true',
                  },
                  children: [Component.text(entry.key)],
                ),
            ],
          ),
        ],
      ),
    ],
  );

  Component _menu({required bool mobile}) {
    final menu = page.data['side_menu'] as Map;
    final base = menu['base_path'];
    final links = <Component>[
      for (final item in menu['items'] as List)
        Component.element(
          tag: 'a',
          attributes: {
            'href': '$base/${item['id']}',
            if (mobile && page.path == '$base/${item['id']}/')
              'aria-current': 'page',
            if (!mobile)
              'class':
                  'button ${page.path == '$base/${item['id']}/' ? 'active' : ''}',
            if (!mobile) 'role': 'button',
          },
          children: [Component.text('${item['title']}')],
        ),
    ];
    return mobile
        ? Component.element(
            tag: 'nav',
            attributes: {
              'class': 'mobile-section-nav',
              'aria-label': '${base == '/nest' ? 'Nest' : 'Flock'} sections',
            },
            children: [
              Component.element(
                tag: 'div',
                attributes: {'class': 'section-nav-links'},
                children: links,
              ),
            ],
          )
        : Component.fragment(links);
  }

  Component _posts() {
    final posts = pages.where((p) => p.path.startsWith('/blog/posts/')).toList()
      ..sort(
        (a, b) =>
            '${b.data['publishDate']}'.compareTo('${a.data['publishDate']}'),
      );
    return Component.fragment([
      for (final post in posts)
        _fragment(
          '''<li><a href="${post.path}"><div class="post-synopsis"><div class="content">
      <span class="publish-date above">${date(post.data['publishDate'])}</span>
      <h2 class="title">${escape(post.data['title'])}</h2><p class="description">${escape(post.data['description'])}</p>
      <p><span class="permalink">${post.path}</span></p></div></div></a></li>''',
        ),
    ]);
  }

  Component _hero() => Component.element(
    tag: 'section',
    attributes: {
      'class': 'hero',
      'aria-label': 'Flock patches built on Flutter commits',
    },
    children: [
      _nav(),
      Component.element(
        tag: 'canvas',
        attributes: {'id': 'plume', 'aria-hidden': 'true'},
      ),
      Component.element(
        tag: 'div',
        attributes: {'class': 'scene'},
        children: [
          Component.element(
            tag: 'div',
            attributes: {'class': 'flock'},
            children: [
              _fragment(
                '<img class="fleek" src="/images/hero/fleek-embracing-optimized.webp" alt="" width="1560" height="1008" fetchpriority="high">',
              ),
              Component.element(
                tag: 'div',
                attributes: {'class': 'stack'},
                children: [
                  for (final (index, commit)
                      in (commits['flock'] as List).take(4).indexed)
                    _commit(commit as Map, patch: true, hidden: index > 0),
                ],
              ),
            ],
          ),
          Component.element(
            tag: 'div',
            attributes: {'class': 'flutter'},
            children: [
              for (final commit in (commits['flutter'] as List).take(3))
                _commit(commit as Map),
            ],
          ),
        ],
      ),
    ],
  );

  Component _commit(
    Map commit, {
    bool patch = false,
    bool hidden = false,
  }) => Component.element(
    tag: 'article',
    attributes: {
      'class': patch ? 'commit patch' : 'commit',
      'data-sha': '${commit['sha']}',
      if (hidden) 'hidden': '',
    },
    children: [
      _fragment(
        '''<h2><a href="${escape(commit['url'])}">${escape(commit['message'])}</a></h2>
      <p><span class="avatar" aria-hidden="true">${commit['avatarUrl'] != null && commit['avatarUrl'] != '' ? '<img src="${escape(commit['avatarUrl'])}" alt="" width="29" height="29">' : 'F'}</span><span><strong>${escape(commit['authorLogin'] ?? commit['authorName'])}</strong> authored <time datetime="${escape(commit['authoredAt'])}">${escape(commit['authoredAt'])}</time></span></p>''',
      ),
    ],
  );
}

Map<String, dynamic> loadCommits() => Map<String, dynamic>.from(
  jsonDecode(File('source/data/recent-commits.json').readAsStringSync()) as Map,
);
