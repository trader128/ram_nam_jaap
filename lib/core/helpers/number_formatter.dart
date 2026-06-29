import '../constants/jap_constants.dart';

abstract final class NumberFormatter {
  static String formatCount(int value) {
    final text = value.toString();
    if (text.length <= 3) {
      return text;
    }

    final buffer = StringBuffer();
    final remainder = text.length % 3;
    if (remainder > 0) {
      buffer.write(text.substring(0, remainder));
      if (text.length > remainder) {
        buffer.write(',');
      }
    }

    for (var index = remainder; index < text.length; index += 3) {
      buffer.write(text.substring(index, index + 3));
      if (index + 3 < text.length) {
        buffer.write(',');
      }
    }

    return buffer.toString();
  }

  static String formatMalas(int count) {
    final malas = count / JapConstants.beadsPerMala;
    if (malas == malas.roundToDouble()) {
      return malas.toStringAsFixed(0);
    }
    return malas.toStringAsFixed(1);
  }
}
