import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:args/args.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

import 'image_utils.dart';

const backgroundHex = '#0d0912';

img.Image icon(img.Image logo, int size,
    {double inset = .06, bool opaque = false}) {
  final edge = size - 2 * math.max(1, (size * inset).round()).toInt();
  return centeredCanvas(fitWithin(logo, edge, edge), size, size,
      background: opaque ? img.ColorRgba8(13, 9, 18, 255) : null);
}

String safariMask(img.Image image) {
  final active = <(int, int), int>{};
  final paths = <String>[];
  for (var y = 0; y <= image.height; y++) {
    final runs = <(int, int)>{};
    var x = 0;
    while (y < image.height && x < image.width) {
      if (image.getPixel(x, y).a < 128) {
        x++;
        continue;
      }
      final start = x;
      while (x < image.width && image.getPixel(x, y).a >= 128) {
        x++;
      }
      runs.add((start, x));
    }
    for (final run in active.keys.toList()) {
      if (runs.contains(run)) continue;
      final top = active.remove(run)!;
      final width = run.$2 - run.$1;
      paths.add('M${run.$1} ${top}h${width}v${y - top}h${-width}z');
    }
    for (final run in runs) {
      active.putIfAbsent(run, () => y);
    }
  }
  return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${image.width} ${image.height}"><path fill="#000" d="${paths.join(' ')}"/></svg>\n';
}

Future<void> main(List<String> arguments) => runTool(() async {
      final parser = ArgParser()
        ..addOption('source', defaultsTo: assetPath('flock-nav-logo.png'))
        ..addOption('output-dir', defaultsTo: assetPath('favicon'))
        ..addFlag('help', abbr: 'h', negatable: false);
      final args = parser.parse(arguments);
      if (args['help'] as bool) {
        print(parser.usage);
        return;
      }
      if (args.rest.isNotEmpty) {
        throw const FormatException('Unexpected positional arguments');
      }
      final logo =
          cropVisible(readImage(args['source'] as String), threshold: 128);
      final destination = args['output-dir'] as String;
      for (final name in [
        'favicon-16x16.png',
        'favicon-32x32.png',
        'favicon.ico',
        'apple-touch-icon.png',
        'android-chrome-192x192.png',
        'android-chrome-512x512.png',
        'mstile-150x150.png'
      ]) {
        protectOriginal(args['source'] as String, p.join(destination, name));
      }
      void png(String name, img.Image image) =>
          writeAsset(p.join(destination, name), img.encodePng(image, level: 9));
      for (final size in [16, 32]) {
        png('favicon-${size}x$size.png', icon(logo, size));
      }
      writeAsset(
          p.join(destination, 'favicon.ico'),
          img.IcoEncoder().encodeImages([
            for (final size in [16, 32, 48, 64]) icon(logo, size)
          ]));
      png('apple-touch-icon.png',
          icon(logo, 180, inset: .10, opaque: true).convert(numChannels: 3));
      for (final size in [192, 512]) {
        png('android-chrome-${size}x$size.png', icon(logo, size));
      }
      png('mstile-150x150.png',
          icon(logo, 150, inset: .10, opaque: true).convert(numChannels: 3));
      Directory(destination).createSync(recursive: true);
      File(p.join(destination, 'safari-pinned-tab.svg'))
          .writeAsStringSync(safariMask(icon(logo, 512)));
      final manifest = {
        'name': 'Flock',
        'short_name': 'Flock',
        'icons': [
          for (final size in [192, 512])
            {
              'src': '/images/favicon/android-chrome-${size}x$size.png',
              'sizes': '${size}x$size',
              'type': 'image/png'
            }
        ],
        'theme_color': backgroundHex,
        'background_color': backgroundHex,
        'display': 'standalone'
      };
      File(p.join(destination, 'site.webmanifest')).writeAsStringSync(
          '${const JsonEncoder.withIndent('  ').convert(manifest)}\n');
      File(p.join(destination, 'browserconfig.xml')).writeAsStringSync(
          '<?xml version="1.0" encoding="utf-8"?>\n<browserconfig><msapplication><tile><square150x150logo src="/images/favicon/mstile-150x150.png"/><TileColor>$backgroundHex</TileColor></tile></msapplication></browserconfig>\n');
      print('Exported favicons to $destination');
    });
