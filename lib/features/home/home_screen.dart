import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/practice_state_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/verse_preview.dart';
import '../../core/ui/what_is_this_sheet.dart';
import '../../core/utils/prompts.dart';
import '../practice/practice_screen.dart';
import '../settings/settings_screen.dart';

/// Home — the only screen you'll see most days.
///
/// The home is a *preview* of the practice. It shows the reference and
/// the first few words of the verse, plus a "what is this?" link for
/// new users. The full verse is reserved for the practice moment.
///
/// No streak. No flame. No "extraordinary! your prayer journey is an
/// inspiration" copy. The product is the practice.
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
          style: const TextStyle(
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
        const Text(
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
          // The reference — small, all-caps, amber. The hint of what's coming.
          Text(
            p.ref,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.amber,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),
          // The verse preview — first 6 words, italicized. A taste, not
          // the full thing. The practice screen reveals the rest.
          Text(
            versePreviewText(p.text),
            style: const TextStyle(
              fontSize: 18,
              height: 1.4,
              color: AppColors.ink,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
            ),
          ),
        ] else
          const Text(
            'preparing today\'s practice…',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.mute,
            ),
          ),
        const SizedBox(height: 12),
        // The "what is this?" affordance — for users who want context
        // before they commit to the practice.
        TextButton(
          onPressed: () => WhatIsThisSheet.show(context),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'what is this?',
            style: TextStyle(
              color: AppColors.amber,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: p == null
                ? null
                : () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
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
              const Text(
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
        const Text(
          'see you tomorrow.',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w300,
            color: AppColors.teal,
            height: 1.2,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        // Reference only — no full verse. The brand says the practice is
        // the moment, not the archive.
        Text(
          prompt == null
              ? 'today\'s practice is complete.'
              : "today's practice was ${prompt!.ref.toLowerCase()}.",
          style: const TextStyle(
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
          MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
        ),
        child: const Text('settings'),
      ),
    );
  }
}
