import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/practice_state.dart';
import '../../core/storage/practice_state_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/what_is_this_sheet.dart';
import '../home/home_screen.dart';

/// Onboarding — a single screen. Pick a practice window, then begin.
///
/// The 3-screen onboarding of the previous version is gone. The product is
/// the practice. One screen, one question, one button. The product asks
/// only what it needs to deliver the practice.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  PracticeWindow? _window;
  bool _saving = false;

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
              const SizedBox(height: 40),
              // Use inkSoft (AA on cream) for the prompt, not mute.
              const Text(
                'when do you want to practice?',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.inkSoft,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              _WindowOption(
                label: 'morning',
                detail: '6 – 9 am',
                value: PracticeWindow.morning,
                selected: _window == PracticeWindow.morning,
                onTap: () => _select(PracticeWindow.morning),
              ),
              const SizedBox(height: 10),
              _WindowOption(
                label: 'midday',
                detail: '11 am – 2 pm',
                value: PracticeWindow.midday,
                selected: _window == PracticeWindow.midday,
                onTap: () => _select(PracticeWindow.midday),
              ),
              const SizedBox(height: 10),
              _WindowOption(
                label: 'evening',
                detail: '8 – 10 pm',
                value: PracticeWindow.evening,
                selected: _window == PracticeWindow.evening,
                onTap: () => _select(PracticeWindow.evening),
              ),
              const SizedBox(height: 10),
              _WindowOption(
                label: 'anytime',
                detail: 'no specific time',
                value: PracticeWindow.anytime,
                selected: _window == PracticeWindow.anytime,
                onTap: () => _select(PracticeWindow.anytime),
              ),
              const SizedBox(height: 20),
              // "What is this?" affordance — new users want context
              // before they commit. Same sheet as the home screen.
              Center(
                child: TextButton(
                  onPressed: () => WhatIsThisSheet.show(context),
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
              ),
              const Spacer(flex: 2),
              ElevatedButton(
                onPressed: _window == null || _saving ? null : _begin,
                child: Text(_saving ? 'saving' : 'begin'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _select(PracticeWindow w) {
    if (_saving) return;
    setState(() => _window = w);
  }

  Future<void> _begin() async {
    if (_window == null || _saving) return;
    setState(() => _saving = true);
    final notifier = ref.read(practiceStateProvider.notifier);
    try {
      await notifier.setWindow(_window!);
      await notifier.completeOnboarding();
      if (!mounted) return;
      unawaited(
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      // Reset the saving flag so the user can tap again. Show an
      // error so they know what happened.
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("couldn't save. try again."),
        ),
      );
    }
  }
}

class _WindowOption extends StatelessWidget {
  final String label;
  final String detail;
  final PracticeWindow value;
  final bool selected;
  final VoidCallback onTap;

  const _WindowOption({
    required this.label,
    required this.detail,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: selected ? AppColors.teal : AppColors.creamSoft,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.teal : AppColors.line,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: selected ? AppColors.cream : AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    style: TextStyle(
                      fontSize: 12,
                      // Use amberDark/creamSoft for AA compliance in
                      // both selected and unselected states.
                      color: selected
                          ? AppColors.creamSoft
                          : AppColors.inkSoft,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check : Icons.circle_outlined,
              color: selected ? AppColors.cream : AppColors.muteDark,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}


