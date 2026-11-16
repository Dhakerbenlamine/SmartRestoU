import 'package:flutter_test/flutter_test.dart';
import 'package:smart_restou/app.dart';

void main() {
  testWidgets('SmartRestoU opens the menu and navigates to reservations',
      (tester) async {
    await tester.pumpWidget(const SmartRestoApp());

    expect(find.text('Menus du restaurant'), findsOneWidget);
    expect(find.text('Risotto aux légumes'), findsOneWidget);

    await tester.tap(find.text('Réserver'));
    await tester.pumpAndSettle();

    expect(find.text('Réserver une table'), findsOneWidget);
  });
}
