import 'package:flutter/material.dart';
import 'package:smart_restou/models/app_user.dart';
import 'package:smart_restou/models/menu_item.dart';
import 'package:smart_restou/services/api_service.dart';
import 'package:smart_restou/services/smart_resto_api.dart';

class AdminMenusScreen extends StatefulWidget {
  const AdminMenusScreen({
    super.key,
    required this.user,
    required this.api,
    this.onLogout,
  });

  final AppUser user;
  final SmartRestoApi api;
  final VoidCallback? onLogout;

  @override
  State<AdminMenusScreen> createState() => _AdminMenusScreenState();
}

class _AdminMenusScreenState extends State<AdminMenusScreen> {
  static const _diets = ['Standard', 'Vegan', 'Sans gluten'];
  static const _types = ['Menu du jour', 'Menu semaine'];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _diet = _diets.first;
  String _type = _types.first;
  DateTime _date = DateTime.now();
  List<MenuItem> _menus = const [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    if (widget.user.isAdmin) _loadMenus();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadMenus() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final menus = await widget.api.getMenus();
      if (mounted) setState(() => _menus = menus);
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

  Future<void> _pickDate() async {
    final chosen = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (chosen != null) setState(() => _date = chosen);
  }

  Future<void> _addMenu() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await widget.api.createMenu(
        MenuItem(
          id: '',
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          diet: _diet,
          type: _type,
          date: _date,
        ),
      );
      _nameController.clear();
      _descriptionController.clear();
      await _loadMenus();
      if (mounted) _showMessage('Menu ajouté avec succès.');
    } on ApiException catch (error) {
      if (mounted) _showMessage(error.message);
    } on FormatException catch (error) {
      if (mounted) _showMessage('Réponse serveur invalide : ${error.message}');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteMenu(MenuItem menu) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce menu ?'),
        content: Text('Le menu « ${menu.name} » sera supprimé.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await widget.api.deleteMenu(menu.id);
      await _loadMenus();
      if (mounted) _showMessage('Menu supprimé.');
    } on ApiException catch (error) {
      if (mounted) _showMessage(error.message);
    } on FormatException catch (error) {
      if (mounted) _showMessage('Réponse serveur invalide : ${error.message}');
    }
  }

  void _showDetails(MenuItem menu) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(menu.name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text(menu.description),
              const SizedBox(height: 12),
              Text('${menu.diet} · ${_typeLabel(menu.type)}'),
              Text('Disponible : ${menu.available ? 'Oui' : 'Non'}'),
            ],
          ),
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.user.isAdmin) {
      return const Center(
        child: Text(
          'Accès refusé',
          key: Key('admin-access-denied'),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      );
    }

    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.primary,
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
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              foregroundColor: theme.colorScheme.primary,
              child: Text(
                widget.user.name.isEmpty
                    ? 'A'
                    : widget.user.name[0].toUpperCase(),
              ),
            ),
            if (widget.onLogout != null)
              PopupMenuButton<String>(
                onSelected: (_) => widget.onLogout!.call(),
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    key: Key('admin-logout'),
                    value: 'logout',
                    child: Text('Se déconnecter'),
                  ),
                ],
                icon: const Icon(Icons.more_vert),
              ),
          ],
        ),
        const SizedBox(height: 28),
        Text('Administration', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          'Gérez les menus et pilotez l’établissement.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF8992B3),
          ),
        ),
        const SizedBox(height: 20),
        _AddMenuCard(
          formKey: _formKey,
          nameController: _nameController,
          descriptionController: _descriptionController,
          diet: _diet,
          type: _type,
          date: _date,
          diets: _diets,
          types: _types,
          isSaving: _isSaving,
          onDietChanged: (value) => setState(() => _diet = value),
          onTypeChanged: (value) => setState(() => _type = value),
          onPickDate: _pickDate,
          onSubmit: _addMenu,
        ),
        const SizedBox(height: 16),
        _ExistingMenusCard(
          menus: _menus,
          isLoading: _isLoading,
          loadError: _loadError,
          onRetry: _loadMenus,
          onDetails: _showDetails,
          onDelete: _deleteMenu,
        ),
      ],
    );
  }
}

