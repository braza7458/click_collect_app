import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:ui_web' as ui_web;

import 'package:web/web.dart' as web;

/// Bridges to `web/poulets_stripe.js` (Stripe.js) so the web build can offer
/// Apple Pay / Google Pay through Stripe's Express Checkout Element — see
/// that file's doc comment for why this isn't done through flutter_stripe's
/// PaymentSheet on web.
///
/// Uses the dynamic `JSObject`/`callMethod` style rather than strict
/// `@JS()` external bindings — fewer places for a signature mismatch to
/// silently misbehave for this small, ad hoc surface.
class WebStripeCheckout {
  const WebStripeCheckout._();

  static const expressContainerId = 'poulets-express-checkout';
  static const paymentContainerId = 'poulets-payment-element';

  /// Registers the two DOM containers Stripe Elements mount into as Flutter
  /// platform views. Call once, before any [WebCheckoutView] is built.
  static void registerViews() {
    ui_web.platformViewRegistry.registerViewFactory(
      expressContainerId,
      (int viewId) => web.HTMLDivElement()..id = expressContainerId,
    );
    ui_web.platformViewRegistry.registerViewFactory(
      paymentContainerId,
      (int viewId) => web.HTMLDivElement()..id = paymentContainerId,
    );
  }

  static JSObject get _bridge => web.window.getProperty('pouletsStripe'.toJS) as JSObject;

  static void init(String publishableKey) {
    _bridge.callMethodVarArgs('init'.toJS, [publishableKey.toJS]);
  }

  /// Mounts both elements for [clientSecret] and resolves [onResult] with
  /// `(true, null)` on success or `(false, message)` on failure/cancel.
  static void mountCheckout(String clientSecret, void Function(bool success, String? message) onResult) {
    void handleResult(JSString status, JSString message) {
      final ok = status.toDart == 'success';
      onResult(ok, ok ? null : message.toDart);
    }

    _bridge.callMethodVarArgs('mountCheckout'.toJS, [
      clientSecret.toJS,
      expressContainerId.toJS,
      paymentContainerId.toJS,
      handleResult.toJS,
    ]);
  }

  /// Triggers the confirm flow for the typed-card Payment Element (the
  /// wallet buttons in the Express Checkout Element confirm themselves).
  static void submitPayment() {
    _bridge.callMethodVarArgs('submitPayment'.toJS, []);
  }
}
