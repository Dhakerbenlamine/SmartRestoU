import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_restou/app.dart';

void main() {
  testWidgets('menu filters and reservation navigation work', (tester) async {
    await tester.pumpWidget(const SmartRestoApp());

    expect(find.text('Menus du restaurant'), findsOneWidget);
    await tester.tap(find.byKey(const Key('diet-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Vegan').last);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Risotto aux légumes'), 200);
    expect(find.text('Risotto aux légumes'), findsOneWidget);
    expect(find.text('Filet de bœuf aux herbes'), findsNothing);

    await tester.drag(find.byType(ListView), const Offset(0, -180));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Voir détails'));
    await tester.pumpAndSettle();
    expect(find.text('Une recette végétale et crémeuse.'), findsNWidgets(2));

    await tester.tap(find.text('Réserver une table'));
    await tester.pumpAndSettle();

    expect(find.text('Réserver une table'), findsOneWidget);
    expect(
      find.text('Choisissez votre repas et réservez votre place.'),
      findsOneWidget,
    );
  });

  testWidgets('filters can be reset and empty results are explained', (
    tester,
  ) async {
    await tester.pumpWidget(const SmartRestoApp());

    await tester.tap(find.byKey(const Key('diet-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Vegan').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('type-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Menu de la semaine').last);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Aucun menu ne correspond à ces filtres.'),
      200,
    );
    expect(
      find.text('Aucun menu ne correspond à ces filtres.'),
      findsOneWidget,
    );
  });
}
