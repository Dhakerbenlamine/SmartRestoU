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
  MenuItem(
    id: 'menu-4',
    name: 'Couscous aux légumes',
    description: 'Semoule et légumes mijotés aux épices douces.',
    diet: 'Vegan',
    type: 'Menu du jour',
    date: DateTime.now().add(const Duration(days: 3)),
  ),
  MenuItem(
    id: 'menu-5',
    name: 'Poulet rôti aux herbes',
    description: 'Accompagné de pommes de terre et de salade verte.',
    diet: 'Standard',
    type: 'Menu de la semaine',
    date: DateTime.now().add(const Duration(days: 4)),
  ),
  MenuItem(
    id: 'menu-6',
    name: 'Salade de quinoa et pois chiches',
    description: 'Une salade fraîche, complète et naturellement sans gluten.',
    diet: 'Sans gluten',
    type: 'Menu du jour',
    date: DateTime.now().add(const Duration(days: 5)),
  ),
]);
