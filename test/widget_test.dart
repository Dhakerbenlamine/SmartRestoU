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
    await tester.tap(find.text('Voir détails').first);
    await tester.pumpAndSettle();
    expect(find.text('Une recette végétale et crémeuse.'), findsNWidgets(2));

    await tester.tap(find.text('Réserver une table'));
    await tester.pumpAndSettle();

    expect(find.text('Réserver une Table'), findsOneWidget);
    expect(find.text('Resto U Central'), findsOneWidget);
    expect(find.text('Date et heure de la réservation'), findsOneWidget);
    expect(find.text('Nombre de personnes'), findsOneWidget);
    expect(find.byKey(const Key('reservation-date-time')), findsOneWidget);
  });

  testWidgets('reservation cancel returns to the menus', (tester) async {
    await tester.pumpWidget(const SmartRestoApp());

    await tester.tap(find.byKey(const Key('nav-reservation')));
    await tester.pumpAndSettle();
    expect(find.text('Réserver une Table'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Confirmer la Réservation'),
      200,
    );
    await tester.tap(find.text('Confirmer la Réservation'));
    await tester.pumpAndSettle();
    expect(
      find.text('Choisissez une date et une heure pour continuer.'),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Annuler'), 200);
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();

    expect(find.text('Menus du restaurant'), findsOneWidget);
  });

  testWidgets('dashboard uses generic empty states and opens reservations', (
    tester,
  ) async {
    await tester.pumpWidget(const SmartRestoApp());

    await tester.tap(find.byKey(const Key('nav-dashboard')));
    await tester.pumpAndSettle();

    expect(find.text('Mon espace'), findsNWidgets(2));
    expect(find.text('Mes notifications'), findsOneWidget);
    expect(find.text('Aucune notification pour le moment.'), findsOneWidget);
    expect(find.text('Mes réservations'), findsOneWidget);
    expect(find.text('Aucune réservation enregistrée.'), findsOneWidget);
    expect(find.text('Etudiant Test'), findsNothing);
    expect(find.text('Bonjour, Etudiant Test'), findsNothing);

    await tester.tap(find.byKey(const Key('dashboard-reserve')));
    await tester.pumpAndSettle();
    expect(find.text('Réserver une Table'), findsOneWidget);
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
