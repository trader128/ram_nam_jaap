import 'package:flutter/material.dart';

/// Immutable description of a single deity ("Naam").
///
/// Everything visual and devotional about the active experience — name,
/// mantra, palette, and backdrop — is derived from the selected [DeityPack].
/// The whole app is data-driven from this single source so new deities can be
/// added by appending to the catalog, never by touching UI code.
@immutable
class DeityPack {
  const DeityPack({
    required this.id,
    required this.name,
    required this.transliteration,
    required this.mantra,
    required this.meaning,
    required this.primary,
    required this.accent,
    required this.backdropTop,
    required this.backdropBottom,
  });

  /// Stable storage identifier (also used to namespace per-deity Hive data).
  final String id;

  /// Devanagari name shown as the chanting focus, e.g. "राम".
  final String name;

  /// Latin transliteration, e.g. "Ram".
  final String transliteration;

  /// Full mantra/shlok for this deity.
  final String mantra;

  /// One-line meaning of the mantra.
  final String meaning;

  /// Dominant brand color driving naam text, beads, glow, and accents.
  final Color primary;

  /// Secondary color for gradients and highlights.
  final Color accent;

  /// Upper tint of the immersive backdrop gradient.
  final Color backdropTop;

  /// Lower tint of the immersive backdrop gradient.
  final Color backdropBottom;

  /// Soft glow color derived from [primary].
  Color get glow => primary;

  /// Full asset path of this deity's devotional background artwork.
  String get backgroundImage => 'assets/images/deities/$id.jpg';
}
