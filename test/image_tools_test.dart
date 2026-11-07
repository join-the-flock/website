import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../tools/generate_favicons.dart' show safariMask;
import '../tools/image_utils.dart';
import '../tools/optimize_images.dart' show ImageExport, exportImage;

void main() {
  late Directory temporary;
  setUp(() =>
      temporary = Directory.systemTemp.createTempSync('flock-image-tools-'));
  tearDown(() => temporary.deleteSync(recursive: true));

  test('visible crop ignores alpha noise and preserves transparent canvas', () {
    final image = img.Image(width: 10, height: 10, numChannels: 4);
    image.setPixelRgba(0, 0, 255, 0, 0, 1);
    image.setPixelRgba(4, 5, 255, 20, 100, 255);
    final cropped = cropVisible(image, padding: 2);
    expect([cropped.width, cropped.height], [5, 5]);
    final canvas = centeredCanvas(cropped, 66, 72);
    expect(canvas.getPixel(0, 0).a, 0);
    expect(canvas.getPixel(32, 35).a, 255);
    expect(() => cropVisible(img.Image(width: 2, height: 2, numChannels: 4)),
        throwsFormatException);
    expect(fitWithin(cropped, 100, 100).width, 5);
  });

  test('lossy WebP retains source alpha and exact sprite geometry', () {
    final source = p.join(temporary.path, 'source.png');
    final target = p.join(temporary.path, 'sprite.webp');
    final image = img.Image(width: 8, height: 4, numChannels: 4);
    for (final pixel in image) {
      pixel.setRgba(248, 33, 126, pixel.x * 30);
    }
    writeAsset(source, img.encodePng(image));
    final original = File(source).readAsBytesSync();
    exportImage(
        const ImageExport('test', 'source.png', 'sprite.webp',
            width: 8, height: 4),
        source,
        target);
    final decoded = img.decodeWebP(File(target).readAsBytesSync())!;
    expect([decoded.width, decoded.height], [8, 4]);
    expect(decoded.map((pixel) => pixel.a).toList(),
        image.map((pixel) => pixel.a).toList());
    expect(File(source).readAsBytesSync(), original);
  });

  test('Safari mask has geometry for opaque artwork only', () {
    final image = img.Image(width: 3, height: 2, numChannels: 4);
    image.setPixelRgba(1, 0, 0, 0, 0, 255);
    image.setPixelRgba(2, 1, 0, 0, 0, 100);
    expect(safariMask(image), contains('viewBox="0 0 3 2"'));
    expect(safariMask(image), contains('d="M1 0h1v1h-1z"'));
  });

  test('export preflight rejects missing inputs without partial writes',
      () async {
    final output = p.join(temporary.path, 'outputs');
    final result = await Process.run(Platform.resolvedExecutable, [
      'run',
      'tools/optimize_images.dart',
      '--only',
      'homepage',
      'about',
      '--branding-dir',
      p.join(temporary.path, 'missing'),
      '--output-dir',
      output,
    ]);
    expect(result.exitCode, 64);
    expect(result.stderr, contains('Missing originals'));
    expect(Directory(output).existsSync(), isFalse);
  });

  test(
      'favicon CLI exports transparent PNGs, opaque app icons and multi-size ICO',
      () async {
    final source = p.join(temporary.path, 'logo.png');
    final output = p.join(temporary.path, 'icons');
    final logo = img.Image(width: 12, height: 8, numChannels: 4);
    img.fillRect(logo,
        x1: 2, y1: 2, x2: 9, y2: 5, color: img.ColorRgba8(248, 33, 126, 255));
    writeAsset(source, img.encodePng(logo));
    final result = await Process.run(Platform.resolvedExecutable, [
      'run',
      'tools/generate_favicons.dart',
      '--source',
      source,
      '--output-dir',
      output
    ]);
    expect(result.exitCode, 0, reason: '${result.stderr}');
    final png = readImage(p.join(output, 'favicon-32x32.png'));
    expect([png.width, png.height], [32, 32]);
    expect(png.getPixel(0, 0).a, 0);
    final apple = readImage(p.join(output, 'apple-touch-icon.png'));
    expect([
      apple.getPixel(0, 0).r,
      apple.getPixel(0, 0).g,
      apple.getPixel(0, 0).b
    ], [
      13,
      9,
      18
    ]);
    final ico = File(p.join(output, 'favicon.ico')).readAsBytesSync();
    final header = ByteData.sublistView(ico);
    expect(header.getUint16(2, Endian.little), 1);
    expect(header.getUint16(4, Endian.little), 4);
    expect([for (var frame = 0; frame < 4; frame++) ico[6 + frame * 16]],
        [16, 32, 48, 64]);
    expect(File(p.join(output, 'site.webmanifest')).existsSync(), isTrue);
    expect(File(p.join(output, 'safari-pinned-tab.svg')).existsSync(), isTrue);
    expect(() => protectOriginal(source, source), throwsFormatException);
  });
}
