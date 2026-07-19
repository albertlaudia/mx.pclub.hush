import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hush/core/theme/app_theme.dart';
import 'package:hush/features/settings/about_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders the wordmark, about copy, and links', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AboutSheet(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Headline.
    expect(find.text('about hush.'), findsOneWidget);
    // Tagline.
    expect(find.text('a daily practice, quietly.'), findsOneWidget);
    // Brand-locked byline.
    expect(find.text('made by pclub'), findsOneWidget);

    // License + feedback links.
    expect(find.text('open source licenses'), findsOneWidget);
    expect(find.text('send feedback'), findsOneWidget);
  });

  testWidgets('opening from a Scaffold shows the sheet', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => AboutSheet.show(context),
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
    expect(find.text('about hush.'), findsOneWidget);
  });
}
