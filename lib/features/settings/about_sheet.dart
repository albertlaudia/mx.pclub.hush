import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';

/// About `hush.` — version, made by, open source licenses, feedback.
///
/// Dev info goes here, behind a tap. The main settings page is for
/// user actions, not for reading numbers.
class AboutSheet extends StatelessWidget {
  const AboutSheet({super.key});

  // The contact email for feedback. The domain (`hush.app`) is the
  // planned future web address; until it's live, the mailto will
  // open the user's mail client with the address pre-filled but
  // possibly undeliverable.
  static const _feedbackEmail = 'hello@hush.app';

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
            Center(
              child: BrandMark.wordmark(
                size: 28,
                color: AppColors.teal,
                accent: AppColors.amber,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
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
            const Text(
              'a daily practice, quietly.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.ink,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
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
              onTap: () => _openLicenses(context),
            ),
            const SizedBox(height: 12),
            _Link(
              label: 'send feedback',
              onTap: () => _sendFeedback(context),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'made by pclub',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.inkSoft,
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
      // Drag-to-dismiss (iOS pattern).
      enableDrag: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const AboutSheet(),
    );
  }

  void _openLicenses(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: 'hush.',
      applicationVersion: '0.1.0',
      // A small wordmark for the license page. Wrapped so it sits in
      // the icon area without disrupting the standard layout.
      applicationIcon: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BrandMark.wordmark(
          size: 18,
          color: AppColors.teal,
          accent: AppColors.amber,
        ),
      ),
    );
  }

  Future<void> _sendFeedback(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: _feedbackEmail,
      // Pre-fill subject and body. The user can edit before sending.
      queryParameters: {
        'subject': 'hush. feedback',
        'body': 'hi —\n\n',
      },
    );
    try {
      // Try the mailto URL first; if the device has no mail client
      // (rare on iOS/Android), fall back to a no-op.
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Silently fail. The brand says no copy that shouts; the user
      // will figure out there's no mail client.
    }
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
            const Icon(
              Icons.chevron_right,
              color: AppColors.muteDark,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
