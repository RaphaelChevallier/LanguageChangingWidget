import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../services/language_service.dart';
import '../services/scheduler_service.dart';
import '../models/language.dart';
import '../models/change_interval.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final SettingsService settings;
  final LanguageService langService;
  final SchedulerService scheduler;

  const HomeScreen({
    super.key,
    required this.settings,
    required this.langService,
    required this.scheduler,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _isEnabled = false;
  Language _currentLang = Language.all.first;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Called when the app comes back from background (e.g., unlock).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _handleResume();
    }
  }

  void _loadState() {
    setState(() {
      _isEnabled = widget.settings.isEnabled;
      _currentLang = widget.settings.currentLanguage;
    });
  }

  Future<void> _handleResume() async {
    if (!widget.settings.isEnabled) return;
    if (widget.settings.interval != ChangeInterval.onUnlock) return;
    await widget.langService.rotateLanguage();
    setState(() => _currentLang = widget.settings.currentLanguage);
  }

  Future<void> _toggle() async {
    setState(() => _isLoading = true);
    try {
      if (_isEnabled) {
        await widget.langService.disable();
        await widget.scheduler.cancelRotation();
      } else {
        if (widget.settings.targetLanguages.isEmpty) {
          _showNoLanguagesDialog();
          return;
        }
        await widget.langService.enable();
        await widget.scheduler.scheduleRotation();
      }
      setState(() {
        _isEnabled = widget.settings.isEnabled;
        _currentLang = widget.settings.currentLanguage;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showNoLanguagesDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('No languages selected',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'Please choose at least one language to learn in Settings.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK',
                style: TextStyle(color: Color(0xFF6C63FF))),
          ),
        ],
      ),
    );
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SettingsScreen(
          settings: widget.settings,
          langService: widget.langService,
          scheduler: widget.scheduler,
        ),
      ),
    );
    // Refresh after returning from settings.
    _loadState();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor =
        _isEnabled ? const Color(0xFF6C63FF) : Colors.grey[700]!;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: Row(
          children: [
            const Text('🌐 ', style: TextStyle(fontSize: 22)),
            const Text(
              'LangToggle',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: _openSettings,
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── Current language card ─────────────────────────
                    _LanguageCard(
                      language: _currentLang,
                      isEnabled: _isEnabled,
                    ),
                    const SizedBox(height: 40),

                    // ── Big toggle ────────────────────────────────────
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 160,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        color: _isEnabled
                            ? const Color(0xFF6C63FF)
                            : const Color(0xFF2A2A2A),
                        boxShadow: _isEnabled
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF6C63FF)
                                      .withOpacity(0.5),
                                  blurRadius: 24,
                                  spreadRadius: 4,
                                )
                              ]
                            : [],
                      ),
                      child: GestureDetector(
                        onTap: _isLoading ? null : _toggle,
                        child: Stack(
                          children: [
                            AnimatedAlign(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              alignment: _isEnabled
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 60,
                                        height: 60,
                                        child: Padding(
                                          padding: EdgeInsets.all(12),
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 3,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        width: 64,
                                        height: 64,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.2),
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            _isEnabled ? '🌐' : '🏠',
                                            style:
                                                const TextStyle(fontSize: 28),
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _isEnabled ? 'Learning Mode ON' : 'Native Mode',
                        key: ValueKey(_isEnabled),
                        style: TextStyle(
                          color: activeColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isEnabled
                          ? 'Tap to revert to your native language'
                          : 'Tap to enable language rotation',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Bottom info strip ──────────────────────────────────────
            _BottomInfoStrip(settings: widget.settings),
          ],
        ),
      ),
    );
  }
}

// ── Language card ─────────────────────────────────────────────────────────────

class _LanguageCard extends StatelessWidget {
  final Language language;
  final bool isEnabled;

  const _LanguageCard({required this.language, required this.isEnabled});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: 240,
      height: 130,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isEnabled
              ? [const Color(0xFF6C63FF), const Color(0xFF9C63FF)]
              : [const Color(0xFF2A2A2A), const Color(0xFF1E1E1E)],
        ),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ]
            : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(language.flag, style: const TextStyle(fontSize: 42)),
          const SizedBox(height: 6),
          Text(
            language.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            language.nativeName,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom info strip ─────────────────────────────────────────────────────────

class _BottomInfoStrip extends StatelessWidget {
  final SettingsService settings;

  const _BottomInfoStrip({required this.settings});

  @override
  Widget build(BuildContext context) {
    final native = settings.nativeLanguage;
    final targets = settings.targetLanguages;
    final interval = settings.interval;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _InfoChip(
            icon: Icons.home,
            label: native.flag,
            subtitle: 'Native',
          ),
          _InfoChip(
            icon: Icons.translate,
            label: '${targets.length}',
            subtitle: 'Languages',
          ),
          _InfoChip(
            icon: Icons.schedule,
            label: _shortInterval(interval),
            subtitle: 'Interval',
          ),
        ],
      ),
    );
  }

  String _shortInterval(ChangeInterval interval) {
    switch (interval) {
      case ChangeInterval.onUnlock:
        return 'Unlock';
      case ChangeInterval.everyHour:
        return '1h';
      case ChangeInterval.every6Hours:
        return '6h';
      case ChangeInterval.everyDay:
        return '1d';
      case ChangeInterval.every3Days:
        return '3d';
      case ChangeInterval.everyWeek:
        return '7d';
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(label,
              style:
                  const TextStyle(fontSize: 18, color: Colors.white)),
        ),
        const SizedBox(height: 4),
        Text(subtitle,
            style: TextStyle(color: Colors.grey[500], fontSize: 11)),
      ],
    );
  }
}
