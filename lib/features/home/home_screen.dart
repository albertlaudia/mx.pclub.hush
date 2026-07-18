import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/practice_state.dart';
import '../../core/storage/practice_state_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/prompts.dart';
import '../practice/practice_screen.dart';
import '../settings/settings_screen.dart';

/// Home — the only screen you'll see most days.
///
/// Today's practice card. A verse, a prompt, a "begin" button. That's it.
/// No streak. No flame. No "extraordinary! your prayer journey is an
/// inspiration" copy. No mood check-in. No Section. No widget. No
/// notification. The product is the practice.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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
    final state = ref.watch(practiceStateProvider);
    final practiced = state.practicedToday;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(),
              const SizedBox(height: 56),
              if (practiced)
                _PracticedState(prompt: _prompt)
              else
                _ActiveState(prompt: _prompt),
              const SizedBox(height: 48),
              _SettingsLink(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'good morning'
        : hour < 18
            ? 'good afternoon'
            : 'good evening';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BrandMark.wordmark(size: 18),
        const SizedBox(height: 24),
        Text(
          greeting,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.mute,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}

class _ActiveState extends ConsumerWidget {
  final Prompt? prompt;
  const _ActiveState({this.prompt});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = prompt;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "today's practice",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.amber,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12),
        if (p != null) ...[
          Text(
            p.ref,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.mute,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '"${p.text}"',
            style: const TextStyle(
              fontSize: 22,
              height: 1.4,
              color: AppColors.teal,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
            ),
          ),
        ] else
          Text(
            'preparing today\'s practice…',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.mute,
            ),
          ),
        const SizedBox(height: 36),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: p == null
                ? null
                : () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PracticeScreen(prompt: p),
                      ),
                    ),
            child: const Text('begin'),
          ),
        ),
      ],
    );
  }
}

class _PracticedState extends StatelessWidget {
  final Prompt? prompt;
  const _PracticedState({this.prompt});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.teal.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              BrandMark.dotInRing(size: 14),
              const SizedBox(width: 8),
              Text(
                'today is done',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.teal,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'see you tomorrow.',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w300,
            color: AppColors.teal,
            height: 1.2,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          prompt == null
              ? 'today\'s practice is complete.'
              : 'today\'s practice was "${prompt!.text}"',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.inkSoft,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _SettingsLink extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        ),
        child: const Text('settings'),
      ),
    );
  }
}
