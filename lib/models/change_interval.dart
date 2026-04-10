/// How often the language should be changed when the toggle is ON.
enum ChangeInterval {
  onUnlock,
  everyHour,
  every6Hours,
  everyDay,
  every3Days,
  everyWeek,
}

extension ChangeIntervalExtension on ChangeInterval {
  String get label {
    switch (this) {
      case ChangeInterval.onUnlock:
        return 'Every unlock / wake';
      case ChangeInterval.everyHour:
        return 'Every hour';
      case ChangeInterval.every6Hours:
        return 'Every 6 hours';
      case ChangeInterval.everyDay:
        return 'Once a day';
      case ChangeInterval.every3Days:
        return 'Every 3 days';
      case ChangeInterval.everyWeek:
        return 'Once a week';
    }
  }

  /// Duration in minutes, or null for "on unlock" (handled separately).
  int? get intervalMinutes {
    switch (this) {
      case ChangeInterval.onUnlock:
        return null;
      case ChangeInterval.everyHour:
        return 60;
      case ChangeInterval.every6Hours:
        return 360;
      case ChangeInterval.everyDay:
        return 1440;
      case ChangeInterval.every3Days:
        return 4320;
      case ChangeInterval.everyWeek:
        return 10080;
    }
  }

  String get key => name;

  static ChangeInterval fromKey(String key) {
    return ChangeInterval.values.firstWhere(
      (e) => e.key == key,
      orElse: () => ChangeInterval.everyDay,
    );
  }
}
