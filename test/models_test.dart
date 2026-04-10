import 'package:flutter_test/flutter_test.dart';
import 'package:language_toggle_widget/models/language.dart';
import 'package:language_toggle_widget/models/change_interval.dart';

void main() {
  group('Language model', () {
    test('fromCode returns correct language', () {
      final lang = Language.fromCode('es');
      expect(lang, isNotNull);
      expect(lang!.name, 'Spanish');
      expect(lang.flag, '🇪🇸');
    });

    test('fromCode returns null for unknown code', () {
      expect(Language.fromCode('xx'), isNull);
    });

    test('equality is based on code', () {
      expect(Language.fromCode('fr'), equals(Language.fromCode('fr')));
      expect(Language.fromCode('fr'), isNot(equals(Language.fromCode('de'))));
    });

    test('all list is non-empty', () {
      expect(Language.all, isNotEmpty);
    });

    test('all languages have non-empty code, name, flag', () {
      for (final lang in Language.all) {
        expect(lang.code, isNotEmpty);
        expect(lang.name, isNotEmpty);
        expect(lang.flag, isNotEmpty);
      }
    });

    test('toJson / fromJson roundtrip', () {
      const lang = Language(
        code: 'ja',
        name: 'Japanese',
        nativeName: '日本語',
        flag: '🇯🇵',
      );
      final json = lang.toJson();
      final restored = Language.fromJson(json);
      expect(restored, equals(lang));
      expect(restored.nativeName, '日本語');
    });
  });

  group('ChangeInterval model', () {
    test('fromKey roundtrip for all values', () {
      for (final interval in ChangeInterval.values) {
        expect(ChangeIntervalExtension.fromKey(interval.key), equals(interval));
      }
    });

    test('fromKey returns everyDay for unknown key', () {
      expect(
        ChangeIntervalExtension.fromKey('unknown_key'),
        ChangeInterval.everyDay,
      );
    });

    test('onUnlock has null intervalMinutes', () {
      expect(ChangeInterval.onUnlock.intervalMinutes, isNull);
    });

    test('non-onUnlock intervals have positive intervalMinutes', () {
      for (final interval in ChangeInterval.values) {
        if (interval == ChangeInterval.onUnlock) continue;
        expect(interval.intervalMinutes, isNotNull);
        expect(interval.intervalMinutes! > 0, isTrue);
      }
    });

    test('label is non-empty for all values', () {
      for (final interval in ChangeInterval.values) {
        expect(interval.label, isNotEmpty);
      }
    });
  });
}
