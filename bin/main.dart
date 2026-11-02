import 'dart:convert';
import 'dart:io';

import 'package:static_shock/static_shock.dart';

import 'recent_commits.dart';

Future<void> main(List<String> arguments) async {
  if (arguments.contains('--cached-commits')) {
    if (!await File('source/data/recent-commits.json').exists()) {
      throw StateError('No cached commit snapshot. Build without --cached-commits first.');
    }
  } else {
    await fetchRecentCommits();
  }

  // Configure the static website generator.
  final staticShock = StaticShock()
    // Here, you can directly hook into the StaticShock pipeline. For example,
    // you can copy an "images" directory from the source set to build set:
    ..pick(ExtensionPicker("html"))
    ..pick(ExtensionPicker("jpeg"))
    ..pick(DirectoryPicker.parse("images"))
    ..pick(DirectoryPicker.parse("data"))
    ..pick(DirectoryPicker.parse("scripts"))
    ..loadData(DataLoader.fromFunction((context) async => {
      'recent_commits': jsonDecode(await File('source/data/recent-commits.json').readAsString()),
    }))
    // All 3rd party behavior is added through plugins, even the behavior
    // shipped with Static Shock.
    ..plugin(const MarkdownPlugin())
    ..plugin(const JinjaPlugin())
    ..plugin(const PrettyUrlsPlugin())
    ..plugin(const RedirectsPlugin())
    ..plugin(const SassPlugin())
    ..plugin(DraftingPlugin(
      showDrafts: arguments.contains("preview"),
    ))
    ..plugin(RssPlugin(
      site: RssSiteConfiguration(
        title: "Flock and Nest",
        description: "By the Flutter community, for the Flutter community.",
        homePageUrl: "https://getflocked.dev/blog/",
      ),
      pageToRssItemMapper: (RssSiteConfiguration config, Page page) {
        return defaultPageToRssItemMapper(config, page)?.copyWith(
          author: page.data["author"]?["name"] ?? "",
        );
      },
    ));

  // Generate the static website.
  await staticShock.generateSite();
}
