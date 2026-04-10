import 'package:flutter/material.dart';
import '../models/language.dart';
import '../models/change_interval.dart';
import '../services/settings_service.dart';
import '../services/language_service.dart';
import '../services/scheduler_service.dart';

class SettingsScreen extends StatefulWidget {
  final SettingsService settings;
  final LanguageService langService;
  final SchedulerService scheduler;

  const SettingsScreen({
    super.key,
    required this.settings,
    required this.langService,
    required this.scheduler,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Language _nativeLanguage;
  late List<Language> _targetLanguages;
  late ChangeInterval _interval;

  @override
  void initState() {
    super.initState();
    _nativeLanguage = widget.settings.nativeLanguage;
    _targetLanguages = List.from(widget.settings.targetLanguages);
    _interval = widget.settings.interval;
  }

  Future<void> _saveAll() async {
    await widget.settings.setNativeLanguage(_nativeLanguage);
    await widget.settings.setTargetLanguages(_targetLanguages);
    await widget.settings.setInterval(_interval);
    // Re-schedule with updated interval.
    if (widget.settings.isEnabled) {
      await widget.scheduler.scheduleRotation();
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Settings',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveAll,
            child: const Text('Save',
                style: TextStyle(color: Color(0xFF6C63FF), fontSize: 16)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _SectionHeader('Native Language'),
          _NativeLanguagePicker(
            selected: _nativeLanguage,
            onChanged: (lang) => setState(() => _nativeLanguage = lang),
          ),
          const SizedBox(height: 24),
          _SectionHeader('Languages to Learn'),
          _TargetLanguagePicker(
            nativeLanguage: _nativeLanguage,
            selected: _targetLanguages,
            onChanged: (langs) => setState(() => _targetLanguages = langs),
          ),
          const SizedBox(height: 24),
          _SectionHeader('Change Interval'),
          _IntervalPicker(
            selected: _interval,
            onChanged: (interval) => setState(() => _interval = interval),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Tip: Add the LangToggle widget to your home screen or lock screen for quick one-tap toggling.',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF6C63FF),
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

// ── Native language picker ───────────────────────────────────────────────────

class _NativeLanguagePicker extends StatelessWidget {
  final Language selected;
  final ValueChanged<Language> onChanged;

  const _NativeLanguagePicker({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton<Language>(
            value: selected,
            dropdownColor: const Color(0xFF1E1E1E),
            isExpanded: true,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            borderRadius: BorderRadius.circular(12),
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF6C63FF)),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            items: Language.all
                .map((lang) => DropdownMenuItem(
                      value: lang,
                      child: Text('${lang.flag}  ${lang.name}'),
                    ))
                .toList(),
            onChanged: (lang) {
              if (lang != null) onChanged(lang);
            },
          ),
        ),
      ),
    );
  }
}

// ── Target languages picker ──────────────────────────────────────────────────

class _TargetLanguagePicker extends StatelessWidget {
  final Language nativeLanguage;
  final List<Language> selected;
  final ValueChanged<List<Language>> onChanged;

  const _TargetLanguagePicker({
    required this.nativeLanguage,
    required this.selected,
    required this.onChanged,
  });

  void _toggle(Language lang) {
    final updated = List<Language>.from(selected);
    if (updated.contains(lang)) {
      updated.remove(lang);
    } else {
      updated.add(lang);
    }
    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final available =
        Language.all.where((l) => l.code != nativeLanguage.code).toList();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: available.map((lang) {
          final isSelected = selected.contains(lang);
          return CheckboxListTile(
            value: isSelected,
            activeColor: const Color(0xFF6C63FF),
            checkColor: Colors.white,
            title: Text(
              '${lang.flag}  ${lang.name}',
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
            subtitle: Text(
              lang.nativeName,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            onChanged: (_) => _toggle(lang),
            controlAffinity: ListTileControlAffinity.trailing,
          );
        }).toList(),
      ),
    );
  }
}

// ── Interval picker ──────────────────────────────────────────────────────────

class _IntervalPicker extends StatelessWidget {
  final ChangeInterval selected;
  final ValueChanged<ChangeInterval> onChanged;

  const _IntervalPicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: ChangeInterval.values.map((interval) {
          final isSelected = selected == interval;
          return RadioListTile<ChangeInterval>(
            value: interval,
            groupValue: selected,
            activeColor: const Color(0xFF6C63FF),
            title: Text(
              interval.label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF6C63FF) : Colors.white,
                fontSize: 15,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          );
        }).toList(),
      ),
    );
  }
}
