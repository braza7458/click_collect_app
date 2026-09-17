import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'signup_step2_screen.dart';

class SignupStep1Screen extends StatefulWidget {
  const SignupStep1Screen({super.key});

  @override
  State<SignupStep1Screen> createState() => _SignupStep1ScreenState();
}

class _SignupStep1ScreenState extends State<SignupStep1Screen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool get _hasValidUsername => _usernameController.text.trim().length >= 3;
  bool get _hasMinLength => _passwordController.text.length >= 8;
  bool get _hasDigit => RegExp(r'\d').hasMatch(_passwordController.text);
  bool get _hasUppercase => RegExp(r'[A-Z]').hasMatch(_passwordController.text);

  bool get _canContinue => _hasValidUsername && _hasMinLength && _hasDigit && _hasUppercase;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _continue() {
    if (!_canContinue) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SignupStep2Screen(
          username: _usernameController.text.trim(),
          password: _passwordController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un compte')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: LinearProgressIndicator(
                        value: 0.5,
                        minHeight: 6,
                        backgroundColor: AppColors.charcoalSoft,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.orange),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Étape 1/2', style: textTheme.bodySmall),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Créez votre compte', style: textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Juste un pseudo et un mot de passe — aucun e-mail, aucun numéro de téléphone.',
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _usernameController,
                      style: textTheme.bodyLarge?.copyWith(color: AppColors.cream),
                      decoration: const InputDecoration(labelText: 'Pseudo'),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: textTheme.bodyLarge?.copyWith(color: AppColors.cream),
                      decoration: const InputDecoration(labelText: 'Mot de passe'),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 14),
                    _ValidationRow(label: 'Pseudo : au moins 3 caractères', valid: _hasValidUsername),
                    _ValidationRow(label: 'Mot de passe : au minimum 8 caractères', valid: _hasMinLength),
                    _ValidationRow(label: 'Au moins un chiffre', valid: _hasDigit),
                    _ValidationRow(label: 'Au moins une majuscule', valid: _hasUppercase),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canContinue ? _continue : null,
                  child: const Text('Continuer'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ValidationRow extends StatelessWidget {
  const _ValidationRow({required this.label, required this.valid});

  final String label;
  final bool valid;

  @override
  Widget build(BuildContext context) {
    final color = valid ? AppColors.green : AppColors.creamMuted;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(
            valid ? Icons.check_circle_outline_rounded : Icons.circle_outlined,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
