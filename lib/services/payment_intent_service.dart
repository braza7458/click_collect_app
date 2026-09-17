import 'package:cloud_functions/cloud_functions.dart';

/// Creates a Stripe PaymentIntent for [amountCents] via the `createPaymentIntent`
/// Cloud Function (see functions/index.js) and returns its client secret, so
/// the app can hand it straight to Stripe's PaymentSheet.
///
/// The Stripe *secret* key never appears in this app — it lives only in that
/// Cloud Function, as a Functions secret.
Future<String> fetchPaymentIntentClientSecret({
  required int amountCents,
  String currency = 'eur',
}) async {
  final result = await FirebaseFunctions.instance.httpsCallable('createPaymentIntent').call<Map<String, dynamic>>({
    'amountCents': amountCents,
    'currency': currency,
  });
  return result.data['clientSecret'] as String;
}
