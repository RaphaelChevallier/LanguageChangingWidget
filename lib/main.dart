import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/settings_service.dart';
import 'services/language_service.dart';
import 'services/scheduler_service.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settings = await SettingsService.create();
  final langService = LanguageService(settings);
  final scheduler = SchedulerService(settings);

  await scheduler.init();

  runApp(LangToggleApp(
    settings: settings,
    langService: langService,
    scheduler: scheduler,
  ));
}

class LangToggleApp extends StatelessWidget {
  final SettingsService settings;
  final LanguageService langService;
  final SchedulerService scheduler;

  const LangToggleApp({
    super.key,
    required this.settings,
    required this.langService,
    required this.scheduler,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: langService.currentLocale,
      builder: (_, locale, __) {
        return MaterialApp(
          title: 'LangToggle',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6C63FF),
              secondary: Color(0xFF6C63FF),
            ),
          ),
          locale: settings.isEnabled ? locale : null,
          supportedLocales: const [
            Locale('en'),
            Locale('es'),
            Locale('fr'),
            Locale('de'),
            Locale('it'),
            Locale('pt'),
            Locale('ru'),
            Locale('ja'),
            Locale('ko'),
            Locale('zh'),
            Locale('ar'),
            Locale('hi'),
            Locale('nl'),
            Locale('pl'),
            Locale('sv'),
            Locale('tr'),
            Locale('vi'),
            Locale('th'),
            Locale('id'),
            Locale('uk'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: HomeScreen(
            settings: settings,
            langService: langService,
            scheduler: scheduler,
          ),
        );
      },
    );
  }
}
