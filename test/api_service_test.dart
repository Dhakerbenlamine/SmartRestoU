import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_restou/models/menu_item.dart';
import 'package:smart_restou/services/api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('login sends the API payload and parses the user', () async {
    final service = ApiService(
      client: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, endsWith('/auth/login'));
        expect(jsonDecode(request.body), {
          'email': 'user@example.com',
          'motDePasse': 'secret123',
        });
        return http.Response(
          jsonEncode({
            'id': 'user-1',
            'nom': 'Étudiant',
            'email': 'user@example.com',
            'role': 'etudiant',
            'accessToken': 'test-access-token',
          }),
          200,
        );
      }),
    );

    final user = await service.login('user@example.com', 'secret123');

    expect(user?.id, 'user-1');
    expect(user?.isAdmin, isFalse);
  });

  test('restores a remembered user through the users endpoint', () async {
    final service = ApiService(
      client: MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, endsWith('/utilisateurs/user-1'));
        expect(request.headers['authorization'], 'Bearer saved-token');
        return http.Response(
          jsonEncode({
            'id': 'user-1',
            'nom': 'Admin',
            'email': 'admin@example.com',
            'role': 'admin',
          }),
          200,
        );
      }),
    );
    await service.rememberUser('user-1');
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('smart_restou_access_token', 'saved-token');

    final user = await service.restoreSession();

    expect(user?.isAdmin, isTrue);
  });

  test('uses the login access token for protected admin operations', () async {
    var requestCount = 0;
    final service = ApiService(
      client: MockClient((request) async {
        requestCount++;
        if (requestCount == 1) {
          return http.Response(
            jsonEncode({
              'id': 'admin-1',
              'nom': 'Admin',
              'email': 'admin@example.com',
              'role': 'admin',
              'accessToken': 'admin-token',
            }),
            200,
          );
        }
        expect(request.headers['authorization'], 'Bearer admin-token');
        expect(request.method, 'POST');
        return http.Response('{"id":"menu-2"}', 201);
      }),
    );

    await service.login('admin@example.com', 'secret123');
    await service.createMenu(
      MenuItem(
        id: '',
        name: 'Nouveau plat',
        description: 'Description',
        diet: 'Standard',
        type: 'Menu du jour',
        date: DateTime(2026, 11, 23),
      ),
    );
  });

  test(
    'menu list and create requests use the documented JSON fields',
    () async {
      final service = ApiService(
        client: MockClient((request) async {
          if (request.method == 'GET') {
            expect(request.url.path, endsWith('/menus'));
            return http.Response(
              jsonEncode([
                {
                  'id': 'menu-1',
                  'nom': 'Riz aux légumes',
                  'description': 'Plat du jour',
                  'regime': 'Vegan',
                  'type': 'Menu semaine',
                  'date': '2026-11-23',
                  'disponible': true,
                  'image': null,
                },
              ]),
              200,
            );
          }

          expect(request.method, 'POST');
          expect(request.url.path, endsWith('/menus'));
          expect(jsonDecode(request.body), {
            'nom': 'Nouveau plat',
            'description': 'Description',
            'regime': 'Standard',
            'type': 'Menu semaine',
            'date': '2026-11-23',
            'disponible': true,
            'image': null,
          });
          return http.Response('{"id":"menu-2"}', 201);
        }),
      );

      final menus = await service.getMenus();
      expect(menus.single.type, 'Menu semaine');
      await service.createMenu(
        MenuItem(
          id: '',
          name: 'Nouveau plat',
          description: 'Description',
          diet: 'Standard',
          type: 'Menu de la semaine',
          date: DateTime(2026, 11, 23),
        ),
      );
    },
  );
}
