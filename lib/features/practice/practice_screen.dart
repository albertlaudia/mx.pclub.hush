import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/practice_state_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/prompts.dart';

/// Practice — the moment. A verse, a moment of attention, a quiet
/// "done" button. No timer. No countdown. No "you prayed for 1:32".
/// The user is in the practice, not in a metric.
class PracticeScreen extends ConsumerStatefulWidget {
  final Prompt prompt;
  const PracticeScreen({super.key, required this.prompt});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  bool _done = false;

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
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Spacer(flex: 1),
              Text(
                widget.prompt.ref,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.amber,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: AppColors.creamSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'a moment of attention.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mute,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'read the verse. let it land. then continue.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.inkSoft,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              if (_done)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BrandMark.dotInRing(size: 18),
                        const SizedBox(width: 12),
                        Text(
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
                    onPressed: _complete,
                    child: const Text('done'),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _complete() async {
    await ref.read(practiceStateProvider.notifier).markPracticed();
    if (!mounted) return;
    setState(() => _done = true);
    // Pop back to home after a brief moment so the user sees the
    // "see you tomorrow" acknowledgment.
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) Navigator.of(context).pop();
    });
  }
}
