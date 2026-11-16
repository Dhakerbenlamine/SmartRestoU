import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.onReserve, this.onHistory});

  final VoidCallback onReserve;
  final VoidCallback? onHistory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              child: const Text(
                'S',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 12),
            Text('SmartRestoU', style: theme.textTheme.titleLarge),
            const Spacer(),
            CircleAvatar(
              backgroundColor: primary.withValues(alpha: 0.1),
              foregroundColor: primary,
              child: const Icon(Icons.person_outline),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Text('Mon espace', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          'Retrouvez ici vos réservations et notifications.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF8992B3),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 60,
          child: FilledButton.icon(
            key: const Key('dashboard-reserve'),
            onPressed: onReserve,
            icon: const Icon(Icons.add),
            label: const Text('Réserver une table'),
          ),
        ),
        const SizedBox(height: 20),
        _DashboardSection(
          title: 'Mes notifications',
          icon: Icons.notifications_none_outlined,
          trailing: _CountBadge(color: primary, count: 0),
          child: const _EmptySectionMessage(
            icon: Icons.notifications_off_outlined,
            message: 'Aucune notification pour le moment.',
          ),
        ),
        const SizedBox(height: 16),
        _DashboardSection(
          title: 'Mes réservations',
          icon: Icons.calendar_month_outlined,
          trailing: TextButton(
            onPressed: onHistory,
            child: const Text('Voir tout'),
          ),
          child: const _EmptySectionMessage(
            icon: Icons.event_busy_outlined,
            message: 'Aucune réservation enregistrée.',
          ),
        ),
      ],
    );
  }
}

class _DashboardSection extends StatelessWidget {
  const _DashboardSection({
    required this.title,
    required this.icon,
    required this.trailing,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title, style: theme.textTheme.titleMedium),
                ),
                trailing,
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.color, required this.count});

  final Color color;
  final int count;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 17,
      backgroundColor: color,
      foregroundColor: Colors.white,
      child: Text(
        '$count',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _EmptySectionMessage extends StatelessWidget {
  const _EmptySectionMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF8992B3), size: 28),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
