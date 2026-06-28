import 'package:hive_flutter/hive_flutter.dart';

import '../constants/hive_box_names.dart';

abstract final class HiveStorage {
  static Future<void> init() async {
    await Hive.initFlutter();

    await Future.wait([
      Hive.openBox<dynamic>(HiveBoxNames.settings),
      Hive.openBox<dynamic>(HiveBoxNames.history),
      Hive.openBox<dynamic>(HiveBoxNames.statistics),
      Hive.openBox<dynamic>(HiveBoxNames.session),
    ]);
  }

  static Box<dynamic> get settingsBox =>
      Hive.box<dynamic>(HiveBoxNames.settings);

  static Box<dynamic> get historyBox => Hive.box<dynamic>(HiveBoxNames.history);

  static Box<dynamic> get statisticsBox =>
      Hive.box<dynamic>(HiveBoxNames.statistics);

  static Box<dynamic> get sessionBox => Hive.box<dynamic>(HiveBoxNames.session);
}
