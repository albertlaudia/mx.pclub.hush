import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/streak_provider.dart';
import '../../core/storage/streak_store.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widget/home_widget.dart';
import '../../core/utils/streak_math.dart';
import '../prayer/prayer_screen.dart';
import '../checkin/god_checkin_screen.dart';
import '../mood/feeling_checkin_screen.dart';

/// Home screen — the "you have a 70 day streak" view.
///
/// Matches the Prayer Lock design reference:
///   - Big flame + day number in the center
///   - Weekly progress row underneath
///   - "extraordinary! your prayer journey is an inspiration to all"
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Push current state to the home widget on first build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final store = ref.read(streakStoreProvider);
      AppHomeWidget.instance.updateFromStore(store);
    });
  }

  @override
  Widget build(BuildContext context) {
    final streak = ref.watch(streakProvider);
    final store = ref.read(streakStoreProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              _Header(),
              const SizedBox(height: 24),
              _StreakDisplay(streak: streak),
              const SizedBox(height: 12),
              _EncouragementLine(streak: streak),
              const SizedBox(height: 28),
              _WeekRow(store: store),
              const SizedBox(height: 32),
              _ActionRow(),
              const SizedBox(height: 16),
              _SecondaryActions(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final best = ref.watch(streakProvider).best;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'prayer lock',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
            letterSpacing: -0.2,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_fire_department,
                  size: 16, color: AppColors.primaryDark),
              const SizedBox(width: 4),
              Text(
                'best $best',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StreakDisplay extends StatelessWidget {
  final StreakState streak;
  const _StreakDisplay({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: BoxDecoration(
        color: AppColors.soft,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text('🔥', style: const TextStyle(fontSize: 80, height: 1.0)),
          const SizedBox(height: 16),
          Text(
            '${streak.current}',
            style: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.w300,
              color: AppColors.ink,
              height: 1.0,
              letterSpacing: -2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'day streak',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}

class _EncouragementLine extends StatelessWidget {
  final StreakState streak;
  const _EncouragementLine({required this.streak});

  @override
  Widget build(BuildContext context) {
    final lines = _linesFor(streak.current);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        lines,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15,
          color: AppColors.inkSoft,
          height: 1.4,
        ),
      ),
    );
  }

  String _linesFor(int n) {
    if (n == 0) return 'one prayer away from a streak. tap below to begin.';
    if (n == 1) return 'day one. the hardest and the holiest.';
    if (n < 4) return 'keep going. momentum is built one day at a time.';
    if (n < 7) return 'a small rhythm is forming. stay with it.';
    if (n < 14) return 'extraordinary! your prayer journey is an inspiration to all';
    if (n < 30) return 'remarkable consistency. you are building something.';
    if (n < 60) return 'a month of practice. this is no longer a streak. this is a life.';
    if (n < 100) return 'extraordinary! your prayer journey is an inspiration to all';
    return 'a true disciple. extraordinary! your prayer journey is an inspiration to all';
  }
}

class _WeekRow extends StatelessWidget {
  final StreakStore store;
  const _WeekRow({required this.store});

  @override
  Widget build(BuildContext context) {
    final today = StreakMath.today();
    final weekStart = StreakMath.startOfWeek(today);
    final last = store.lastDay;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (i) {
          final d = weekStart.add(Duration(days: i));
          final isToday = StreakMath.dayKey(d) == StreakMath.dayKey(today);
          final practiced = last != null &&
              !d.isAfter(StreakMath.dayKey(last)) &&
              d.isAfter(StreakMath.dayKey(last).subtract(const Duration(days: 1)));
          // A simpler rule: any day <= last is "practiced" if the streak covered it.
          // For the MVP we just mark today if practiced; past days use streak continuity.
          return _DayCell(
            abbrev: StreakMath.dayAbbrev(d),
            number: d.day,
            isToday: isToday,
            practiced: _wasPracticed(d, last),
          );
        }),
      ),
    );
  }

  bool _wasPracticed(DateTime d, DateTime? last) {
    if (last == null) return false;
    final dKey = StreakMath.dayKey(d);
    final today = StreakMath.dayKey(DateTime.now());
    if (dKey.isAfter(today)) return false;
    if (dKey.isAfter(StreakMath.dayKey(last))) return false;
    // Did the streak cover this day? The streak covers every day from
    // (last - current+1) up to (last). For the MVP, treat days within the
    // streak window as practiced.
    final streak = (DateTime.now().difference(last).inDays);
    final covered = today.subtract(Duration(days: streak));
    return !dKey.isBefore(covered);
  }
}

class _DayCell extends StatelessWidget {
  final String abbrev;
  final int number;
  final bool isToday;
  final bool practiced;
  const _DayCell({
    required this.abbrev,
    required this.number,
    required this.isToday,
    required this.practiced,
  });

  @override
  Widget build(BuildContext context) {
    final circleColor = practiced ? AppColors.primary : AppColors.line;
    final textColor = practiced ? AppColors.white : AppColors.mute;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          abbrev,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.mute,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
            border: isToday
                ? Border.all(color: AppColors.primaryDark, width: 2)
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: TextStyle(
              fontSize: 13,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final practiced = ref.watch(streakProvider).practicedToday;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: practiced
            ? null
            : () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const PrayerScreen()),
                );
              },
        child: Text(practiced ? "today is done ✓" : "pray now"),
      ),
    );
  }
}

class _SecondaryActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const GodCheckinScreen()));
            },
            icon: const Text('✝️', style: TextStyle(fontSize: 16)),
            label: const Text('check in with God'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.ink,
              side: const BorderSide(color: AppColors.line),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const FeelingCheckinScreen()));
            },
            icon: const Text('😊', style: TextStyle(fontSize: 16)),
            label: const Text('how i feel'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.ink,
              side: const BorderSide(color: AppColors.line),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
