import 'package:smart_restou/models/menu_item.dart';

final sampleMenuItems = List<MenuItem>.unmodifiable([
  MenuItem(
    id: 'menu-1',
    name: 'Filet de bœuf aux herbes',
    description: 'Servi avec des légumes de saison.',
    diet: 'Standard',
    type: 'Menu du jour',
    date: DateTime.now(),
  ),
  MenuItem(
    id: 'menu-2',
    name: 'Risotto aux légumes',
    description: 'Une recette végétale et crémeuse.',
    diet: 'Vegan',
    type: 'Menu du jour',
    date: DateTime.now().add(const Duration(days: 1)),
  ),
  MenuItem(
    id: 'menu-3',
    name: 'Riz avec escalope',
    description: 'Un repas complet et équilibré.',
    diet: 'Sans gluten',
    type: 'Menu de la semaine',
    date: DateTime.now().add(const Duration(days: 2)),
  ),
]);
