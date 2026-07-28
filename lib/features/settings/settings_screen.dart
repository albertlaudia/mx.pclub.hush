import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/notifications/notification_service.dart';
import '../../core/storage/practice_state.dart';
import '../../core/storage/practice_state_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/what_is_this_sheet.dart';
import 'about_sheet.dart';

/// Settings — a single page. Practice, help, reset.
///
/// The page is for actions: change the window, learn what the product
/// is, replay onboarding, opt into "deeper practice" (the umbrella
/// for opt-in hooks), reset state. Dev info is hidden behind the
/// "about hush." sheet.
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
          const _SectionHeader('practice'),
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
            ],
          ),
          const SizedBox(height: 32),
          const _SectionHeader('help'),
          const SizedBox(height: 12),
          _Card(
            children: [
              _Row(
                label: 'what is this?',
                value: '',
                onTap: () => WhatIsThisSheet.show(context),
              ),
              const Divider(height: 1, color: AppColors.line),
              _Row(
                label: 'show me again',
                value: '',
                onTap: () => _replayOnboarding(context),
              ),
              const Divider(height: 1, color: AppColors.line),
              _Row(
                label: 'about hush.',
                value: '',
                onTap: () => AboutSheet.show(context),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const _SectionHeader('deeper practice'),
          const SizedBox(height: 8),
          // "deeper practice" is the umbrella for opt-in hooks. The
          // user enables it once; the daily notification is the
          // first hook, future home widget + lock screen widget will
          // respect the same flag. The default is off — the brand
          // is voluntary until the user chooses otherwise.
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'opt into gentle hooks: a quiet daily reminder. the app stays quiet until you open it.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.inkSoft,
                height: 1.5,
              ),
            ),
          ),
          _Card(
            children: [
              _DeeperPracticeRow(),
            ],
          ),
          const SizedBox(height: 32),
          // Reset is destructive — visually distinct from the rest
          // of the page. Brand-aligned muted red, not bright.
          Center(
            child: TextButton(
              onPressed: () => _showResetDialog(context, ref),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'reset practice state',
                style: TextStyle(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w500,
                ),
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
      // Enable drag-to-dismiss. iOS pattern.
      isScrollControlled: false,
      enableDrag: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
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
    if (picked != null && picked != current) {
      await notifier.setWindow(picked);
      // If the user has opted into deeper practice, reschedule the
      // daily notification to fire at the new window. Without
      // this, the notification would still fire at the old time.
      final deeper = ref.read(practiceStateProvider).deeperPractice;
      if (deeper) {
        await NotificationService.instance.scheduleDaily(picked);
      }
    }
  }

  /// Replay the onboarding flow. The user can see the welcome screen
  /// and the window picker again without resetting their actual
  /// practice state. This is non-destructive.
  Future<void> _replayOnboarding(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const _OnboardingReplay(),
      ),
    );
  }

  Future<void> _showResetDialog(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cream,
        title: const Text(
          'reset practice state?',
          style: TextStyle(color: AppColors.ink),
        ),
        content: const Text(
          'this will clear your practice history. the app will return to its first-launch state.',
          style: TextStyle(color: AppColors.inkSoft),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'cancel',
              style: TextStyle(color: AppColors.inkSoft),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'reset',
              style: TextStyle(color: AppColors.warning),
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

/// Wraps the onboarding screen so the user can preview it again
/// without losing their real settings. On close, they return to
/// the settings page with their original state intact.
class _OnboardingReplay extends StatelessWidget {
  const _OnboardingReplay();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // The user can't accidentally skip onboarding in replay mode.
      // The only way out is the close button.
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.cream,
        body: SafeArea(
          child: Stack(
            children: [
              // The onboarding screen renders normally, but since the
              // user is already onboarded, picking a window and tapping
              // "begin" would push to home. We override that with a
              // close button instead.
              const _ReplayableOnboarding(),
              Positioned(
                top: 12,
                right: 12,
                child: IconButton(
                  icon: const Icon(Icons.close, color: AppColors.ink),
                  tooltip: 'close',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A non-destructive version of the onboarding screen. The window
/// picker is shown, but tapping "begin" just returns to the
/// settings page with the existing window unchanged.
class _ReplayableOnboarding extends ConsumerWidget {
  const _ReplayableOnboarding();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Show a one-tap version: just the wordmark + a brief note + close.
    // Keeps the replay lightweight — the user already saw the full
    // onboarding. This isn't a "show me the form" button; it's a
    // "remind me what the product is" button.
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top spacer to leave room for the close button.
          const SizedBox(height: 56),
          Align(
            alignment: Alignment.centerLeft,
            child: BrandMark.wordmark(
              size: 18,
              color: AppColors.teal,
              accent: AppColors.amber,
            ),
          ),
          const Spacer(flex: 1),
          const Text(
            'a daily practice,\nquietly.',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w400,
              color: AppColors.teal,
              height: 1.15,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'one short practice, once a day. that\'s the whole product.',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.inkSoft,
              height: 1.5,
            ),
          ),
          const Spacer(flex: 1),
          Center(
            child: TextButton(
              onPressed: () => WhatIsThisSheet.show(context),
              child: const Text(
                'what is this?',
                style: TextStyle(color: AppColors.amberDark),
              ),
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

/// "deeper practice" toggle row. When the user enables it, the
/// daily notification is scheduled (and future opt-in hooks like
/// home widget + lock screen widget will respect the same flag).
/// When disabled, all scheduled hooks are cancelled.
class _DeeperPracticeRow extends ConsumerStatefulWidget {
  const _DeeperPracticeRow();

  @override
  ConsumerState<_DeeperPracticeRow> createState() => _DeeperPracticeRowState();
}

class _DeeperPracticeRowState extends ConsumerState<_DeeperPracticeRow> {
  bool _busy = false;

  Future<void> _toggle(bool value) async {
    if (_busy) return;
    setState(() => _busy = true);
    final notifier = ref.read(practiceStateProvider.notifier);
    final window = ref.read(practiceStateProvider).window;
    try {
      if (value) {
        // Request permission first; the user can still see the
        // toggle in either state, but the notification only fires
        // if permission is granted.
        final granted = await NotificationService.instance.requestPermission();
        if (!mounted) return;
        if (granted) {
          await NotificationService.instance.scheduleDaily(window);
        } else {
          // Permission denied. The user can change their mind in
          // system settings; we still set the preference so the
          // hook activates when they grant permission later. (The
          // next time they open the app, we'd re-check and
          // schedule.) For now, schedule anyway — if permission is
          // missing, the system silently drops the notification.
          await NotificationService.instance.scheduleDaily(window);
        }
      } else {
        await NotificationService.instance.cancel();
      }
      await notifier.setDeeperPractice(value);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("couldn't change. try again."),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = ref.watch(practiceStateProvider).deeperPractice;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'daily reminder',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.ink,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  enabled
                      ? 'a quiet nudge at your window.'
                      : 'opt in for a gentle daily nudge.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.inkSoft,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            onChanged: _busy ? null : _toggle,
            activeColor: AppColors.teal,
            inactiveTrackColor: AppColors.line,
          ),
        ],
      ),
    );
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
        // Use inkSoft (AA on cream) for section headers. Previously
        // used mute which fails AA.
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.inkSoft,
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
            if (value.isNotEmpty)
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.inkSoft,
                ),
              ),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right,
                color: AppColors.muteDark,
                size: 18,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
