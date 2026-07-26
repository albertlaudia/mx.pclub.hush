import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// "what is this?" — the on-brand explanation of `hush.`
///
/// Four short lines, one button. Used from:
///   - the home screen link
///   - the settings page "help" section
///
/// The copy is brand-locked: lowercase, no exclamation marks, no
/// superlatives, no guilt, no promises. The product is a private
/// journal — we explain what it isn't as much as what it is.
class WhatIsThisSheet extends StatelessWidget {
  const WhatIsThisSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 12, 28, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 4, bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            BrandMark.wordmark(size: 22, color: AppColors.teal),
            const SizedBox(height: 32),
            const Text(
              'what is this?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w400,
                color: AppColors.teal,
                height: 1.2,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 24),
            const _Line(
              headline: 'one short practice, once a day.',
            ),
            const SizedBox(height: 20),
            const _Line(
              headline: 'read one verse. attend to it. continue.',
            ),
            const SizedBox(height: 20),
            const _Line(
              headline: 'no streak. no score. no notification reminders.',
            ),
            const SizedBox(height: 20),
            const _Line(
              headline: 'no data leaves this phone.',
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('got it'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// Show the sheet from any context.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cream,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const WhatIsThisSheet(),
    );
  }
}

class _Line extends StatelessWidget {
  final String headline;
  const _Line({required this.headline});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(right: 14, top: 8),
            decoration: const BoxDecoration(
              color: AppColors.amber,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Expanded(
          child: Text(
            headline,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.ink,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
