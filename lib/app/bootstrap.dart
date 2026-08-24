import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/firebase/firebase_bootstrap.dart';
import '../core/storage/hive_storage.dart';
import '../features/deity/data/deity_migration.dart';
import 'app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFF050608),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await HiveStorage.init();
  await DeityMigration.run();

  // Cloud backup is optional; a failure here must never delay the counter.
  await FirebaseBootstrap.init();

  runApp(const ProviderScope(child: BhaktiApp()));
}
