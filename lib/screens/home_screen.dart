import 'package:flutter/material.dart';
import 'package:smart_restou/data/menu_items.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _BrandHeader(),
        const SizedBox(height: 32),
        Text(
          'Menus du restaurant',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Découvrez les plats préparés chaque jour dans votre restaurant universitaire.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF8992B3),
              ),
        ),
        const SizedBox(height: 20),
        for (final meal in sampleMenuItems) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.diet.toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    meal.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(meal.description),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        meal.type.toUpperCase(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '${meal.date.day.toString().padLeft(2, '0')}/'
                        '${meal.date.month.toString().padLeft(2, '0')}/'
                        '${meal.date.year}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          child: const Text('S', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 12),
        Text('SmartRestoU', style: Theme.of(context).textTheme.titleLarge),
        const Spacer(),
        const CircleAvatar(
          backgroundColor: Color(0xFFE5E7F2),
          child: Icon(Icons.person_outline, color: Color(0xFF171B3A)),
        ),
      ],
    );
  }
}
