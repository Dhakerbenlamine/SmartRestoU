import 'package:flutter/material.dart';
import 'package:smart_restou/models/app_user.dart';
import 'package:smart_restou/models/reservation.dart';
import 'package:smart_restou/screens/admin_menus_screen.dart';
import 'package:smart_restou/screens/connexion_screen.dart';
import 'package:smart_restou/screens/dashboard_screen.dart';
import 'package:smart_restou/screens/history_screen.dart';
import 'package:smart_restou/screens/home_screen.dart';
import 'package:smart_restou/screens/placeholder_screen.dart';
import 'package:smart_restou/screens/reservation_screen.dart';
import 'package:smart_restou/services/api_service.dart';
import 'package:smart_restou/services/smart_resto_api.dart';
import 'package:smart_restou/theme/app_theme.dart';

class SmartRestoApp extends StatelessWidget {
  const SmartRestoApp({super.key, this.api});

  final SmartRestoApi? api;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartRestoU',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: AuthGate(api: api ?? ApiService()),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.api});

  final SmartRestoApi api;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  AppUser? _user;
  String? _restoreError;
  bool _isRestoring = true;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    setState(() {
      _isRestoring = true;
      _restoreError = null;
    });
    try {
      _user = await widget.api.restoreSession();
    } on ApiException catch (error) {
      _restoreError = error.message;
    } on FormatException catch (error) {
      _restoreError = 'Réponse serveur invalide : ${error.message}';
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  Future<AppUser?> _login(
    String email,
    String password,
    bool rememberMe,
  ) async {
    final user = await widget.api.login(email, password);
    if (user == null) return null;
    await widget.api.rememberUser(rememberMe ? user.id : null);
    if (mounted) setState(() => _user = user);
    return user;
  }

  Future<void> _logout() async {
    await widget.api.logout();
    if (mounted) setState(() => _user = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_isRestoring) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_user != null) {
      return AppShell(user: _user!, api: widget.api, onLogout: _logout);
    }
    return ConnexionScreen(
      api: widget.api,
      onLogin: _login,
      restoreError: _restoreError,
      onRetryRestore: _restoreSession,
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.user,
    required this.api,
    required this.onLogout,
  });

  final AppUser user;
  final SmartRestoApi api;
  final VoidCallback onLogout;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  final List<Reservation> _reservations = [];

  Widget get _currentPage {
    if (widget.user.isAdmin) {
      return switch (_selectedIndex) {
        0 => AdminMenusScreen(
          user: widget.user,
          api: widget.api,
          onLogout: widget.onLogout,
        ),
        _ => const PlaceholderScreen(
          title: 'Statistiques',
          message: 'Les statistiques de l’établissement apparaîtront ici.',
          icon: Icons.insights_outlined,
        ),
      };
    }

    return switch (_selectedIndex) {
      0 => HomeScreen(
        api: widget.api,
        onReserve: () => setState(() => _selectedIndex = 1),
      ),
      1 => ReservationScreen(
        onCancel: () => setState(() => _selectedIndex = 0),
        onReservationConfirmed: (reservation) {
          setState(() {
            _reservations.add(reservation);
            _selectedIndex = 2;
          });
        },
      ),
      2 => DashboardScreen(
        onReserve: () => setState(() => _selectedIndex = 1),
        onHistory: () => setState(() => _selectedIndex = 3),
        onLogout: widget.onLogout,
        reservations: List.unmodifiable(_reservations),
      ),
      _ => HistoryScreen(
        onDashboard: () => setState(() => _selectedIndex = 2),
        reservations: List.unmodifiable(_reservations),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final destinations = widget.user.isAdmin
        ? const [
            NavigationDestination(
              key: Key('nav-admin-menus'),
              icon: Icon(Icons.restaurant_menu_outlined),
              selectedIcon: Icon(Icons.restaurant_menu),
              label: 'Menus admin',
            ),
            NavigationDestination(
              key: Key('nav-statistics'),
              icon: Icon(Icons.insights_outlined),
              selectedIcon: Icon(Icons.insights),
              label: 'Statistiques',
            ),
          ]
        : const [
            NavigationDestination(
              icon: Icon(Icons.restaurant_menu_outlined),
              selectedIcon: Icon(Icons.restaurant_menu),
              label: 'Menus',
            ),
            NavigationDestination(
              key: Key('nav-reservation'),
              icon: Icon(Icons.event_seat_outlined),
              selectedIcon: Icon(Icons.event_seat),
              label: 'Réserver',
            ),
            NavigationDestination(
              key: Key('nav-dashboard'),
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Mon espace',
            ),
            NavigationDestination(
              key: Key('nav-history'),
              icon: Icon(Icons.history),
              selectedIcon: Icon(Icons.history_toggle_off),
              label: 'Historique',
            ),
          ];

    return Scaffold(
      body: SafeArea(child: _currentPage),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: destinations,
      ),
    );
  }
}
