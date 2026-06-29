import 'package:flutter/services.dart';

class HapticService {
  Future<void> japTap({required bool enabled}) async {
    if (!enabled) {
      return;
    }
    await HapticFeedback.lightImpact();
  }

  Future<void> malaComplete({required bool enabled}) async {
    if (!enabled) {
      return;
    }
    await HapticFeedback.mediumImpact();
  }
}
