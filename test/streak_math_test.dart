import 'package:flutter_test/flutter_test.dart';
import 'package:hush/core/utils/streak_math.dart';

void main() {
  group('StreakMath', () {
    test('dayKey normalizes to midnight', () {
      final t = DateTime(2026, 7, 14, 14, 32, 17, 500);
      expect(StreakMath.dayKey(t), DateTime(2026, 7, 14));
    });

    test('daysBetween same day is 0', () {
      final a = DateTime(2026, 7, 14);
      final b = DateTime(2026, 7, 14);
      expect(StreakMath.daysBetween(a, b), 0);
    });

    test('daysBetween one day apart is 1', () {
      final a = DateTime(2026, 7, 14);
      final b = DateTime(2026, 7, 15);
      expect(StreakMath.daysBetween(a, b), 1);
    });

    test('daysBetween handles b < a (returns 0)', () {
      final a = DateTime(2026, 7, 15);
      final b = DateTime(2026, 7, 14);
      expect(StreakMath.daysBetween(a, b), 0);
    });

    test('startOfWeek returns Monday', () {
      // 2026-07-15 is a Wednesday. Start of week should be 2026-07-13 (Monday).
      final wed = DateTime(2026, 7, 15);
      expect(StreakMath.startOfWeek(wed), DateTime(2026, 7, 13));
    });

    test('startOfWeek on Monday is the same day', () {
      final mon = DateTime(2026, 7, 13);
      expect(StreakMath.startOfWeek(mon), DateTime(2026, 7, 13));
    });

    test('iso produces yyyy-MM-dd', () {
      expect(StreakMath.iso(DateTime(2026, 7, 14)), '2026-07-14');
    });
  });
}