class _AddMenuCard extends StatelessWidget {
  const _AddMenuCard({
    required this.formKey,
    required this.nameController,
    required this.descriptionController,
    required this.diet,
    required this.type,
    required this.date,
    required this.diets,
    required this.types,
    required this.isSaving,
    required this.onDietChanged,
    required this.onTypeChanged,
    required this.onPickDate,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final String diet;
  final String type;
  final DateTime date;
  final List<String> diets;
  final List<String> types;
  final bool isSaving;
  final ValueChanged<String> onDietChanged;
  final ValueChanged<String> onTypeChanged;
  final VoidCallback onPickDate;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFFEAE6FF),
                    foregroundColor: theme.colorScheme.primary,
                    child: const Icon(Icons.add),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ajouter un menu',
                        style: theme.textTheme.titleLarge,
                      ),
                      Text(
                        'Créez un nouveau plat',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF8992B3),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const _AdminFieldLabel('Nom du plat'),
              TextFormField(
                key: const Key('admin-menu-name'),
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'ex. Filet de colin',
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Saisissez le nom du plat.'
                    : null,
              ),
              const SizedBox(height: 14),
              const _AdminFieldLabel('Description'),
              TextFormField(
                key: const Key('admin-menu-description'),
                controller: descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Description du plat',
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Saisissez une description.'
                    : null,
              ),
              const SizedBox(height: 14),
              const _AdminFieldLabel('Date'),
              InkWell(
                key: const Key('admin-menu-date'),
                onTap: onPickDate,
                borderRadius: BorderRadius.circular(16),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    suffixIcon: Icon(Icons.calendar_month_outlined),
                  ),
                  child: Text(_formatDate(date)),
                ),
              ),
              const SizedBox(height: 14),
              const _AdminFieldLabel('Régime'),
              DropdownButtonFormField<String>(
                key: const Key('admin-menu-diet'),
                initialValue: diet,
                items: [
                  for (final value in diets)
                    DropdownMenuItem(value: value, child: Text(value)),
                ],
                onChanged: (value) {
                  if (value != null) onDietChanged(value);
                },
              ),
              const SizedBox(height: 14),
              const _AdminFieldLabel('Type de menu'),
              DropdownButtonFormField<String>(
                key: const Key('admin-menu-type'),
                initialValue: type,
                items: [
                  for (final value in types)
                    DropdownMenuItem(
                      value: value,
                      child: Text(_typeLabel(value)),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) onTypeChanged(value);
                },
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  key: const Key('admin-menu-submit'),
                  onPressed: isSaving ? null : onSubmit,
                  child: isSaving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Ajouter le menu'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExistingMenusCard extends StatelessWidget {
  const _ExistingMenusCard({
    required this.menus,
    required this.isLoading,
    required this.loadError,
    required this.onRetry,
    required this.onDetails,
    required this.onDelete,
  });

  final List<MenuItem> menus;
  final bool isLoading;
  final String? loadError;
  final VoidCallback onRetry;
  final ValueChanged<MenuItem> onDetails;
  final ValueChanged<MenuItem> onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.menu, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Menus existants',
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                CircleAvatar(
                  radius: 17,
                  backgroundColor: const Color(0xFFEAE6FF),
                  foregroundColor: theme.colorScheme.primary,
                  child: Text('${menus.length}'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (loadError != null)
              Column(
                children: [
                  Text(
                    loadError!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  TextButton(
                    onPressed: onRetry,
                    child: const Text('Réessayer'),
                  ),
                ],
              )
            else if (menus.isEmpty)
              const Padding(
                padding: EdgeInsets.all(18),
                child: Text('Aucun menu enregistré.'),
              )
            else
              for (var index = 0; index < menus.length; index++) ...[
                if (index > 0) const Divider(height: 26),
                _MenuAdminRow(
                  menu: menus[index],
                  onDetails: () => onDetails(menus[index]),
                  onDelete: () => onDelete(menus[index]),
                ),
              ],
          ],
        ),
      ),
    );
  }
}

class _MenuAdminRow extends StatelessWidget {
  const _MenuAdminRow({
    required this.menu,
    required this.onDetails,
    required this.onDelete,
  });

  final MenuItem menu;
  final VoidCallback onDetails;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final dietColor = switch (menu.diet) {
      'Vegan' => const Color(0xFF00A64F),
      'Sans gluten' => const Color(0xFFFF6500),
      _ => Theme.of(context).colorScheme.primary,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(menu.name, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              _formatDate(menu.date),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: dietColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                menu.diet.toUpperCase(),
                style: TextStyle(color: dietColor, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: FilledButton.tonal(
                onPressed: onDetails,
                child: const Text('Voir'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: onDelete,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFFF0F0),
                  foregroundColor: const Color(0xFFFF303A),
                ),
                child: const Text('Supprimer'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AdminFieldLabel extends StatelessWidget {
  const _AdminFieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(label, style: Theme.of(context).textTheme.titleMedium),
  );
}

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}/'
    '${date.year}';

String _typeLabel(String value) =>
    value == 'Menu semaine' || value == 'Menu de la semaine'
    ? 'Menu de la semaine'
    : value;
