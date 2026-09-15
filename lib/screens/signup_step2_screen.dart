import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'choose_restaurant_screen.dart';

class SignupStep2Screen extends StatefulWidget {
  const SignupStep2Screen({super.key, required this.firstName});

  final String firstName;

  @override
  State<SignupStep2Screen> createState() => _SignupStep2ScreenState();
}

class _SignupStep2ScreenState extends State<SignupStep2Screen> {
  bool _acceptedTerms = false;
  bool _emailOptIn = true;
  bool _smsOptIn = false;

  void _validate() {
    if (!_acceptedTerms) return;
    final appState = AppStateScope.of(context);
    appState.loginAs(widget.firstName, points: 0);
    appState.setOptIns(email: _emailOptIn, sms: _smsOptIn);
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
                      borderRadius: BorderRadius.circular(8),
                      child: const LinearProgressIndicator(value: 1, minHeight: 6),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('Étape 2/2', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Programme de fidélité', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.charcoalSoft,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.orange.withValues(alpha: 0.35)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.loyalty, color: AppColors.orange, size: 28),
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
                    const SizedBox(height: 24),
                    Text('Consentements', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    _ConsentCheckbox(
                      value: _acceptedTerms,
                      onChanged: (v) => setState(() => _acceptedTerms = v),
                      title: 'J\'accepte les Conditions Générales d\'Utilisation',
                      required: true,
                    ),
                    _ConsentCheckbox(
                      value: _emailOptIn,
                      onChanged: (v) => setState(() => _emailOptIn = v),
                      title: 'Je souhaite recevoir les offres par e-mail',
                    ),
                    _ConsentCheckbox(
                      value: _smsOptIn,
                      onChanged: (v) => setState(() => _smsOptIn = v),
                      title: 'Je souhaite recevoir les offres par SMS',
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: ElevatedButton(
                onPressed: _acceptedTerms ? _validate : null,
                child: const Text('Je valide mon inscription'),
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
      borderRadius: BorderRadius.circular(12),
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
