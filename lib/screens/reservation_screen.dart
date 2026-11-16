import 'package:flutter/material.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key, required this.onCancel});

  final VoidCallback onCancel;

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _guestCount = 1;

  Future<void> _selectDateAndTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 1, now.month, now.day),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 12, minute: 0),
    );
    if (time == null || !mounted) return;

    setState(() {
      _selectedDate = date;
      _selectedTime = time;
    });
  }

  Future<void> _confirmReservation() async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choisissez une date et une heure pour continuer.'),
        ),
      );
      return;
    }

    final date = _selectedDate!;
    final time = _selectedTime!;
    final reservationDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    if (!reservationDateTime.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choisissez une date et une heure dans le futur.'),
        ),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.check_circle_outline,
          color: Theme.of(context).colorScheme.primary,
          size: 40,
        ),
        title: const Text('Récapitulatif de réservation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resto U Central · $_guestCount personne(s)'),
            const SizedBox(height: 8),
            Text('${_formatDate(date)} à ${time.format(context)}'),
            const SizedBox(height: 16),
            const Text(
              'Mode démonstration : aucun ticket QR ni e-mail ne sera envoyé.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';

  @override
  Widget build(BuildContext context) {
    final dateAndTime = _selectedDate == null || _selectedTime == null
        ? 'jj/mm/aaaa --:--'
        : '${_formatDate(_selectedDate!)} ${_selectedTime!.format(context)}';

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _ReservationHeader(),
        const SizedBox(height: 28),
        Text(
          'Réserver une Table',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Choisissez une date et le nombre de convives pour votre repas.',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: const Color(0xFF8992B3)),
        ),
        const SizedBox(height: 20),
        const _RestaurantCard(),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date et heure de la réservation',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    key: const Key('reservation-date-time'),
                    onPressed: _selectDateAndTime,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            dateAndTime,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: const Color(0xFF8992B3)),
                          ),
                        ),
                        const Icon(Icons.calendar_month_outlined),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Nombre de personnes',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    DropdownButton<int>(
                      key: const Key('guest-count'),
                      value: _guestCount,
                      items: [
                        for (var count = 1; count <= 10; count++)
                          DropdownMenuItem(value: count, child: Text('$count')),
                      ],
                      onChanged: (count) {
                        if (count != null) {
                          setState(() => _guestCount = count);
                        }
                      },
                    ),
                    Text(
                      'maximum 10 convives par table',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const _TicketNotice(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 60,
          child: FilledButton(
            onPressed: _confirmReservation,
            child: const Text('Confirmer la Réservation'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 56,
          child: OutlinedButton(
            onPressed: widget.onCancel,
            child: const Text('Annuler'),
          ),
        ),
      ],
    );
  }
}

class _ReservationHeader extends StatelessWidget {
  const _ReservationHeader();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          child: const Text('S', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 12),
        Text('SmartRestoU', style: Theme.of(context).textTheme.titleLarge),
        const Spacer(),
        CircleAvatar(
          backgroundColor: primary.withValues(alpha: 0.1),
          foregroundColor: primary,
          child: const Text('E', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  const _RestaurantCard();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(Icons.apartment_outlined, color: primary, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resto U Central',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Capacité maximale : 500 personnes',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF8992B3),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketNotice extends StatelessWidget {
  const _TicketNotice();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: primary),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Un ticket numérique sécurisé contenant un QR Code unique sera '
              'généré après confirmation. Une notification de confirmation '
              'sera également transmise par e-mail.',
            ),
          ),
        ],
      ),
    );
  }
}
