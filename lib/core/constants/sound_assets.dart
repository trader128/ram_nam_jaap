abstract final class SoundAssets {
  static const String malaComplete = 'sounds/mala_complete.wav';

  /// Per-deity spoken chant of the divine name, e.g. `sounds/chants/ram.m4a`.
  /// Paths are relative to the bundled `assets/` folder (audioplayers convention).
  static String chantFor(String deityId) => 'sounds/chants/$deityId.m4a';

  /// Shared, seamlessly-looping temple ambient track played while chanting.
  static const String templeAmbient = 'music/temple_ambient.m4a';
}
