import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/streak_provider.dart';
import '../../core/storage/streak_store.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/prompts.dart';
import '../../core/widget/home_widget.dart';

/// The full-screen prayer view. Mirrors the Prayer Lock "tap the notification"
/// screen: app icon, "prayer lock" wordmark, and a single CTA to begin.
class PrayerScreen extends ConsumerStatefulWidget {
  const PrayerScreen({super.key});
  @override
  ConsumerState<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends ConsumerState<PrayerScreen> {
  bool _praying = false;
  int _elapsed = 0;
  Prompt? _prompt;

  @override
  void initState() {
    super.initState();
    PromptPicker.today().then((p) {
      if (mounted) setState(() => _prompt = p);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_praying) {
      return _entryView();
    }
    return _prayingView();
  }

  Widget _entryView() {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(flex: 1),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Center(
                  child: Icon(
                    Icons.lock_outline,
                    color: AppColors.white,
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'prayer lock',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w400,
                  color: AppColors.ink,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _prompt == null
                    ? 'preparing today\'s prayer…'
                    : 'today\'s prayer is ready',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.mute,
                ),
              ),
              const Spacer(flex: 2),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _prompt == null ? null : () {
                    setState(() => _praying = true);
                    _startTimer();
                  },
                  child: const Text('begin prayer'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _prayingView() {
    final p = _prompt;
    return Scaffold(
      backgroundColor: AppColors.soft,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 1),
              if (p != null) ...[
                Text(
                  p.ref,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.mute,
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '"${p.text}"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    height: 1.4,
                    color: AppColors.ink,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  _elapsedSecondsLabel(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w200,
                    color: AppColors.primary,
                    letterSpacing: -1,
                  ),
                ),
              ],
              const Spacer(flex: 2),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _complete,
                  child: const Text('mark complete'),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'not now',
                    style: TextStyle(color: AppColors.mute),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _elapsedSecondsLabel() {
    final m = (_elapsed ~/ 60).toString().padLeft(2, '0');
    final s = (_elapsed % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _startTimer() {
    _elapsed = 0;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || !_praying) return false;
      setState(() => _elapsed++);
      return _praying;
    });
  }

  Future<void> _complete() async {
    await ref.read(streakProvider.notifier).markPrayedToday();
    final store = ref.read(streakStoreProvider);
    await AppHomeWidget.instance.updateFromStore(store);
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'prayer complete · day ${ref.read(streakProvider).current} of your streak',
        ),
        backgroundColor: AppColors.ink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
