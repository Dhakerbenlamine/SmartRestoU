class MenuItem {
  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.diet,
    required this.type,
    required this.date,
  });

  final String id;
  final String name;
  final String description;
  final String diet;
  final String type;
  final DateTime date;
}
