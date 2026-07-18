import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/storage/practice_state_provider.dart';
import 'core/storage/practice_state.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = await PracticeStateStore.open();
  runApp(ProviderScope(
    overrides: [practiceStoreProvider.overrideWithValue(store)],
    child: const LockApp(),
  ));
}

class LockApp extends StatelessWidget {
  const LockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'lock.',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const _Gate(),
    );
  }
}

class _Gate extends ConsumerWidget {
  const _Gate();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarded = ref.watch(practiceStateProvider).onboarded;
    return onboarded ? const HomeScreen() : const OnboardingScreen();
  }
}
