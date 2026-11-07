import 'package:args/args.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

import 'image_utils.dart';

Future<void> main(List<String> arguments) => runTool(() async {
      final parser = ArgParser()
        ..addOption('source',
            defaultsTo:
                p.join(websiteRoot, 'design/logos/nest/nest-logo-v1.png'))
        ..addOption('output', defaultsTo: assetPath('nest/nest-logo-66x72.png'))
        ..addFlag('help', abbr: 'h', negatable: false);
      final args = parser.parse(arguments);
      if (args['help'] as bool) {
        print(parser.usage);
        return;
      }
      if (args.rest.isNotEmpty) {
        throw const FormatException('Unexpected positional arguments');
      }
      final image = fitWithin(
          cropVisible(readImage(args['source'] as String), padding: 2), 66, 72);
      final output = args['output'] as String;
      protectOriginal(args['source'] as String, output);
      writeAsset(
          output, img.encodePng(centeredCanvas(image, 66, 72), level: 9));
      print('$output: 66×72');
    });
