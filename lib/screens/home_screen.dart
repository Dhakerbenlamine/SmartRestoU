import 'package:flutter/material.dart';
import 'package:smart_restou/data/menu_items.dart';
import 'package:smart_restou/models/menu_item.dart';
import 'package:smart_restou/services/api_service.dart';
import 'package:smart_restou/services/smart_resto_api.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onReserve, this.api});

  final VoidCallback? onReserve;
  final SmartRestoApi? api;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _allDiets = 'Tous les régimes';
  static const _allTypes = 'Tous les types';
  static const _diets = [_allDiets, 'Standard', 'Vegan', 'Sans gluten'];
  static const _types = [_allTypes, 'Menu du jour', 'Menu de la semaine'];

  String _selectedDiet = _allDiets;
  String _selectedType = _allTypes;
  late List<MenuItem> _menuItems;
  bool _isLoading = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _menuItems = widget.api == null ? sampleMenuItems : const [];
    if (widget.api != null) _loadMenus();
  }

  Future<void> _loadMenus() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final items = await widget.api!.getMenus();
      if (mounted) setState(() => _menuItems = items);
    } on ApiException catch (error) {
      if (mounted) setState(() => _loadError = error.message);
    } on FormatException catch (error) {
      if (mounted) {
        setState(
          () => _loadError = 'Réponse serveur invalide : ${error.message}',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<MenuItem> get _filteredItems => _menuItems.where((item) {
    final matchesDiet =
        _selectedDiet == _allDiets || item.diet == _selectedDiet;
    final matchesType =
        _selectedType == _allTypes ||
        item.type == _selectedType ||
        (_selectedType == 'Menu de la semaine' && item.type == 'Menu semaine');
    return matchesDiet && matchesType;
  }).toList();

  Future<void> _showDetails(MenuItem item) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(item.description),
              const SizedBox(height: 16),
              Text('${item.diet} · ${item.type}'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: widget.onReserve == null
                      ? null
                      : () {
                          Navigator.of(context).pop();
                          widget.onReserve!.call();
                        },
                  icon: const Icon(Icons.event_seat_outlined),
                  label: const Text('Réserver une table'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final meals = _filteredItems;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _BrandHeader(),
        const SizedBox(height: 28),
        Text(
          'Menus du restaurant',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Découvrez les plats préparés chaque jour avec soin.',
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(color: const Color(0xFF8992B3)),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _MenuFilter(
                key: const Key('diet-filter'),
                value: _selectedDiet,
                options: _diets,
                onChanged: (value) => setState(() => _selectedDiet = value),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MenuFilter(
                key: const Key('type-filter'),
                value: _selectedType,
                options: _types,
                onChanged: (value) => setState(() => _selectedType = value),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 54,
          child: FilledButton.icon(
            onPressed: widget.onReserve,
            icon: const Icon(Icons.add),
            label: const Text('Réserver'),
          ),
        ),
        const SizedBox(height: 24),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_loadError != null)
          _MenuLoadError(message: _loadError!, onRetry: _loadMenus)
        else if (meals.isEmpty)
          const _EmptyMenus()
        else
          for (final meal in meals) ...[
            _MenuCard(item: meal, onDetails: () => _showDetails(meal)),
            const SizedBox(height: 14),
          ],
      ],
    );
  }
}

class _MenuLoadError extends StatelessWidget {
  const _MenuLoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      children: [
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        TextButton(onPressed: onRetry, child: const Text('Réessayer')),
      ],
    ),
  );
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

class _MenuFilter extends StatelessWidget {
  const _MenuFilter({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: const InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: Color(0xFFE0E3EF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: Color(0xFFE0E3EF)),
        ),
      ),
      items: [
        for (final option in options)
          DropdownMenuItem(value: option, child: Text(option, maxLines: 1)),
      ],
      onChanged: (next) {
        if (next != null) onChanged(next);
      },
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.item, required this.onDetails});

  final MenuItem item;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    final date = item.date;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _DietBadge(diet: item.diet),
                Flexible(
                  child: Text(
                    '${date.day.toString().padLeft(2, '0')}/'
                    '${date.month.toString().padLeft(2, '0')}/'
                    '${date.year}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(item.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(item.description),
            const Divider(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    item.type.toUpperCase(),
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                TextButton.icon(
                  onPressed: onDetails,
                  icon: const Icon(Icons.chevron_right),
                  label: const Text('Voir détails'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DietBadge extends StatelessWidget {
  const _DietBadge({required this.diet});

  final String diet;

  @override
  Widget build(BuildContext context) {
    final color = switch (diet) {
      'Vegan' => const Color(0xFF168A49),
      'Sans gluten' => const Color(0xFFD96113),
      _ => Theme.of(context).colorScheme.primary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        diet.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _EmptyMenus extends StatelessWidget {
  const _EmptyMenus();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(Icons.no_meals_outlined, size: 40),
          const SizedBox(height: 12),
          Text(
            'Aucun menu ne correspond à ces filtres.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
