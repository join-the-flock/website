import 'dart:io';

import 'package:args/args.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

import 'image_utils.dart';

class ImageExport {
  const ImageExport(this.group, this.source, this.output,
      {this.width,
      this.height,
      this.quality = 92,
      this.branding = false,
      this.lossless = false});
  final String group, source, output;
  final int? width, height;
  final int quality;
  final bool branding, lossless;
}

// Current artwork only. Exact sprite sizes match the live SVG coordinates.
const exports = <ImageExport>[
  ImageExport('homepage', 'hero/fleek-embracing.png',
      'hero/fleek-embracing-optimized.webp'),
  ImageExport('homepage', 'features/activity-ribbon-v4.png',
      'features/activity-ribbon-v4-optimized.webp',
      width: 920, quality: 90),
  ImageExport('nest', 'nest/nest-with-eggs.png', 'nest/nest-with-eggs.webp'),
  ImageExport('flock', 'flock/storm-wall.png', 'flock/storm-wall.webp',
      width: 1800, quality: 86),
  ImageExport('flock', 'flock/dash-exhausted.png', 'flock/dash-exhausted.webp',
      width: 600),
  ImageExport('flock', 'flock/fleek-right.png', 'flock/fleek-right.webp',
      lossless: true),
  ImageExport('flock', 'flock/fleek-left-complete.png',
      'flock/fleek-left-complete.webp',
      width: 511, height: 390),
  ImageExport('flock', 'flock/fleek-leader-complete.png',
      'flock/fleek-leader-complete.webp',
      width: 1185, height: 570),
  ImageExport('about', 'creators/creators-in-chairs-with-fleek_close-up.jpeg',
      'about/creators-in-chairs.webp',
      width: 1920, quality: 88, branding: true),
  ImageExport('blog', 'fleek/fleek-at-desk-typing_cyberpunk_illustrated.jpeg',
      'blog/fleek-at-desk-typing.webp',
      width: 1920, quality: 88, branding: true),
  ImageExport('sharing', 'flock-social-hero.png', 'flock-social-hero.jpg',
      quality: 90),
  ImageExport('avatars', 'team/matt-carroll.jpg', 'team/matt-carroll-192.webp',
      width: 192, quality: 88),
  ImageExport('avatars', 'team/jesse-ezell.jpg', 'team/jesse-ezell-192.webp',
      width: 192, quality: 88),
];

void exportImage(ImageExport spec, String source, String output) {
  var image = readImage(source);
  if (spec.width != null &&
      (spec.height != null || image.width > spec.width!)) {
    final height =
        spec.height ?? (image.height * spec.width! / image.width).round();
    image = img.copyResize(image,
        width: spec.width,
        height: height,
        interpolation: img.Interpolation.cubic);
  }
  final bytes = p.extension(output) == '.jpg'
      ? img.encodeJpg(image.convert(numChannels: 3),
          quality: spec.quality, chroma: img.JpegChroma.yuv420)
      : img.encodeWebP(image,
          lossless: spec.lossless,
          quality: spec.quality,
          method: 6,
          alphaQuality: 100,
          exact: true);
  writeAsset(output, bytes);
  print(
      '${spec.output}: ${image.width}×${image.height}, ${File(source).lengthSync()} → ${bytes.length} bytes');
}

Future<void> main(List<String> arguments) => runTool(() async {
      final groups = exports.map((spec) => spec.group).toSet().toList()..sort();
      final parser = ArgParser()
        ..addMultiOption('only',
            allowed: groups, help: 'Export selected groups (default: all)')
        ..addOption('branding-dir',
            defaultsTo: p.join(p.dirname(websiteRoot), 'branding'))
        ..addOption('output-dir', defaultsTo: assetPath(''))
        ..addFlag('list',
            negatable: false,
            help: 'List selected inputs/outputs without writing')
        ..addFlag('help', abbr: 'h', negatable: false);
      final args = parser.parse(arguments);
      if (args['help'] as bool) {
        print(parser.usage);
        return;
      }
      if (args.rest.isNotEmpty && !args.wasParsed('only')) {
        throw const FormatException('Select groups with --only');
      }
      final selected = <String>{...args['only'] as List<String>, ...args.rest};
      if (selected.any((group) => !groups.contains(group))) {
        throw FormatException(
            'Unknown export group. Choose: ${groups.join(', ')}');
      }
      final jobs = [
        for (final spec in exports)
          if (selected.isEmpty || selected.contains(spec.group))
            (
              spec,
              p.join(
                  spec.branding
                      ? args['branding-dir'] as String
                      : assetPath(''),
                  spec.source),
              p.join(args['output-dir'] as String, spec.output)
            )
      ];
      if (args['list'] as bool) {
        for (final (spec, source, output) in jobs) {
          print('${spec.group}: $source → $output');
        }
        return;
      }
      final missing = [
        for (final (_, source, _) in jobs)
          if (!File(source).existsSync()) source
      ];
      if (missing.isNotEmpty) {
        throw FormatException(
            'Missing originals:\n${missing.join('\n')}\nUse --branding-dir or --only. No images were exported.');
      }
      for (final (_, source, output) in jobs) {
        protectOriginal(source, output);
      }
      for (final (spec, source, output) in jobs) {
        exportImage(spec, source, output);
      }
    });
