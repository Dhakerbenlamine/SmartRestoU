import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_restou/app.dart';
import 'package:smart_restou/data/menu_items.dart';
import 'package:smart_restou/models/app_user.dart';
import 'package:smart_restou/models/menu_item.dart';
import 'package:smart_restou/services/smart_resto_api.dart';

void main() {
  testWidgets('authentication is the first screen without a saved session', (
    tester,
  ) async {
    final api = _FakeApi();
    await tester.pumpWidget(SmartRestoApp(api: api));
    await tester.pumpAndSettle();

    expect(find.text('Bon retour !'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('auth-email')),
      'etudiant@test.fr',
    );
    await tester.enterText(find.byKey(const Key('auth-password')), 'secret123');
    await tester.ensureVisible(find.byKey(const Key('auth-submit')));
    await tester.tap(find.byKey(const Key('auth-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Menus du restaurant'), findsOneWidget);
    expect(api.rememberedUserId, isNull);
  });

  testWidgets('admin menu screen loads and creates menus through the API', (
    tester,
  ) async {
    final api = _FakeApi(
      restoredUser: const AppUser(
        id: 'admin-1',
        name: 'Admin',
        email: 'admin@test.fr',
        role: 'admin',
      ),
      menus: const [],
    );
    await tester.pumpWidget(SmartRestoApp(api: api));
    await tester.pumpAndSettle();

    expect(find.text('Administration'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('admin-menu-name')),
      'Plat test',
    );
    await tester.enterText(
      find.byKey(const Key('admin-menu-description')),
      'Description test',
    );
    await tester.drag(find.byType(ListView).first, const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('admin-menu-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Plat test'), findsOneWidget);
    expect(api.menus, hasLength(1));
  });

  testWidgets('menu filters and reservation navigation work', (tester) async {
    await _pumpStudentApp(tester);

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
    await _pumpStudentApp(tester);

    await tester.tap(find.byKey(const Key('nav-reservation')));
    await tester.pumpAndSettle();
    expect(find.text('Réserver une Table'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Confirmer la Réservation'), 200);
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
    await _pumpStudentApp(tester);

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

  testWidgets('history shows empty states and returns to dashboard', (
    tester,
  ) async {
    await _pumpStudentApp(tester);

    await tester.tap(find.byKey(const Key('nav-history')));
    await tester.pumpAndSettle();

    expect(find.text('Mon Historique'), findsOneWidget);
    expect(find.text('Mes Réservations'), findsOneWidget);
    expect(find.text('Aucune réservation enregistrée.'), findsOneWidget);
    expect(find.text('Repas Consommés'), findsOneWidget);
    expect(
      find.textContaining('Aucun repas consommé enregistré.'),
      findsOneWidget,
    );
    expect(find.text('Etudiant Test'), findsNothing);

    await tester.tap(find.byKey(const Key('history-dashboard')));
    await tester.pumpAndSettle();
    expect(
      find.text('Retrouvez ici vos réservations et notifications.'),
      findsOneWidget,
    );
  });

  testWidgets('confirmed reservation appears on dashboard and history', (
    tester,
  ) async {
    await _pumpStudentApp(tester);

    await tester.tap(find.byKey(const Key('nav-reservation')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('reservation-date-time')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -180));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('guest-count')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2').last);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Confirmer la Réservation'), 200);
    await tester.tap(find.text('Confirmer la Réservation'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-reservation')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('nav-dashboard')), findsOneWidget);
    expect(find.text('Confirmation de réservation'), findsOneWidget);
    expect(find.text('Resto U Central'), findsOneWidget);
    expect(find.textContaining('2 personne(s)'), findsNWidgets(2));
    expect(find.text('À VENIR'), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav-history')));
    await tester.pumpAndSettle();
    expect(find.text('Resto U Central'), findsOneWidget);
    expect(find.textContaining('2 personne(s)'), findsOneWidget);
    expect(find.text('À VENIR'), findsOneWidget);
    expect(
      find.textContaining('Aucun repas consommé enregistré.'),
      findsOneWidget,
    );
  });

  testWidgets('filters can be reset and empty results are explained', (
    tester,
  ) async {
    await _pumpStudentApp(tester);

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

Future<void> _pumpStudentApp(WidgetTester tester) async {
  await tester.pumpWidget(SmartRestoApp(api: _FakeApi(restoredUser: _student)));
  await tester.pumpAndSettle();
}

const _student = AppUser(
  id: 'student-1',
  name: 'Étudiant',
  email: 'etudiant@test.fr',
  role: 'etudiant',
);

class _FakeApi implements SmartRestoApi {
  _FakeApi({this.restoredUser, List<MenuItem>? menus})
    : menus = List.of(menus ?? sampleMenuItems);

  final AppUser? restoredUser;
  final List<MenuItem> menus;
  String? rememberedUserId;

  @override
  Future<AppUser?> restoreSession() async => restoredUser;

  @override
  Future<AppUser?> login(String email, String password) async =>
      email == 'etudiant@test.fr' && password == 'secret123' ? _student : null;

  @override
  Future<void> signup(String name, String email, String password) async {}

  @override
  Future<void> rememberUser(String? userId) async {
    rememberedUserId = userId;
  }

  @override
  Future<void> logout() async {
    rememberedUserId = null;
  }

  @override
  Future<List<MenuItem>> getMenus() async => List.unmodifiable(menus);

  @override
  Future<void> createMenu(MenuItem menu) async {
    menus.add(
      MenuItem(
        id: 'menu-${menus.length + 1}',
        name: menu.name,
        description: menu.description,
        diet: menu.diet,
        type: menu.type,
        date: menu.date,
        available: menu.available,
        image: menu.image,
      ),
    );
  }

  @override
  Future<void> deleteMenu(String id) async {
    menus.removeWhere((menu) => menu.id == id);
  }
}
