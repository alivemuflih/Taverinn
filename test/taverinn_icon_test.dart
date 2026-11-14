import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/widgets/taverinn_icon.dart';

void main() {
  testWidgets('official Taverinn SVG paths load with semantics',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TaverinnIcon(
                key: ValueKey('party_icon'),
                assetPath: 'assets/icons/party.svg',
                size: 36,
                semanticLabel: 'Party',
              ),
              SizedBox(width: 16),
              TaverinnIcon(
                key: ValueKey('home_icon'),
                assetPath: 'assets/icons/home.svg',
                size: 36,
                semanticLabel: 'Home',
              ),
              SizedBox(width: 16),
              TaverinnIcon(
                key: ValueKey('brand_logo'),
                assetPath: 'assets/icons/taverinn_logo.svg',
                size: 48,
                semanticLabel: 'Taverinn',
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.bySemanticsLabel('Party'), findsOneWidget);
    expect(find.bySemanticsLabel('Home'), findsOneWidget);
    expect(find.bySemanticsLabel('Taverinn'), findsOneWidget);
  });
}
