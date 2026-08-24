import 'package:flutter/services.dart';

class HapticService {
  void japTap({required bool enabled}) {
    if (!enabled) {
      return;
    }
    HapticFeedback.lightImpact();
  }

  void malaComplete({required bool enabled}) {
    if (!enabled) {
      return;
    }
    HapticFeedback.mediumImpact();
  }
}
