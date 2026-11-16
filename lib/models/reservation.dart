class Reservation {
  const Reservation({
    required this.dateTime,
    required this.guestCount,
    this.restaurantName = 'Resto U Central',
  });

  final DateTime dateTime;
  final int guestCount;
  final String restaurantName;

  bool get isPast => !dateTime.isAfter(DateTime.now());
}
