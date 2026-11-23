import 'package:smart_restou/models/app_user.dart';
import 'package:smart_restou/models/menu_item.dart';

abstract interface class SmartRestoApi {
  Future<AppUser?> restoreSession();
  Future<AppUser?> login(String email, String password);
  Future<void> signup(String name, String email, String password);
  Future<void> rememberUser(String? userId);
  Future<void> logout();
  Future<List<MenuItem>> getMenus();
  Future<void> createMenu(MenuItem menu);
  Future<void> deleteMenu(String id);
}
