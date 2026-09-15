import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'signup_step2_screen.dart';

class SignupStep1Screen extends StatefulWidget {
  const SignupStep1Screen({super.key});

  @override
  State<SignupStep1Screen> createState() => _SignupStep1ScreenState();
}

class _SignupStep1ScreenState extends State<SignupStep1Screen> {
  final _firstNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  DateTime? _birthDate;

  bool get _hasMinLength => _passwordController.text.length >= 8;
  bool get _hasDigit => RegExp(r'\d').hasMatch(_passwordController.text);
  bool get _hasUppercase => RegExp(r'[A-Z]').hasMatch(_passwordController.text);

  bool get _canContinue =>
      _firstNameController.text.trim().isNotEmpty &&
      _birthDate != null &&
      _emailController.text.contains('@') &&
      _hasMinLength &&
      _hasDigit &&
      _hasUppercase;

  @override
  void dispose() {
    _firstNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25),
      firstDate: DateTime(now.year - 100),
      lastDate: now,
    );
    if (picked != null && mounted) {
      setState(() => _birthDate = picked);
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  void _continue() {
    if (!_canContinue) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SignupStep2Screen(firstName: _firstNameController.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un compte')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: const LinearProgressIndicator(value: 0.5, minHeight: 6),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('Étape 1/2', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Vos informations', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _firstNameController,
                      style: const TextStyle(color: AppColors.cream),
                      decoration: const InputDecoration(labelText: 'Prénom'),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _pickBirthDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date de naissance',
                          suffixIcon: Icon(Icons.calendar_today_outlined, size: 20),
                        ),
                        child: Text(
                          _birthDate == null ? 'Sélectionner une date' : _formatDate(_birthDate!),
                          style: TextStyle(
                            color: _birthDate == null ? AppColors.creamMuted.withValues(alpha: 0.6) : AppColors.cream,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: AppColors.cream),
                      decoration: const InputDecoration(labelText: 'E-mail'),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(color: AppColors.cream),
                      decoration: const InputDecoration(labelText: 'Mot de passe'),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    _ValidationRow(label: 'Au minimum 8 caractères', valid: _hasMinLength),
                    _ValidationRow(label: 'Au moins un chiffre', valid: _hasDigit),
                    _ValidationRow(label: 'Au moins une majuscule', valid: _hasUppercase),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: ElevatedButton(
                onPressed: _canContinue ? _continue : null,
                child: const Text('Continuer'),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            valid ? Icons.check_circle : Icons.circle_outlined,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color, fontSize: 13)),
        ],
      ),
    );
  }
}
