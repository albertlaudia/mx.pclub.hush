import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/practice_state_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/prompts.dart';

/// Practice — the moment. The user has tapped "begin" on the home
/// screen. Now they get:
///
///   1. An 800ms breathing space (only the wordmark is visible).
///   2. The verse fades in over 400ms — the moment of attention.
///   3. The "continue" button, with a single light haptic on tap.
///   4. "see you tomorrow" + 1500ms, then back to home.
///
/// No timer. No countdown. No "you prayed for 1:32". The user is in
/// the practice, not in a metric.
class PracticeScreen extends ConsumerStatefulWidget {
  final Prompt prompt;
  const PracticeScreen({super.key, required this.prompt});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  // State machine:
  //   false = the breathing space; only the wordmark is visible.
  //   true  = the verse has faded in; the "continue" button is live.
  bool _verseRevealed = false;
  bool _done = false;
  bool _completing = false;
  Timer? _revealTimer;
  Timer? _autoPopTimer;

  @override
  void initState() {
    super.initState();
    // 800ms is enough time for the user to put the phone down, look up,
    // and "arrive" at the practice before the verse appears. Cancelled
    // in dispose() so a manual pop doesn't trigger a dangling setState.
    _revealTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _verseRevealed = true);
    });
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    _revealTimer = null;
    _autoPopTimer?.cancel();
    _autoPopTimer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BrandMark.wordmark(size: 16),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.mute),
                    onPressed:
                        _done ? null : () => Navigator.of(context).pop(),
                    tooltip: 'close',
                  ),
                ],
              ),
              // The breathing space — only the wordmark is visible until
              // the reveal timer fires.
              Expanded(
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _verseRevealed ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    child: _verseBlock(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // The "a moment of attention" prompt. Stays visible throughout.
              // It's the cue that tells the user what to do.
              const Text(
                'a moment of attention.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mute,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _verseRevealed
                    ? 'read the verse. let it land. then continue.'
                    : 'read the verse when it appears. let it land.',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.inkSoft,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              if (_done)
                Center(
                  child: AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BrandMark.dotInRing(size: 18),
                        const SizedBox(width: 12),
                        const Text(
                          'see you tomorrow.',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.teal,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    // Disable until the verse is revealed and the save is
                    // in flight. The label changed from "done" to
                    // "continue" — the user is continuing their day, not
                    // finishing a task.
                    onPressed:
                        _completing || !_verseRevealed ? null : _complete,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        _verseRevealed ? 'continue' : '...',
                        key: ValueKey(_verseRevealed),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// The verse block — reference + text. Wrapped in a single widget so
  /// the AnimatedOpacity above can fade it in as one piece.
  Widget _verseBlock() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.prompt.ref,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.amber,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          '"${widget.prompt.text}"',
          style: const TextStyle(
            fontSize: 26,
            height: 1.4,
            color: AppColors.teal,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Future<void> _complete() async {
    if (_completing) return;
    setState(() => _completing = true);
    // A single light haptic confirms the moment landed. The brand is
    // tactile — "hush." is a verb, a hush on the world, a moment sealed.
    unawaited(HapticFeedback.lightImpact());
    try {
      await ref.read(practiceStateProvider.notifier).markPracticed();
      if (!mounted) return;
      setState(() => _done = true);
      // Pop back to home after a brief moment so the user sees the
      // "see you tomorrow" acknowledgment. The timer is cancelled in
      // dispose() so a manual pop never causes a dangling call.
      _autoPopTimer = Timer(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        Navigator.of(context).pop();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _completing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("couldn't save. try again."),
          backgroundColor: AppColors.ink,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
