import 'package:home_widget/home_widget.dart';
import '../storage/streak_store.dart';

/// Bridge to the iOS / Android home screen widget.
///
/// On iOS the widget is a SwiftUI widget added as a Widget Extension target.
/// See `ios/RunnerWidget/` for the SwiftUI side. The Dart side calls
/// `HomeWidget.saveWidgetData` to push the current streak number to the
/// widget timeline, then `HomeWidget.updateWidget` to refresh.
class AppHomeWidget {
  AppHomeWidget._();
  static final instance = AppHomeWidget._();

  static const _iOSWidgetName = 'LockWidget';
  static const _androidWidgetName = 'LockWidgetProvider';

  Future<void> updateFromStore(StreakStore store) async {
    final streak = store.current;
    final best = store.best;
    final practiced = store.lastDay != null &&
        store.lastDay!.year == DateTime.now().year &&
        store.lastDay!.month == DateTime.now().month &&
        store.lastDay!.day == DateTime.now().day;

    try {
      await HomeWidget.saveWidgetData<int>('streak', streak);
      await HomeWidget.saveWidgetData<int>('best', best);
      await HomeWidget.saveWidgetData<bool>('practiced', practiced);
      await HomeWidget.saveWidgetData<String>(
        'label',
        streak == 1 ? '1-day streak' : '$streak-day streak',
      );
      await HomeWidget.updateWidget(
        name: _iOSWidgetName,
        androidName: _androidWidgetName,
        iOSName: _iOSWidgetName,
      );
    } catch (_) {
      // Widget may not be installed yet — silent fail is fine for MVP.
    }
  }
}
