/// Stripe configuration.
///
/// [publishableKey] is safe to ship in client code — unlike the Stripe
/// *secret* key, which must never appear in this app and only ever lives
/// server-side (e.g. a Firebase Cloud Function, once the project is wired
/// up — see [lib/services/payment_intent_service.dart]).
///
/// Defaults to the restaurant's Stripe **test-mode** publishable key, so the
/// app works out of the box in development. Override at build time for a
/// live key instead of editing this file:
///   flutter build apk --dart-define=STRIPE_PUBLISHABLE_KEY=pk_live_xxx
class StripeConfig {
  const StripeConfig._();

  static const publishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: 'pk_test_51UFoKXE4fctyB2XUgiEWHyezDh4tDztRCfdJhFMgoa4N358RUNRIzx435gyaWZhzxV2Jp2LZ9QzQCR7Gi6Oo81Wy00l0QxbaF4',
  );

  static bool get isConfigured => publishableKey.isNotEmpty;

  /// Whether [publishableKey] is a Stripe test-mode key — drives whether
  /// Google Pay asks for its test environment (`pk_live_` keys need real
  /// production Google Pay access, granted by Google once the app is live).
  static bool get isTestMode => publishableKey.startsWith('pk_test_');

  /// Two-letter ISO country code of the business, used by both Apple Pay
  /// and Google Pay to know who's charging the customer.
  static const merchantCountryCode = 'FR';
}
