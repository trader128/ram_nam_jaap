import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';
import 'package:path/path.dart' as path;

Future<void> main() async {
  final outDir = Directory(
    path.join(Directory.current.path, 'store', 'play-store', 'screenshots'),
  );
  await outDir.create(recursive: true);

  await integrationDriver(
    onScreenshot: (String name, List<int> bytes, [Map<String, Object?>? args]) async {
      final file = File(path.join(outDir.path, '$name.png'));
      await file.writeAsBytes(bytes, flush: true);
      // ignore: avoid_print
      print('Screenshot saved: ${file.path}');
      return true;
    },
  );
}
