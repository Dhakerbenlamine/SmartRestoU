import 'package:flutter/material.dart';
import 'package:smart_restou/models/reservation.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.onReserve,
    this.onHistory,
    this.reservations = const [],
  });

  final VoidCallback onReserve;
  final VoidCallback? onHistory;
  final List<Reservation> reservations;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final sortedReservations = [...reservations]
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

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
          trailing: _CountBadge(color: primary, count: reservations.length),
          child: reservations.isEmpty
              ? const _EmptySectionMessage(
                  icon: Icons.notifications_off_outlined,
                  message: 'Aucune notification pour le moment.',
                )
              : Column(
                  children: [
                    for (final reservation in sortedReservations.reversed)
                      _NotificationRow(reservation: reservation),
                  ],
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
          child: reservations.isEmpty
              ? const _EmptySectionMessage(
                  icon: Icons.event_busy_outlined,
                  message: 'Aucune réservation enregistrée.',
                )
              : Column(
                  children: [
                    for (final reservation in sortedReservations)
                      _ReservationRow(reservation: reservation),
                  ],
                ),
        ),
      ],
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({required this.reservation});

  final Reservation reservation;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(
        child: Icon(Icons.notifications_none_outlined),
      ),
      title: const Text('Confirmation de réservation'),
      subtitle: Text(
        '${_formatDateTime(reservation.dateTime)} · '
        '${reservation.guestCount} personne(s)',
      ),
    );
  }
}

class _ReservationRow extends StatelessWidget {
  const _ReservationRow({required this.reservation});

  final Reservation reservation;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(reservation.restaurantName),
      subtitle: Text(
        '${_formatDateTime(reservation.dateTime)} · '
        '${reservation.guestCount} personne(s)',
      ),
      trailing: _ReservationStatus(isPast: reservation.isPast),
    );
  }
}

class _ReservationStatus extends StatelessWidget {
  const _ReservationStatus({required this.isPast});

  final bool isPast;

  @override
  Widget build(BuildContext context) {
    final color = isPast ? const Color(0xFF8992B3) : const Color(0xFF168A49);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isPast ? 'PASSÉE' : 'À VENIR',
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

String _formatDateTime(DateTime dateTime) =>
    '${dateTime.day.toString().padLeft(2, '0')}/'
    '${dateTime.month.toString().padLeft(2, '0')}/'
    '${dateTime.year} à '
    '${dateTime.hour.toString().padLeft(2, '0')}:'
    '${dateTime.minute.toString().padLeft(2, '0')}';

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
