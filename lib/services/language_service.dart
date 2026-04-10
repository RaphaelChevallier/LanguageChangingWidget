import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'settings_service.dart';
import '../models/language.dart';

/// Handles picking the next language and applying it to the app locale.
class LanguageService {
  static const MethodChannel _channel =
      MethodChannel('com.example.language_toggle_widget/locale');

  final SettingsService _settings;
  final _random = Random();

  /// Notifier that broadcasts the currently active [Locale].
  final ValueNotifier<Locale> currentLocale;

  LanguageService(this._settings)
      : currentLocale = ValueNotifier<Locale>(
            Locale(_settings.currentLanguage.code));

  /// Returns the locale that should be in effect right now.
  Locale get activeLocale =>
      isEnabled ? currentLocale.value : Locale(_settings.nativeLanguage.code);

  bool get isEnabled => _settings.isEnabled;

  /// Enables learning mode: picks a random target language and applies it.
  Future<void> enable() async {
    await _settings.setEnabled(true);
    await _pickAndApplyNext();
  }

  /// Disables learning mode: reverts to the native language.
  Future<void> disable() async {
    await _settings.setEnabled(false);
    final native = _settings.nativeLanguage;
    await _settings.setCurrentLanguage(native);
    currentLocale.value = Locale(native.code);
    await _applyNative(native);
    await _updateWidget();
  }

  /// Called by the scheduler to rotate to the next language.
  Future<void> rotateLanguage() async {
    if (!_settings.isEnabled) return;
    await _pickAndApplyNext();
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<void> _pickAndApplyNext() async {
    final targets = _settings.targetLanguages;
    if (targets.isEmpty) return;

    final next = targets[_random.nextInt(targets.length)];
    await _settings.setCurrentLanguage(next);
    await _settings.setLastChanged(DateTime.now());
    currentLocale.value = Locale(next.code);
    await _applyLocale(next);
    await _updateWidget();
  }

  /// Tells the platform to switch the app locale (Android per-app locale API).
  Future<void> _applyLocale(Language lang) async {
    try {
      await _channel.invokeMethod<void>(
          'setLocale', {'languageCode': lang.code});
    } on PlatformException {
      // Platform may not support per-app locale; Flutter locale change still works.
    }
  }

  /// Reverts the platform locale to the user's native language.
  Future<void> _applyNative(Language lang) async {
    try {
      await _channel.invokeMethod<void>(
          'resetLocale', {'languageCode': lang.code});
    } on PlatformException {
      // Best-effort.
    }
  }

  /// Pushes the current state to the native home screen widget.
  Future<void> _updateWidget() async {
    try {
      await _channel.invokeMethod<void>('updateWidget', {
        'isEnabled': _settings.isEnabled,
        'languageCode': _settings.currentLanguage.code,
        'languageName': _settings.currentLanguage.name,
        'languageFlag': _settings.currentLanguage.flag,
      });
    } on PlatformException {
      // Widget update is best-effort.
    }
  }
}
