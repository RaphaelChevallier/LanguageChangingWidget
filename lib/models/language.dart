/// Represents a language supported by the app.
class Language {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  const Language({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'nativeName': nativeName,
        'flag': flag,
      };

  factory Language.fromJson(Map<String, dynamic> json) => Language(
        code: json['code'] as String,
        name: json['name'] as String,
        nativeName: json['nativeName'] as String,
        flag: json['flag'] as String,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Language && code == other.code);

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => '$flag $name';

  /// All languages available for selection.
  static const List<Language> all = [
    Language(code: 'en', name: 'English', nativeName: 'English', flag: '🇺🇸'),
    Language(code: 'es', name: 'Spanish', nativeName: 'Español', flag: '🇪🇸'),
    Language(code: 'fr', name: 'French', nativeName: 'Français', flag: '🇫🇷'),
    Language(code: 'de', name: 'German', nativeName: 'Deutsch', flag: '🇩🇪'),
    Language(code: 'it', name: 'Italian', nativeName: 'Italiano', flag: '🇮🇹'),
    Language(code: 'pt', name: 'Portuguese', nativeName: 'Português', flag: '🇧🇷'),
    Language(code: 'ru', name: 'Russian', nativeName: 'Русский', flag: '🇷🇺'),
    Language(code: 'ja', name: 'Japanese', nativeName: '日本語', flag: '🇯🇵'),
    Language(code: 'ko', name: 'Korean', nativeName: '한국어', flag: '🇰🇷'),
    Language(code: 'zh', name: 'Chinese', nativeName: '中文', flag: '🇨🇳'),
    Language(code: 'ar', name: 'Arabic', nativeName: 'العربية', flag: '🇸🇦'),
    Language(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी', flag: '🇮🇳'),
    Language(code: 'nl', name: 'Dutch', nativeName: 'Nederlands', flag: '🇳🇱'),
    Language(code: 'pl', name: 'Polish', nativeName: 'Polski', flag: '🇵🇱'),
    Language(code: 'sv', name: 'Swedish', nativeName: 'Svenska', flag: '🇸🇪'),
    Language(code: 'tr', name: 'Turkish', nativeName: 'Türkçe', flag: '🇹🇷'),
    Language(code: 'vi', name: 'Vietnamese', nativeName: 'Tiếng Việt', flag: '🇻🇳'),
    Language(code: 'th', name: 'Thai', nativeName: 'ภาษาไทย', flag: '🇹🇭'),
    Language(code: 'id', name: 'Indonesian', nativeName: 'Bahasa Indonesia', flag: '🇮🇩'),
    Language(code: 'uk', name: 'Ukrainian', nativeName: 'Українська', flag: '🇺🇦'),
  ];

  static Language? fromCode(String code) {
    try {
      return all.firstWhere((l) => l.code == code);
    } catch (_) {
      return null;
    }
  }
}
