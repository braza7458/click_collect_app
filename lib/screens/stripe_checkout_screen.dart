import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../config/stripe_config.dart';
import '../data/loyalty_data.dart';
import '../data/menu_data.dart';
import '../services/payment_intent_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/ui.dart';
import 'order_confirmation_screen.dart';

/// Card payment for the current cart, via Stripe's PaymentSheet and the
/// `createPaymentIntent` Cloud Function (see functions/index.js and
/// lib/services/payment_intent_service.dart).
class StripeCheckoutScreen extends StatefulWidget {
  const StripeCheckoutScreen({
    super.key,
    required this.mode,
    required this.customerPhone,
    required this.fulfillmentDetail,
    this.reward,
  });

  final OrderMode mode;
  final String customerPhone;
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
      appBar: AppBar(title: const Text('Paiement')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            // Le "ticket" : récapitulatif façon reçu, total en grand.
            GlassCard(
              radius: AppRadius.xl,
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Eyebrow('Votre commande'),
                  const SizedBox(height: 14),
                  ...appState.cart.map(
                    (line) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.orange.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppRadius.xs),
                            ),
                            child: Text('${line.quantity}', style: textTheme.labelLarge?.copyWith(color: AppColors.orange)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              line.sizeLabel != null ? '${line.itemName} · ${line.sizeLabel}' : line.itemName,
                              style: textTheme.bodyLarge,
                            ),
                          ),
                          Text(formatPrice(line.lineTotal), style: textTheme.bodyLarge),
                        ],
                      ),
                    ),
                  ),
                  if (widget.reward != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.card_giftcard_rounded, size: 18, color: AppColors.honey),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${widget.reward!.label} (récompense fidélité)',
                            style: textTheme.bodyMedium?.copyWith(color: AppColors.honey),
                          ),
                        ),
                        Text('offert', style: textTheme.bodySmall?.copyWith(color: AppColors.honey)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 14),
                  const _DashedDivider(),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(child: Text('Total à payer', style: textTheme.titleMedium)),
                      Text(
                        formatPrice(appState.cartTotal),
                        style: textTheme.displaySmall?.copyWith(color: AppColors.orange, fontSize: 34),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (!StripeConfig.isConfigured)
              GlassCard(
                borderColor: AppColors.honey.withValues(alpha: 0.5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.honey),
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
            GlowButton(
              icon: Icons.lock_rounded,
              busy: _processing,
              label: 'Payer ${formatPrice(appState.cartTotal)}',
              onPressed: () => _pay(appState),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.verified_user_outlined, size: 15, color: AppColors.creamMuted),
                const SizedBox(width: 6),
                Text('Carte bancaire · paiement chiffré par Stripe', style: textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = (constraints.maxWidth / 10).floor();
        return Row(
          children: List.generate(
            count,
            (_) => Expanded(
              child: Container(
                height: 1.2,
                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                color: AppColors.glassBorder,
              ),
            ),
          ),
        );
      },
    );
  }
}
