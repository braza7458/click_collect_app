import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'choose_restaurant_screen.dart';

class SignupStep2Screen extends StatefulWidget {
  const SignupStep2Screen({super.key, required this.username, required this.password});

  final String username;
  final String password;

  @override
  State<SignupStep2Screen> createState() => _SignupStep2ScreenState();
}

class _SignupStep2ScreenState extends State<SignupStep2Screen> {
  bool _acceptedTerms = false;
  bool _submitting = false;
  String? _errorMessage;

  Future<void> _validate() async {
    if (!_acceptedTerms) return;
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    final appState = AppStateScope.of(context);
    final result = await appState.signUp(
      username: widget.username,
      password: widget.password,
    );
    if (!mounted) return;
    if (!result.isSuccess) {
      setState(() {
        _submitting = false;
        _errorMessage = result.errorMessage;
      });
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ChooseRestaurantScreen()),
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
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: LinearProgressIndicator(
                        value: 1,
                        minHeight: 6,
                        backgroundColor: AppColors.charcoalSoft,
                        valueColor: const AlwaysStoppedAnimation(AppColors.orange),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Étape 2/2', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Programme de fidélité', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.charcoalSoft,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: AppColors.orange.withValues(alpha: 0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.orangeDark.withValues(alpha: 0.4),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.orange.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.loyalty, color: AppColors.orange, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('1 € dépensé = 1 point gagné', style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 6),
                                Text(
                                  'Cumulez des points à chaque commande et échangez-les contre des récompenses gourmandes.',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'CONSENTEMENTS',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.creamMuted,
                            letterSpacing: 1.1,
                          ),
                    ),
                    const SizedBox(height: 8),
                    _ConsentCheckbox(
                      value: _acceptedTerms,
                      onChanged: (v) => setState(() => _acceptedTerms = v),
                      title: 'J\'accepte les Conditions Générales d\'Utilisation et la Politique de confidentialité',
                      required: true,
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(_errorMessage!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.red)),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: ElevatedButton(
                onPressed: _acceptedTerms && !_submitting ? _validate : null,
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.charcoal),
                      )
                    : const Text('Je valide mon inscription'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsentCheckbox extends StatelessWidget {
  const _ConsentCheckbox({
    required this.value,
    required this.onChanged,
    required this.title,
    this.required = false,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String title;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(value: value, onChanged: (v) => onChanged(v ?? false)),
            const SizedBox(width: 4),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      TextSpan(text: title),
                      if (required) const TextSpan(text: ' *', style: TextStyle(color: AppColors.orange)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
