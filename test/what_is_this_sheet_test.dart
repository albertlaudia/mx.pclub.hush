import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lock/core/theme/app_theme.dart';
import 'package:lock/core/ui/what_is_this_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders the wordmark, headline, four points, and got-it button',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WhatIsThisSheet(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Headline.
    expect(find.text('what is this?'), findsOneWidget);

    // The four brand-locked points.
    expect(find.text('one short practice, once a day.'), findsOneWidget);
    expect(find.text('read one verse. attend to it. continue.'),
        findsOneWidget);
    expect(find.text('no streak. no score. no notification reminders.'),
        findsOneWidget);
    expect(find.text('no data leaves this phone.'), findsOneWidget);

    // The got-it button dismisses the sheet.
    expect(find.widgetWithText(ElevatedButton, 'got it'), findsOneWidget);
  });

  testWidgets('"got it" button pops the sheet', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => WhatIsThisSheet.show(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('what is this?'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'got it'));
    await tester.pumpAndSettle();
    expect(find.text('what is this?'), findsNothing);
  });
}
