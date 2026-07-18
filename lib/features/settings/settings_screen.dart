import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/practice_state.dart';
import '../../core/storage/practice_state_provider.dart';
import '../../core/theme/app_theme.dart';

/// Settings — a single page. Practice window, locale, about, sign out
/// (which is just "reset practice state" for the MVP since there's no
/// account).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(practiceStateProvider);
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'settings',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: AppColors.ink,
          ),
        ),
        backgroundColor: AppColors.cream,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          _SectionHeader('practice'),
          const SizedBox(height: 12),
          _Card(
            children: [
              _Row(
                label: 'window',
                value: _windowLabel(state.window),
                onTap: () => _showWindowPicker(context, ref, state.window),
              ),
              const Divider(height: 1, color: AppColors.line),
              _Row(
                label: 'today',
                value: state.practicedToday ? 'done' : 'not yet',
              ),
              const Divider(height: 1, color: AppColors.line),
              _Row(
                label: 'total practices',
                value: '${state.totalPractices}',
              ),
            ],
          ),
          const SizedBox(height: 32),
          _SectionHeader('about'),
          const SizedBox(height: 12),
          _Card(
            children: [
              _Row(label: 'version', value: '0.1.0'),
              const Divider(height: 1, color: AppColors.line),
              _Row(label: 'made by', value: 'pclub'),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: TextButton(
              onPressed: () => _showResetDialog(context, ref),
              child: Text(
                'reset practice state',
                style: TextStyle(color: AppColors.mute),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _windowLabel(PracticeWindow w) {
    switch (w) {
      case PracticeWindow.morning: return 'morning · 6–9am';
      case PracticeWindow.midday: return 'midday · 11am–2pm';
      case PracticeWindow.evening: return 'evening · 8–10pm';
      case PracticeWindow.anytime: return 'anytime';
      case PracticeWindow.unknown: return '—';
    }
  }

  Future<void> _showWindowPicker(
    BuildContext context,
    WidgetRef ref,
    PracticeWindow current,
  ) async {
    final notifier = ref.read(practiceStateProvider.notifier);
    final picked = await showModalBottomSheet<PracticeWindow>(
      context: context,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              for (final w in [
                PracticeWindow.morning,
                PracticeWindow.midday,
                PracticeWindow.evening,
                PracticeWindow.anytime,
              ])
                ListTile(
                  title: Text(_windowLabel(w)),
                  trailing: w == current
                      ? const Icon(Icons.check, color: AppColors.teal)
                      : null,
                  onTap: () => Navigator.of(ctx).pop(w),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (picked != null) {
      await notifier.setWindow(picked);
    }
  }

  Future<void> _showResetDialog(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cream,
        title: const Text('reset practice state?'),
        content: const Text(
          'this will clear your practice history. the app will return to its first-launch state.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'reset',
              style: TextStyle(color: AppColors.teal),
            ),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(practiceStateProvider.notifier).reset();
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text.toLowerCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.mute,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.creamSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(children: children),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _Row({required this.label, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.ink,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.inkSoft,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, color: AppColors.mute, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}
