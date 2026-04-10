import 'package:workmanager/workmanager.dart';
import 'settings_service.dart';
import 'language_service.dart';

/// Background task name registered with WorkManager.
const _kRotateTask = 'language_rotate_task';

/// Called by WorkManager in the background isolate.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == _kRotateTask) {
      final settings = await SettingsService.create();
      if (settings.isEnabled && settings.targetLanguages.isNotEmpty) {
        final langService = LanguageService(settings);
        await langService.rotateLanguage();
      }
    }
    return true;
  });
}

/// Manages registration and cancellation of the background rotation task.
class SchedulerService {
  final SettingsService _settings;

  SchedulerService(this._settings);

  /// Initialises WorkManager. Must be called once at app startup.
  Future<void> init() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  }

  /// Schedules (or re-schedules) the rotation task based on current settings.
  Future<void> scheduleRotation() async {
    await cancelRotation();

    final minutes = _settings.interval.intervalMinutes;
    if (minutes == null) {
      // "On unlock" is handled by the app lifecycle, not WorkManager.
      return;
    }

    await Workmanager().registerPeriodicTask(
      _kRotateTask,
      _kRotateTask,
      frequency: Duration(minutes: minutes),
      constraints: Constraints(
        networkType: NetworkType.not_required,
      ),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }

  /// Cancels any pending rotation task.
  Future<void> cancelRotation() async {
    await Workmanager().cancelByUniqueName(_kRotateTask);
  }
}
