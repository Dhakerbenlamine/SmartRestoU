class MenuItem {
  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.diet,
    required this.type,
    required this.date,
    this.available = true,
    this.image,
  });

  final String id;
  final String name;
  final String description;
  final String diet;
  final String type;
  final DateTime date;
  final bool available;
  final String? image;

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    final dateValue = json['date'];
    final date = dateValue is String ? DateTime.tryParse(dateValue) : null;
    if (date == null) {
      throw const FormatException('Menu date must be a yyyy-MM-dd string.');
    }

    return MenuItem(
      id: _stringValue(json, 'id'),
      name: _stringValue(json, 'nom'),
      description: _stringValue(json, 'description'),
      diet: _stringValue(json, 'regime'),
      type: _stringValue(json, 'type'),
      date: date,
      available: json['disponible'] is bool
          ? json['disponible'] as bool
          : throw const FormatException('Menu disponible must be a boolean.'),
      image: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'nom': name,
    'description': description,
    'regime': diet,
    'type': type == 'Menu de la semaine' ? 'Menu semaine' : type,
    'date':
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}',
    'disponible': available,
    'image': image,
  };
}

String _stringValue(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String) return value;
  throw FormatException('Menu $key must be a string.');
}
