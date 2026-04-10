import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/language.dart';
import '../models/change_interval.dart';

/// Persists and retrieves all user settings.
class SettingsService {
  static const _keyIsEnabled = 'is_enabled';
  static const _keyNativeLanguage = 'native_language';
  static const _keyTargetLanguages = 'target_languages';
  static const _keyInterval = 'change_interval';
  static const _keyCurrentLanguage = 'current_language';
  static const _keyLastChanged = 'last_changed';

  final SharedPreferences _prefs;

  SettingsService._(this._prefs);

  static Future<SettingsService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsService._(prefs);
  }

  // ── Toggle ──────────────────────────────────────────────────────────────

  bool get isEnabled => _prefs.getBool(_keyIsEnabled) ?? false;

  Future<void> setEnabled(bool value) =>
      _prefs.setBool(_keyIsEnabled, value);

  // ── Native language ──────────────────────────────────────────────────────

  Language get nativeLanguage {
    final code = _prefs.getString(_keyNativeLanguage) ?? 'en';
    return Language.fromCode(code) ?? Language.all.first;
  }

  Future<void> setNativeLanguage(Language lang) =>
      _prefs.setString(_keyNativeLanguage, lang.code);

  // ── Target languages ──────────────────────────────────────────────────

  List<Language> get targetLanguages {
    final raw = _prefs.getString(_keyTargetLanguages);
    if (raw == null) return [];
    final codes = List<String>.from(jsonDecode(raw) as List);
    return codes
        .map(Language.fromCode)
        .whereType<Language>()
        .toList();
  }

  Future<void> setTargetLanguages(List<Language> langs) =>
      _prefs.setString(
          _keyTargetLanguages, jsonEncode(langs.map((l) => l.code).toList()));

  // ── Interval ────────────────────────────────────────────────────────────

  ChangeInterval get interval {
    final key = _prefs.getString(_keyInterval);
    if (key == null) return ChangeInterval.everyDay;
    return ChangeIntervalExtension.fromKey(key);
  }

  Future<void> setInterval(ChangeInterval interval) =>
      _prefs.setString(_keyInterval, interval.key);

  // ── Current language (what's currently applied) ─────────────────────────

  Language get currentLanguage {
    final code = _prefs.getString(_keyCurrentLanguage);
    if (code == null) return nativeLanguage;
    return Language.fromCode(code) ?? nativeLanguage;
  }

  Future<void> setCurrentLanguage(Language lang) =>
      _prefs.setString(_keyCurrentLanguage, lang.code);

  // ── Last changed timestamp ───────────────────────────────────────────────

  DateTime? get lastChanged {
    final ms = _prefs.getInt(_keyLastChanged);
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> setLastChanged(DateTime dt) =>
      _prefs.setInt(_keyLastChanged, dt.millisecondsSinceEpoch);
}
