import 'package:flutter/material.dart';

abstract final class ColorHelper {
  static int toStorageValue(Color color) {
    return color.toARGB32();
  }

  static Color fromStorageValue(int value, {required Color fallback}) {
    if (value == 0) {
      return fallback;
    }
    return Color(value);
  }
}
