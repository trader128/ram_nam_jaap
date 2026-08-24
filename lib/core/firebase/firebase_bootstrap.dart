import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

/// Brings Firebase up without ever blocking app start.
///
/// The jap counter is offline-first: if Firebase is unconfigured, unreachable,
/// or fails for any other reason, [isAvailable] stays false and the app runs
/// purely on local Hive storage exactly as before. Cloud backup is an optional
/// layer, and is never a precondition for chanting.
abstract final class FirebaseBootstrap {
  static bool _available = false;

  /// Whether cloud features (auth, Firestore sync) can be used at all.
  static bool get isAvailable => _available;

  static Future<void> init() async {
    if (_available) {
      return;
    }

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      _available = true;
    } on Object catch (error) {
      _available = false;
      debugPrint('Firebase unavailable, running local-only: $error');
    }
  }

  @visibleForTesting
  static void overrideAvailability(bool value) => _available = value;
}
