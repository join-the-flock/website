/// Compare a preserved pre-migration distribution with a freshly built site.
/// Usage: dart run tools/check_migration.dart /path/to/baseline
import 'dart:io';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:path/path.dart' as p;

void main(List<String> args) {
  if (args.length != 1) throw ArgumentError('Supply the baseline directory.');
  final differences = <String>[];
  var count = 0;
  String normalize(Node n) {
    if (n is Comment || n is DocumentType) return '';
    if (n is Text) return n.data.replaceAll(RegExp(r'\s+'), ' ').trim();
    final attributes = n is Element
        ? (n.attributes.entries.map((a) => '${a.key}=${a.value}').toList()
                ..sort())
              .join('|')
        : '';
    return '<${n is Element ? n.localName : 'document'} $attributes>${n.nodes.map(normalize).where((v) => v.isNotEmpty).join()}</>';
  }

  for (final file in Directory(
    args.single,
  ).listSync(recursive: true).whereType<File>()) {
    final relative = p.relative(file.path, from: args.single);
    final target = File('build/$relative');
    if (!target.existsSync()) {
      differences.add('Missing $relative');
      continue;
    }
    if (relative.endsWith('.html')) {
      count++;
      final before = normalize(parse(file.readAsStringSync()));
      final after = normalize(parse(target.readAsStringSync()));
      if (before != after) {
        var i = 0;
        while (i < before.length && i < after.length && before[i] == after[i]) {
          i++;
        }
        final start = i > 100 ? i - 100 : 0;
        differences.add(
          '$relative at $i\nBEFORE ${before.substring(start, (i + 250).clamp(0, before.length))}\nAFTER ${after.substring(start, (i + 250).clamp(0, after.length))}',
        );
      }
    } else if (relative != 'rss_feed.xml' && !sameBytes(file, target)) {
      differences.add('Changed asset: $relative');
    }
  }
  if (differences.isNotEmpty) {
    stderr.writeln(differences.join('\n'));
    exitCode = 1;
  } else {
    stdout.writeln(
      '$count pages match the baseline DOM; all styles, scripts and artwork are byte-identical.',
    );
  }
}

bool sameBytes(File a, File b) {
  final x = a.readAsBytesSync(), y = b.readAsBytesSync();
  if (x.length != y.length) return false;
  for (var i = 0; i < x.length; i++) {
    if (x[i] != y[i]) return false;
  }
  return true;
}
