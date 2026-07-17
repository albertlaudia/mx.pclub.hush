import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/notifications/local_notifications.dart';
import '../../core/storage/streak_provider.dart';
import '../../core/storage/streak_store.dart';
import '../../core/theme/app_theme.dart';
import '../home/home_screen.dart';

/// First-launch onboarding. Three short screens:
///   1. "block your phone until you pray" — value prop
///   2. "use your screen time to put God first" — second value prop
///   3. "tap to start your streak" — CTA, request notification permission
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                children: const [
                  _Page(
                    title: 'block your phone\nuntil you pray',
                    body:
                        "every time you reach for a distracting app, you'll see this screen first. a 60-second prayer, then the app unlocks.",
                    icon: Icons.lock_outline,
                  ),
                  _Page(
                    title: 'use your screen time\nto put God first',
                    body:
                        "your streak grows with every prayer. the longer you keep it, the more your phone becomes a place of attention, not avoidance.",
                    icon: Icons.local_fire_department,
                  ),
                  _Page(
                    title: "tap to start\nyour streak",
                    body:
                        "we'll send a gentle reminder at the same time each day. you can change the time later. begin when you're ready.",
                    icon: Icons.flag_outlined,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Row(
                children: [
                  Row(
                    children: List.generate(3, (i) {
                      final active = i == _page;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: active ? 22 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.primary
                              : AppColors.primary.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 16),
                    ),
                    child: Text(_page == 2 ? 'begin' : 'next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _next() async {
    if (_page < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
      return;
    }
    // On last page: request permission, finish onboarding.
    final granted = await AppNotifications.instance.requestPermission();
    if (granted) {
      await AppNotifications.instance.scheduleDaily(hour: 8, minute: 0);
    }
    final store = ref.read(streakStoreProvider);
    await store.setOnboarded(true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }
}

class _Page extends StatelessWidget {
  final String title;
  final String body;
  final IconData icon;
  const _Page({
    required this.title,
    required this.body,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(icon, color: AppColors.white, size: 48),
          ),
          const SizedBox(height: 36),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
              height: 1.15,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            body,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.inkSoft,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
