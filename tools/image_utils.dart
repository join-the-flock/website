import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

String get websiteRoot => File.fromUri(Platform.script).parent.parent.path;

Future<void> runTool(Future<void> Function() action) async {
  try {
    await action();
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    exitCode = 64;
  } on FileSystemException catch (error) {
    stderr.writeln(error);
    exitCode = 1;
  }
}

img.Image readImage(String path) {
  final decoded = img.decodeImage(File(path).readAsBytesSync());
  if (decoded == null) throw FormatException('Cannot decode image: $path');
  return img.bakeOrientation(decoded).convert(numChannels: 4);
}

void writeAsset(String path, List<int> bytes) {
  final file = File(path)..parent.createSync(recursive: true);
  file.writeAsBytesSync(bytes);
}

void protectOriginal(String source, String output) {
  String resolved(String path) => File(path).existsSync()
      ? File(path).resolveSymbolicLinksSync()
      : p.canonicalize(path);
  if (p.equals(resolved(source), resolved(output))) {
    throw FormatException('Refusing to overwrite an original: $source');
  }
}

img.Image fitWithin(img.Image image, int width, int height) {
  final scale =
      math.min(1.0, math.min(width / image.width, height / image.height));
  if (scale == 1) return image;
  return img.copyResize(image,
      width: math.max(1, (image.width * scale).round()),
      height: math.max(1, (image.height * scale).round()),
      interpolation: img.Interpolation.cubic);
}

img.Image cropVisible(img.Image image, {int threshold = 8, int padding = 0}) {
  var left = image.width, top = image.height, right = -1, bottom = -1;
  for (final pixel in image) {
    if (pixel.a < threshold) continue;
    left = math.min(left, pixel.x);
    top = math.min(top, pixel.y);
    right = math.max(right, pixel.x);
    bottom = math.max(bottom, pixel.y);
  }
  if (right < left) throw const FormatException('Image has no visible artwork');
  left = math.max(0, left - padding);
  top = math.max(0, top - padding);
  right = math.min(image.width - 1, right + padding);
  bottom = math.min(image.height - 1, bottom + padding);
  return img.copyCrop(image,
      x: left, y: top, width: right - left + 1, height: bottom - top + 1);
}

img.Image centeredCanvas(img.Image image, int width, int height,
    {img.Color? background}) {
  final canvas = img.Image(width: width, height: height, numChannels: 4);
  if (background != null) canvas.clear(background);
  return img.compositeImage(canvas, image,
      dstX: (width - image.width) ~/ 2, dstY: (height - image.height) ~/ 2);
}

String assetPath(String relative) =>
    p.join(websiteRoot, 'source', 'images', relative);
