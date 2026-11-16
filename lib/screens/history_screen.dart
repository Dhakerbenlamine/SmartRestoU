import 'package:flutter/material.dart';
import 'package:smart_restou/models/reservation.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({
    super.key,
    required this.onDashboard,
    this.reservations = const [],
  });

  final VoidCallback onDashboard;
  final List<Reservation> reservations;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final sortedReservations = [...reservations]
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

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
        Text('Mon Historique', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          'Vos réservations passées et vos avis.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF8992B3),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            key: const Key('history-dashboard'),
            onPressed: onDashboard,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Retour au Tableau de bord'),
          ),
        ),
        const SizedBox(height: 12),
        _HistorySection(
          title: 'Mes Réservations',
          icon: Icons.calendar_month_outlined,
          count: reservations.length,
          iconColor: primary,
          child: reservations.isEmpty
              ? const _HistoryEmptyState(
                  icon: Icons.event_busy_outlined,
                  message: 'Aucune réservation enregistrée.',
                )
              : Column(
                  children: [
                    for (final reservation in sortedReservations)
                      _HistoryReservationRow(reservation: reservation),
                  ],
                ),
        ),
        const SizedBox(height: 16),
        _HistorySection(
          title: 'Repas Consommés',
          icon: Icons.paid_outlined,
          count: 0,
          iconColor: const Color(0xFFD96113),
          child: const _HistoryEmptyState(
            icon: Icons.inbox_outlined,
            message:
                'Aucun repas consommé enregistré. Les réservations ne '
                'confirment pas qu’un repas a été pris.',
          ),
        ),
      ],
    );
  }
}

class _HistoryReservationRow extends StatelessWidget {
  const _HistoryReservationRow({required this.reservation});

  final Reservation reservation;

  @override
  Widget build(BuildContext context) {
    final date = reservation.dateTime;
    final statusColor = reservation.isPast
        ? const Color(0xFF8992B3)
        : const Color(0xFF168A49);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reservation.restaurantName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '${date.day.toString().padLeft(2, '0')}/'
                  '${date.month.toString().padLeft(2, '0')}/'
                  '${date.year} à '
                  '${date.hour.toString().padLeft(2, '0')}:'
                  '${date.minute.toString().padLeft(2, '0')} · '
                  '${reservation.guestCount} personne(s)',
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              reservation.isPast ? 'PASSÉE' : 'À VENIR',
              style: TextStyle(color: statusColor, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection({
    required this.title,
    required this.icon,
    required this.count,
    required this.iconColor,
    required this.child,
  });

  final String title;
  final IconData icon;
  final int count;
  final Color iconColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(title, style: theme.textTheme.titleMedium),
                ),
                Text(
                  '$count',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _HistoryEmptyState extends StatelessWidget {
  const _HistoryEmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: const Color(0xFF8992B3)),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(color: const Color(0xFF8992B3)),
          ),
        ],
      ),
    );
  }
}
