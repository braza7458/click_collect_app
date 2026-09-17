import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../config/stripe_config.dart';
import '../data/loyalty_data.dart';
import '../data/menu_data.dart';
import '../services/payment_intent_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'order_confirmation_screen.dart';

/// Card payment for the current cart, via Stripe's PaymentSheet and the
/// `createPaymentIntent` Cloud Function (see functions/index.js and
/// lib/services/payment_intent_service.dart).
class StripeCheckoutScreen extends StatefulWidget {
  const StripeCheckoutScreen({
    super.key,
    required this.mode,
    required this.customerPhone,
    required this.restaurantName,
    required this.fulfillmentDetail,
    this.reward,
  });

  final OrderMode mode;
  final String customerPhone;
  final String? restaurantName;
  final String? fulfillmentDetail;

  /// Loyalty reward chosen on the cart screen, if any — carried through so
  /// it's still applied even though payment happens on a separate screen.
  final RewardTier? reward;

  @override
  State<StripeCheckoutScreen> createState() => _StripeCheckoutScreenState();
}

class _StripeCheckoutScreenState extends State<StripeCheckoutScreen> {
  bool _processing = false;

  Future<void> _pay(AppState appState) async {
    if (!StripeConfig.isConfigured) {
      await showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Paiement en ligne indisponible'),
          content: const Text(
            'Le paiement par carte n\'est pas encore activé sur cette installation. '
            'Choisissez « payer sur place » pour le moment, ou réessayez une fois Stripe configuré.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Compris')),
          ],
        ),
      );
      return;
    }

    setState(() => _processing = true);
    try {
      final clientSecret = await fetchPaymentIntentClientSecret(
        amountCents: (appState.cartTotal * 100).round(),
      );
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: restaurantName,
          // Un seul pays desservi — inutile de demander l'adresse/pays de
          // facturation au client.
          billingDetailsCollectionConfiguration: const BillingDetailsCollectionConfiguration(
            address: AddressCollectionMode.never,
          ),
        ),
      );
      await Stripe.instance.presentPaymentSheet();

      final order = await appState.placeOrder(
        mode: widget.mode,
        customerPhone: widget.customerPhone,
        restaurantName: widget.restaurantName,
        fulfillmentDetail: widget.fulfillmentDetail,
        paid: true,
        reward: widget.reward,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => OrderConfirmationScreen(order: order)),
      );
    } on StripeException catch (e) {
      if (!mounted) return;
      final message = e.error.localizedMessage ?? 'Le paiement a été annulé.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Le paiement a échoué côté serveur — réessayez.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Le paiement a échoué : $e')),
      );
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Paiement par carte')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.charcoalSoft,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...appState.cart.map(
                    (line) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          Text('${line.quantity} ×', style: textTheme.bodyMedium),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              line.sizeLabel != null ? '${line.itemName} (${line.sizeLabel})' : line.itemName,
                              style: textTheme.bodyLarge,
                            ),
                          ),
                          Text(formatPrice(line.lineTotal), style: textTheme.bodyLarge),
                        ],
                      ),
                    ),
                  ),
                  if (widget.reward != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.card_giftcard, size: 16, color: AppColors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${widget.reward!.label} (récompense fidélité)',
                            style: textTheme.bodyMedium?.copyWith(color: AppColors.orange),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: Text('Total à payer', style: textTheme.titleLarge)),
                      Text(
                        formatPrice(appState.cartTotal),
                        style: textTheme.headlineSmall?.copyWith(color: AppColors.orange),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (!StripeConfig.isConfigured)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: const Border(left: BorderSide(color: AppColors.badgeAmber, width: 3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 18, color: AppColors.badgeAmber),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Paiement en ligne pas encore activé sur cette installation — l\'écran est prêt, il '
                        'manque juste la connexion à un compte Stripe.',
                        style: textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _processing ? null : () => _pay(appState),
              icon: _processing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.charcoal),
                    )
                  : const Icon(Icons.lock_outline, size: 20),
              label: Text(_processing ? 'Paiement en cours…' : 'Payer ${formatPrice(appState.cartTotal)}'),
            ),
          ],
        ),
      ),
    );
  }
}
