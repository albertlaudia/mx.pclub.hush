import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/notifications/local_notifications.dart';
import 'core/storage/streak_provider.dart';
import 'core/storage/streak_store.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = await StreakStore.open();
  await AppNotifications.instance.init();
  runApp(ProviderScope(
    overrides: [streakStoreProvider.overrideWithValue(store)],
    child: const LockApp(),
  ));
}

class LockApp extends StatelessWidget {
  const LockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'prayer lock',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const _Gate(),
    );
  }
}

/// Routes to onboarding or home based on whether the user has finished onboarding.
class _Gate extends ConsumerWidget {
  const _Gate();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(streakStoreProvider);
    return store.onboarded ? const HomeScreen() : const OnboardingScreen();
  }
}
