import 'dart:async';

import 'package:flutter/material.dart';

import '../config/stripe_config.dart';
import '../data/loyalty_data.dart';
import '../data/menu_data.dart';
import '../services/payment_intent_service.dart';
import '../services/web_stripe_checkout.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'order_confirmation_screen.dart';

/// Web equivalent of [StripeCheckoutScreen] — same job (pay the cart total,
/// then place the order as paid), but through Stripe's Express Checkout +
/// Payment Elements (Stripe.js) instead of flutter_stripe's PaymentSheet,
/// because that's how Apple Pay / Google Pay actually show up in a browser.
/// See web_stripe_checkout.dart for the interop, web/poulets_stripe.js for
/// the Stripe.js side.
///
/// The wallet buttons (Apple Pay especially) only render for a visitor on a
/// matching browser/device with a wallet configured — e.g. Apple Pay is
/// Safari-only. Elsewhere the Payment Element (typed card) still works.
class WebCheckoutScreen extends StatefulWidget {
  const WebCheckoutScreen({
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
  final RewardTier? reward;

  @override
  State<WebCheckoutScreen> createState() => _WebCheckoutScreenState();
}

class _WebCheckoutScreenState extends State<WebCheckoutScreen> {
  bool _loading = true;
  bool _submitting = false;
  String? _error;
  String? _clientSecret;

  @override
  void initState() {
    super.initState();
    WebStripeCheckout.registerViews();
    runZonedGuarded(_init, (e, st) {
      // ignore: avoid_print
      print('ZONE_ERROR: $e\n$st');
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'ZONE_ERROR: $e';
        });
      }
    });
  }

  Future<void> _init() async {
    // ignore: avoid_print
    print('STEP 1: _init start');
    final appState = AppStateScope.of(context);
    try {
      // ignore: avoid_print
      print('STEP 2: before WebStripeCheckout.init');
      WebStripeCheckout.init(StripeConfig.publishableKey);
      // ignore: avoid_print
      print('STEP 3: before fetchPaymentIntentClientSecret');
      final clientSecret = await fetchPaymentIntentClientSecret(
        amountCents: (appState.cartTotal * 100).round(),
      );
      // ignore: avoid_print
      print('STEP 4: got clientSecret, mounted=$mounted');
      if (!mounted) return;
      setState(() {
        _clientSecret = clientSecret;
        _loading = false;
      });
      // ignore: avoid_print
      print('STEP 5: setState done, scheduling postFrameCallback');
      // The HtmlElementView containers only exist in the real DOM once this
      // build lands — Stripe's `.mount('#id')` needs that element to
      // already be there, so defer to the frame right after.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // ignore: avoid_print
        print('STEP 6: postFrameCallback fired, mounted=$mounted');
        if (!mounted || _clientSecret == null) return;
        try {
          // ignore: avoid_print
          print('STEP 7: before WebStripeCheckout.mountCheckout');
          WebStripeCheckout.mountCheckout(_clientSecret!, _handleResult);
          // ignore: avoid_print
          print('STEP 8: mountCheckout call returned normally');
        } catch (e, st) {
          // ignore: avoid_print
          print('MOUNT_ERROR: $e\n$st');
          if (mounted) setState(() => _error = 'MOUNT_ERROR: $e');
        }
      });
    } catch (e, st) {
      // ignore: avoid_print
      print('INIT_ERROR: $e\n$st');
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Impossible de préparer le paiement — vérifiez votre connexion et réessayez.';
        });
      }
    }
  }

  Future<void> _handleResult(bool success, String? message) async {
    if (!mounted) return;
    if (!success) {
      setState(() {
        _submitting = false;
        _error = message ?? 'Le paiement a échoué.';
      });
      return;
    }
    final appState = AppStateScope.of(context);
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
              child: Row(
                children: [
                  Expanded(child: Text('Total à payer', style: textTheme.titleLarge)),
                  Text(
                    formatPrice(appState.cartTotal),
                    style: textTheme.headlineSmall?.copyWith(color: AppColors.orange),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.red.withValues(alpha: 0.4)),
                  ),
                  child: Text(_error!, style: textTheme.bodyMedium?.copyWith(color: AppColors.red)),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                'Payez en un geste (Apple Pay, Google Pay…) si votre navigateur le propose :',
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              const SizedBox(
                height: 56,
                child: HtmlElementView(viewType: WebStripeCheckout.expressContainerId),
              ),
              const SizedBox(height: 20),
              Text('Ou par carte :', style: textTheme.bodySmall),
              const SizedBox(height: 8),
              const SizedBox(
                height: 260,
                child: HtmlElementView(viewType: WebStripeCheckout.paymentContainerId),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitting
                      ? null
                      : () {
                          setState(() {
                            _submitting = true;
                            _error = null;
                          });
                          WebStripeCheckout.submitPayment();
                        },
                  icon: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.charcoal),
                        )
                      : const Icon(Icons.lock_outline, size: 20),
                  label: Text(_submitting ? 'Paiement en cours…' : 'Payer ${formatPrice(appState.cartTotal)}'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
