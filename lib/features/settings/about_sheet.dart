import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// About `hush.` — version, made by, open source licenses.
///
/// Dev info goes here, behind a tap. The main settings page is for
/// user actions, not for reading numbers.
class AboutSheet extends StatelessWidget {
  const AboutSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
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
            Center(child: BrandMark.wordmark(size: 28, color: AppColors.teal)),
            const SizedBox(height: 32),
            Text(
              'about hush.',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w400,
                color: AppColors.teal,
                height: 1.2,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'a daily practice, quietly.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.ink,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'hush. is a private journal for a daily moment of attention. '
              'one verse a day. no streak. no score. no data leaves the phone.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.inkSoft,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            _Link(
              label: 'open source licenses',
              onTap: () => showLicensePage(
                context: context,
                applicationName: 'hush.',
                applicationVersion: '0.1.0',
                applicationIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: BrandMark.wordmark(size: 18, color: AppColors.teal),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _Link(
              label: 'send feedback',
              onTap: () {
                // No mailto URL until launch. We can wire a deep link to
                // a Formspree / Buttondown / Tally form in v0.2.
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'made by pclub',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.mute,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cream,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const AboutSheet(),
    );
  }
}

class _Link extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _Link({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.teal,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.mute, size: 18),
          ],
        ),
      ),
    );
  }
}
