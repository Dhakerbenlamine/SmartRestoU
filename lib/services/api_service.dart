import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_restou/models/app_user.dart';
import 'package:smart_restou/models/menu_item.dart';
import 'package:smart_restou/services/api_config.dart';
import 'package:smart_restou/services/smart_resto_api.dart';

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ApiService implements SmartRestoApi {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  static const _storedUserIdKey = 'smart_restou_user_id';
  static const _storedAccessTokenKey = 'smart_restou_access_token';
  static const _requestTimeout = Duration(seconds: 20);
  final http.Client _client;
  String? _accessToken;

  Uri _uri(String path) {
    final base = ApiConfig.baseUrl.endsWith('/')
        ? ApiConfig.baseUrl.substring(0, ApiConfig.baseUrl.length - 1)
        : ApiConfig.baseUrl;
    return Uri.parse('$base$path');
  }

  Future<http.Response> _send(Future<http.Response> request) async {
    try {
      return await request.timeout(_requestTimeout);
    } on TimeoutException {
      throw const ApiException(
        'Le serveur met trop de temps à répondre. Réessayez.',
      );
    } on http.ClientException catch (error) {
      throw ApiException('Impossible de joindre le serveur : ${error.message}');
    }
  }

  Map<String, String> _headers({bool includeAuthorization = true}) => {
    'Accept': 'application/json',
    if (includeAuthorization && _accessToken != null)
      'Authorization': 'Bearer $_accessToken',
  };

  Future<http.Response> _get(String path) =>
      _send(_client.get(_uri(path), headers: _headers()));

  Future<http.Response> _post(
    String path,
    Map<String, Object?> body, {
    bool includeAuthorization = true,
  }) => _send(
    _client.post(
      _uri(path),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (includeAuthorization && _accessToken != null)
          'Authorization': 'Bearer $_accessToken',
      },
      body: jsonEncode(body),
    ),
  );

  Future<http.Response> _delete(String path) =>
      _send(_client.delete(_uri(path), headers: _headers()));

  Map<String, dynamic> _decodeObject(http.Response response) {
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) return decoded;
    throw const ApiException('Réponse serveur invalide.');
  }

  ApiException _responseError(String action, http.Response response) {
    String? message;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded['error'] is String) {
        message = decoded['error'] as String;
      }
    } on FormatException {
      message = null;
    }
    return ApiException(message ?? '$action (HTTP ${response.statusCode}).');
  }

  @override
  Future<AppUser?> login(String email, String password) async {
    final response = await _post('/auth/login', {
      'email': email,
      'motDePasse': password,
    }, includeAuthorization: false);
    if (response.statusCode == 401) return null;
    if (response.statusCode != 200) {
      throw _responseError('Connexion impossible', response);
    }
    final user = AppUser.fromJson(_decodeObject(response));
    if (user.accessToken == null || user.accessToken!.isEmpty) {
      throw const ApiException(
        'Le serveur n’a pas retourné de jeton de session.',
      );
    }
    _accessToken = user.accessToken;
    return user;
  }

  @override
  Future<void> signup(String name, String email, String password) async {
    final response = await _post('/auth/signup', {
      'nom': name,
      'email': email,
      'motDePasse': password,
    }, includeAuthorization: false);
    if (response.statusCode == 409) {
      throw const ApiException('Cette adresse e-mail est déjà utilisée.');
    }
    if (response.statusCode != 201) {
      throw _responseError('Inscription impossible', response);
    }
    _decodeObject(response);
  }

  @override
  Future<AppUser?> restoreSession() async {
    final preferences = await SharedPreferences.getInstance();
    final userId = preferences.getString(_storedUserIdKey);
    if (userId == null || userId.isEmpty) return null;
    final accessToken = preferences.getString(_storedAccessTokenKey);
    if (accessToken == null || accessToken.isEmpty) {
      await rememberUser(null);
      return null;
    }
    _accessToken = accessToken;

    final response = await _get('/utilisateurs/${Uri.encodeComponent(userId)}');
    if (response.statusCode == 404 || response.statusCode == 401) {
      await rememberUser(null);
      _accessToken = null;
      return null;
    }
    if (response.statusCode != 200) {
      throw ApiException(
        'Restauration de session impossible '
        '(${response.statusCode}).',
      );
    }
    return AppUser.fromJson(_decodeObject(response));
  }

  @override
  Future<void> rememberUser(String? userId) async {
    final preferences = await SharedPreferences.getInstance();
    if (userId == null) {
      await preferences.remove(_storedUserIdKey);
      await preferences.remove(_storedAccessTokenKey);
    } else {
      await preferences.setString(_storedUserIdKey, userId);
      if (_accessToken != null) {
        await preferences.setString(_storedAccessTokenKey, _accessToken!);
      }
    }
  }

  @override
  Future<void> logout() async {
    _accessToken = null;
    await rememberUser(null);
  }

  @override
  Future<List<MenuItem>> getMenus() async {
    final response = await _get('/menus');
    if (response.statusCode != 200) {
      throw _responseError('Chargement des menus impossible', response);
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const ApiException('La liste des menus reçue est invalide.');
    }
    return decoded
        .map((item) {
          if (item is! Map<String, dynamic>) {
            throw const ApiException('Un menu reçu est invalide.');
          }
          return MenuItem.fromJson(item);
        })
        .toList(growable: false);
  }

  @override
  Future<void> createMenu(MenuItem menu) async {
    final response = await _post('/menus', menu.toJson());
    if (response.statusCode != 201) {
      throw _responseError('Ajout du menu impossible', response);
    }
    _decodeObject(response);
  }

  @override
  Future<void> deleteMenu(String id) async {
    final response = await _delete('/menus/${Uri.encodeComponent(id)}');
    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode == 404
            ? 'Ce menu n’existe plus.'
            : _responseError('Suppression impossible', response).message,
      );
    }
  }
}
