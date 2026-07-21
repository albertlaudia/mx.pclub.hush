import 'dart:async';

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
  // The greeting changes at midnight. We schedule a single timer to
  // rebuild the header so the user doesn't see "good evening" at 1am.
  Timer? _midnightTimer;

  @override
  void initState() {
    super.initState();
    _loadPrompt();
    _scheduleMidnightRebuild();
  }

  @override
  void dispose() {
    _midnightTimer?.cancel();
    _midnightTimer = null;
    super.dispose();
  }

  Future<void> _loadPrompt() async {
    try {
      final p = await PromptPicker.today();
      if (mounted) setState(() => _prompt = p);
    } catch (e) {
      // PromptPicker.today() has a try/catch with a hardcoded fallback,
      // so this should never throw. But if it does, the home will show
      // "preparing today's practice…" indefinitely. Better to log and
      // surface a fallback than to crash.
      if (kDebugMode) {
        debugPrint('HomeScreen: failed to load prompt: $e');
      }
    }
  }

  /// Schedule a single timer to fire at the next local midnight so the
  /// greeting updates automatically. Then schedule the next one.
  void _scheduleMidnightRebuild() {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day)
        .add(const Duration(days: 1));
    _midnightTimer?.cancel();
    _midnightTimer = Timer(nextMidnight.difference(now), () {
      if (!mounted) return;
      setState(() {});
      _scheduleMidnightRebuild();
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
              const _Header(),
              const SizedBox(height: 56),
              if (practiced)
                _PracticedState(prompt: _prompt)
              else
                _ActiveState(prompt: _prompt),
              const SizedBox(height: 48),
              const _SettingsLink(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 5
        ? 'good evening' // late night reads as evening
        : hour < 12
            ? 'good morning'
            : hour < 18
                ? 'good afternoon'
                : 'good evening';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BrandMark.wordmark(
          size: 18,
          color: AppColors.teal,
          accent: AppColors.amber,
        ),
        const SizedBox(height: 24),
        // Use amberDark (AA on cream) for the greeting tag.
        Text(
          greeting,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.amberDark,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}

class _ActiveState extends StatelessWidget {
  final Prompt? prompt;
  const _ActiveState({this.prompt});

  @override
  Widget build(BuildContext context) {
    final p = prompt;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label: use amberDark for AA compliance on cream.
        const Text(
          "today's practice",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.amberDark,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12),
        if (p != null) ...[
          // The reference — small caps, amberDark (AA on cream).
          Text(
            p.ref,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.amberDark,
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
              color: AppColors.inkSoft,
            ),
          ),
        const SizedBox(height: 12),
        // The "what is this?" affordance — AA-compliant amberDark.
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
              color: AppColors.amberDark,
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
            // Solid pill background for AA compliance regardless of
            // what's behind. Previously used a teal-with-alpha tint
            // which gave ~3:1 contrast on cream.
            color: AppColors.creamSoft,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.line, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              BrandMark.dotInRing(
                size: 14,
                color: AppColors.teal,
              ),
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
        // Reference shown with original casing — "Psalm 46:10" — for
        // consistency with the verse source. Brand says lowercase
        // for UI labels, not for the actual text.
        Text(
          prompt == null
              ? 'today\'s practice is complete.'
              : "today's practice was ${prompt!.ref}.",
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
  const _SettingsLink();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        ),
        child: const Text(
          'settings',
          style: TextStyle(color: AppColors.inkSoft),
        ),
      ),
    );
  }
}
