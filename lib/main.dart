import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/notifications/notification_service.dart';
import 'core/storage/practice_state.dart';
import 'core/storage/practice_state_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Lock to portrait — the layouts are designed for it.
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final store = await PracticeStateStore.open();
  // Initialize the notification service. This is a no-op if the user
  // hasn't opted into "deeper practice" — the service just doesn't
  // schedule anything. We initialize anyway so the platform channel
  // is ready when the user opts in from settings.
  await NotificationService.instance.initialize();
  // If the user previously opted in (before this version), re-schedule
  // the daily notification with the current window. This handles app
  // upgrades and the case where the user changed their window.
  if (store.read().deeperPractice) {
    await NotificationService.instance.scheduleDaily(store.read().window);
  }
  runApp(ProviderScope(
    overrides: [practiceStoreProvider.overrideWithValue(store)],
    child: const HushApp(),
  ));
}

class HushApp extends StatelessWidget {
  const HushApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'hush.',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
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
