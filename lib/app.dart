import 'package:flutter/material.dart';
import 'package:smart_restou/screens/dashboard_screen.dart';
import 'package:smart_restou/screens/home_screen.dart';
import 'package:smart_restou/screens/placeholder_screen.dart';
import 'package:smart_restou/screens/reservation_screen.dart';
import 'package:smart_restou/theme/app_theme.dart';

class SmartRestoApp extends StatelessWidget {
  const SmartRestoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartRestoU',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  Widget get _currentPage {
    return switch (_selectedIndex) {
      0 => HomeScreen(onReserve: () => setState(() => _selectedIndex = 1)),
      1 => ReservationScreen(
        onCancel: () => setState(() => _selectedIndex = 0),
      ),
      2 => DashboardScreen(
        onReserve: () => setState(() => _selectedIndex = 1),
        onHistory: () => setState(() => _selectedIndex = 3),
      ),
      _ => const PlaceholderScreen(
        title: 'Mon historique',
        message: 'Vos repas passés et vos avis apparaîtront ici.',
        icon: Icons.history,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _currentPage),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
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
            icon: Icon(Icons.history),
            selectedIcon: Icon(Icons.history_toggle_off),
            label: 'Historique',
          ),
        ],
      ),
    );
  }
}
