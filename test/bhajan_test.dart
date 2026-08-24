import 'package:flutter_test/flutter_test.dart';
import 'package:bhakti/features/bhajan/data/bhajan_repository.dart';
import 'package:bhakti/features/bhajan/domain/bhajan.dart';
import 'package:bhakti/features/bhajan/domain/bhajan_audio_service.dart';
import 'package:bhakti/features/deity/domain/deity_catalog.dart';

void main() {
  setUp(TestWidgetsFlutterBinding.ensureInitialized);

  Future<List<Bhajan>> load() => BhajanRepository().loadBundled();

  group('Bhajan model', () {
    test('parses a full entry from a map', () {
      final bhajan = Bhajan.fromMap('x', {
        'category': 'aarti',
        'titleEn': 'Test',
        'titleHi': 'परीक्षा',
        'deityId': 'ram',
        'verses': [
          {'hi': 'क', 'en': 'ka'},
          {'hi': 'ख'},
        ],
      });

      expect(bhajan.category, BhajanCategory.aarti);
      expect(bhajan.title(hindi: true), 'परीक्षा');
      expect(bhajan.title(hindi: false), 'Test');
      expect(bhajan.verses, hasLength(2));
      expect(bhajan.verses.first.transliteration, 'ka');
      expect(bhajan.verses.last.transliteration, isNull);
    });

    test('falls back to bhajan for an unknown category', () {
      final bhajan = Bhajan.fromMap('x', {'category': 'nonsense'});
      expect(bhajan.category, BhajanCategory.bhajan);
    });

    test('survives a map with no verses', () {
      final bhajan = Bhajan.fromMap('x', {'titleEn': 'Bare'});
      expect(bhajan.verses, isEmpty);
      expect(bhajan.hasTransliteration, isFalse);
      expect(bhajan.hasAudio, isFalse);
    });

    test('hasAudio reflects either a url or a bundled asset', () {
      expect(
        Bhajan.fromMap('x', {'audioUrl': 'https://e.com/a.m4a'}).hasAudio,
        isTrue,
      );
      expect(
        Bhajan.fromMap('x', {'audioAsset': 'music/a.m4a'}).hasAudio,
        isTrue,
      );
      expect(Bhajan.fromMap('x', const {}).hasAudio, isFalse);
    });

    test('toMap round-trips through fromMap', () {
      const original = Bhajan(
        id: 'x',
        category: BhajanCategory.stotra,
        titleEn: 'Title',
        titleHi: 'शीर्षक',
        deityId: 'mahadev',
        attribution: 'Traditional',
        verses: [BhajanVerse(devanagari: 'क', transliteration: 'ka')],
      );

      final restored = Bhajan.fromMap('x', original.toMap());

      expect(restored.category, original.category);
      expect(restored.titleHi, original.titleHi);
      expect(restored.deityId, original.deityId);
      expect(restored.attribution, original.attribution);
      expect(restored.verses.single.devanagari, 'क');
      expect(restored.verses.single.transliteration, 'ka');
    });
  });

  group('bundled bhajan content', () {
    test('parses and is not empty', () async {
      expect(await load(), isNotEmpty);
    });

    test('every bhajan has verses, a Hindi title, and attribution', () async {
      for (final bhajan in await load()) {
        expect(bhajan.verses, isNotEmpty, reason: bhajan.id);
        expect(bhajan.titleHi, isNotEmpty, reason: bhajan.id);
        expect(
          bhajan.attribution,
          isNotNull,
          reason: '${bhajan.id} has no attribution; every bundled text must '
              'record the author and period that makes it public domain',
        );
      }
    });

    test('no verse is blank', () async {
      for (final bhajan in await load()) {
        for (final verse in bhajan.verses) {
          expect(verse.devanagari.trim(), isNotEmpty, reason: bhajan.id);
        }
      }
    });

    test('every verse carries Devanagari, not Roman text', () async {
      final devanagari = RegExp(r'[\u0900-\u097F]');
      for (final bhajan in await load()) {
        for (final verse in bhajan.verses) {
          expect(
            devanagari.hasMatch(verse.devanagari),
            isTrue,
            reason: '${bhajan.id} has a verse with no Devanagari characters',
          );
        }
      }
    });

    test('transliteration is all-or-nothing within a bhajan', () async {
      for (final bhajan in await load()) {
        final withRoman = bhajan.verses
            .where((verse) => verse.transliteration != null)
            .length;
        expect(
          withRoman,
          anyOf(0, bhajan.verses.length),
          reason: '${bhajan.id} is partially transliterated; the toggle would '
              'show gaps mid-text',
        );
      }
    });

    test('every deity reference resolves to a real deity', () async {
      final ids = DeityCatalog.all.map((deity) => deity.id).toSet();
      for (final bhajan in await load()) {
        if (bhajan.deityId != null) {
          expect(ids, contains(bhajan.deityId), reason: bhajan.id);
        }
      }
    });

    test('ids are unique', () async {
      final bhajans = await load();
      expect(bhajans.map((bhajan) => bhajan.id).toSet(), hasLength(
        bhajans.length,
      ));
    });

    test('no bundled bhajan ships with audio', () async {
      for (final bhajan in await load()) {
        expect(
          bhajan.hasAudio,
          isFalse,
          reason: '${bhajan.id} bundles audio; commercial devotional '
              'recordings are label-owned and must be supplied per-track '
              'through Firestore only when the rights are held',
        );
      }
    });

    test('household aartis ship in Hindi with English transliteration',
        () async {
      final bhajans = await load();
      const expected = {
        'ganesh-aarti': 'Ganesh Aarti',
        'lakshmi-aarti': 'Lakshmi Aarti',
        'om-jai-jagdish-hare': 'Vishnu Aarti',
        'shiv-aarti': 'Shiva Aarti',
        'durga-aarti': 'Durga Aarti',
        'hanuman-aarti': 'Hanuman Aarti',
      };

      for (final entry in expected.entries) {
        final aarti = bhajans.firstWhere((bhajan) => bhajan.id == entry.key);
        expect(aarti.category, BhajanCategory.aarti, reason: aarti.id);
        expect(aarti.titleEn, entry.value, reason: aarti.id);
        expect(aarti.titleHi, isNotEmpty, reason: aarti.id);
        expect(aarti.hasTransliteration, isTrue, reason: aarti.id);
        expect(aarti.verses.length, greaterThanOrEqualTo(6), reason: aarti.id);
      }
    });

    test('the Hanuman Chalisa has its forty verses plus framing dohas',
        () async {
      final bhajans = await load();
      final chalisa = bhajans.firstWhere(
        (bhajan) => bhajan.id == 'hanuman-chalisa',
      );

      expect(chalisa.category, BhajanCategory.chalisa);
      expect(chalisa.deityId, 'hanuman');
      expect(
        chalisa.verses,
        hasLength(43),
        reason: '40 chaupais, 2 opening dohas, 1 closing doha',
      );
      expect(chalisa.hasTransliteration, isTrue);
    });
  });

  group('BhajanPlayback', () {
    test('reports progress against duration', () {
      const playback = BhajanPlayback(
        bhajanId: 'a',
        state: BhajanPlaybackState.playing,
        position: Duration(seconds: 30),
        duration: Duration(minutes: 2),
      );

      expect(playback.progress, closeTo(0.25, 0.001));
      expect(playback.isPlaying('a'), isTrue);
      expect(playback.isPlaying('b'), isFalse);
      expect(playback.isActive, isTrue);
    });

    test('progress is zero when duration is unknown', () {
      const playback = BhajanPlayback(
        bhajanId: 'a',
        state: BhajanPlaybackState.loading,
        position: Duration(seconds: 30),
      );

      expect(playback.progress, 0);
      expect(playback.isLoading('a'), isTrue);
      expect(playback.isActive, isFalse);
    });

    test('progress is clamped when position overruns duration', () {
      const playback = BhajanPlayback(
        position: Duration(seconds: 90),
        duration: Duration(seconds: 60),
      );

      expect(playback.progress, 1.0);
    });

    test('an idle playback claims no track', () {
      const playback = BhajanPlayback();
      expect(playback.bhajanId, isNull);
      expect(playback.isActive, isFalse);
      expect(playback.isPlaying('a'), isFalse);
    });
  });
}
