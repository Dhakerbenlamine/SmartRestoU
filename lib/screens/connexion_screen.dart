import 'package:flutter/material.dart';
import 'package:smart_restou/models/app_user.dart';
import 'package:smart_restou/services/api_service.dart';
import 'package:smart_restou/services/smart_resto_api.dart';

class ConnexionScreen extends StatefulWidget {
  const ConnexionScreen({
    super.key,
    required this.api,
    required this.onLogin,
    this.restoreError,
    this.onRetryRestore,
  });

  final SmartRestoApi api;
  final Future<AppUser?> Function(
    String email,
    String password,
    bool rememberMe,
  )
  onLogin;
  final String? restoreError;
  final VoidCallback? onRetryRestore;

  @override
  State<ConnexionScreen> createState() => _ConnexionScreenState();
}

class _ConnexionScreenState extends State<ConnexionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignup = false;
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _message;
  bool _isSuccessMessage = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _message = null;
    });

    try {
      if (_isSignup) {
        await widget.api.signup(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
        );
        if (!mounted) return;
        setState(() {
          _isSignup = false;
          _passwordController.clear();
          _message = 'Compte créé. Vous pouvez maintenant vous connecter.';
          _isSuccessMessage = true;
        });
      } else {
        final user = await widget.onLogin(
          _emailController.text.trim(),
          _passwordController.text,
          _rememberMe,
        );
        if (!mounted) return;
        if (user == null) {
          setState(() {
            _message = 'Adresse e-mail ou mot de passe incorrect.';
            _isSuccessMessage = false;
          });
        }
      }
    } on ApiException catch (error) {
      if (mounted) {
        setState(() {
          _message = error.message;
          _isSuccessMessage = false;
        });
      }
    } on FormatException catch (error) {
      if (mounted) {
        setState(() {
          _message = 'Réponse serveur invalide : ${error.message}';
          _isSuccessMessage = false;
        });
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _forgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'La réinitialisation du mot de passe n’est pas encore disponible.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            children: [
              _AuthHeader(
                isSignup: _isSignup,
                onLogin: () => setState(() {
                  _isSignup = false;
                  _message = null;
                }),
                onSignup: () => setState(() {
                  _isSignup = true;
                  _message = null;
                }),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 42, 20, 0),
                child: Column(
                  children: [
                    Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAE6FF),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Icon(
                        Icons.menu_book_outlined,
                        color: Colors.black,
                        size: 54,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      _isSignup ? 'Créer un compte' : 'Bon retour !',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontSize: 34,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        Text(
                          _isSignup ? 'Déjà inscrit ? ' : 'Ou ',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF8992B3),
                            fontSize: 16,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() {
                            _isSignup = !_isSignup;
                            _message = null;
                          }),
                          child: Text(
                            _isSignup
                                ? 'connectez-vous'
                                : 'créez un nouveau compte étudiant',
                            style: TextStyle(
                              color: primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 34),
                    Form(
                      key: _formKey,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: const Color(0xFFE0E3EF)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_message != null || widget.restoreError != null)
                              _MessageBanner(
                                message: _message ?? widget.restoreError!,
                                success: _message != null && _isSuccessMessage,
                                onRetry: _message == null
                                    ? widget.onRetryRestore
                                    : null,
                              ),
                            if (_isSignup) ...[
                              _FieldLabel(label: 'Nom complet'),
                              _AuthTextField(
                                key: const Key('signup-name'),
                                controller: _nameController,
                                hint: 'Votre nom',
                                icon: Icons.person_outline,
                                textCapitalization: TextCapitalization.words,
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                    ? 'Veuillez saisir votre nom.'
                                    : null,
                              ),
                              const SizedBox(height: 18),
                            ],
                            const _FieldLabel(label: 'Adresse email'),
                            _AuthTextField(
                              key: const Key('auth-email'),
                              controller: _emailController,
                              hint: 'etudiant@smartresto.univ',
                              icon: Icons.alternate_email,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                final email = value?.trim() ?? '';
                                if (email.isEmpty ||
                                    !email.contains('@') ||
                                    !email.contains('.')) {
                                  return 'Saisissez une adresse e-mail valide.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),
                            const _FieldLabel(label: 'Mot de passe'),
                            _AuthTextField(
                              key: const Key('auth-password'),
                              controller: _passwordController,
                              hint: '••••••••',
                              icon: Icons.lock_outline,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                              validator: (value) {
                                final password = value ?? '';
                                final minimumLength = _isSignup ? 8 : 6;
                                if (password.length < minimumLength) {
                                  return 'Le mot de passe doit contenir au moins '
                                      '$minimumLength caractères.';
                                }
                                return null;
                              },
                            ),
                            if (!_isSignup) ...[
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: Checkbox(
                                      key: const Key('remember-me'),
                                      value: _rememberMe,
                                      onChanged: (value) => setState(
                                        () => _rememberMe = value ?? false,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text('Se souvenir de moi'),
                                  ),
                                  TextButton(
                                    onPressed: _forgotPassword,
                                    child: const Text('Mot de passe oublié ?'),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              height: 58,
                              child: FilledButton(
                                key: const Key('auth-submit'),
                                onPressed: _isSubmitting ? null : _submit,
                                child: _isSubmitting
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        _isSignup
                                            ? 'Créer mon compte'
                                            : 'Se connecter',
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthHeader extends StatelessWidget {
  const _AuthHeader({
    required this.isSignup,
    required this.onLogin,
    required this.onSignup,
  });

  final bool isSignup;
  final VoidCallback onLogin;
  final VoidCallback onSignup;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: Colors.white,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(18),
            ),
            alignment: Alignment.center,
            child: const Text(
              'S',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'SmartRestoU',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          TextButton(onPressed: onLogin, child: const Text('Connexion')),
          const SizedBox(width: 4),
          FilledButton(onPressed: onSignup, child: const Text("S'inscrire")),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(label, style: Theme.of(context).textTheme.titleMedium),
  );
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textCapitalization: textCapitalization,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.black),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF2F3F8),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Color(0xFFE0E3EF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Color(0xFFE0E3EF)),
        ),
      ),
    );
  }
}

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({
    required this.message,
    required this.success,
    this.onRetry,
  });

  final String message;
  final bool success;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final color = success
        ? const Color(0xFF168A49)
        : Theme.of(context).colorScheme.error;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(message, style: TextStyle(color: color)),
          ),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Réessayer')),
        ],
      ),
    );
  }
}
