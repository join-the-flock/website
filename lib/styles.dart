import 'package:sass/sass.dart' as sass;

/// The existing styles use SCSS syntax in both .sass and .scss files.
class SiteStyles extends sass.Importer {
  final sources = <String, String>{};
  @override
  Uri? canonicalize(Uri url) => Uri(scheme: 'site', path: url.path);
  @override
  sass.ImporterResult? load(Uri url) {
    final content =
        sources[url.path] ??
        sources['${url.path}.scss'] ??
        sources['${url.path}.sass'];
    return content == null
        ? null
        : sass.ImporterResult(content, syntax: sass.Syntax.scss);
  }
}
