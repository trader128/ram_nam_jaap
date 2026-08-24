import '../domain/panchang_day.dart';
import '../domain/vrat.dart';

/// Pins bundled tithi vrats onto civil dates using Navamsha panchang limbs.
abstract final class PanchangVratMerger {
  static List<Vrat> merge(List<Vrat> vrats, List<PanchangDay> days) {
    final byId = {for (final vrat in vrats) vrat.id: vrat};
    final dated = <Vrat>[];

    for (final day in days) {
      final templateId = vratIdFor(day);
      if (templateId == null) {
        continue;
      }
      final template = byId[templateId];
      if (template == null) {
        continue;
      }
      dated.add(
        template.copyWith(
          id: '$templateId-${day.dateKey}',
          date: day.date,
        ),
      );
    }

    return [...vrats, ...dated];
  }

  static String? vratIdFor(PanchangDay day) {
    final number = day.tithiNumber;
    final blob = '${day.tithiNameEn ?? ''} ${day.tithiNameHi ?? ''} ${day.paksha ?? ''}'
        .toLowerCase();
    final krishna = (day.paksha ?? '').toLowerCase() == 'krishna' ||
        blob.contains('krishna') ||
        blob.contains('कृष्ण');

    if (number == 11 || blob.contains('ekadashi') || blob.contains('एकादशी')) {
      return 'ekadashi';
    }
    if (number == 15 || blob.contains('purnima') || blob.contains('पूर्णिमा')) {
      return 'purnima';
    }
    if (number == 30 ||
        number == 0 ||
        blob.contains('amavasya') ||
        blob.contains('अमावस्या')) {
      return 'amavasya';
    }
    if (number == 13 || blob.contains('pradosh') || blob.contains('trayodashi') ||
        blob.contains('प्रदोष') ||
        blob.contains('त्रयोदशी')) {
      return 'pradosh';
    }
    if ((number == 4 && krishna) ||
        blob.contains('sankashti') ||
        blob.contains('संकष्टी')) {
      return 'sankashti-chaturthi';
    }
    return null;
  }
}
