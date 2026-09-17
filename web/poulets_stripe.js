// Thin JS bridge to Stripe.js for the web build — used specifically to get
// Apple Pay (and Google Pay / Link) working on Flutter Web via Stripe's
// Express Checkout Element, since flutter_stripe's native PaymentSheet
// (used on Android/iOS — see lib/screens/stripe_checkout_screen.dart) isn't
// how Stripe recommends taking wallet payments on the web.
//
// Kept intentionally small and dynamic (plain JS, not typed Dart interop
// for the whole Stripe.js surface) — lib/services/web_stripe_checkout.dart
// only calls the few functions exposed here.
window.pouletsStripe = {
  _stripe: null,
  _elements: null,
  _confirm: null,

  init: function (publishableKey) {
    if (!this._stripe) {
      this._stripe = Stripe(publishableKey);
    }
  },

  // Mounts the Express Checkout Element (Apple Pay / Google Pay / Link —
  // whichever the browser/device actually supports) and the Payment
  // Element (typed card entry) into the two given container ids, both
  // scoped to the PaymentIntent behind `clientSecret`. `onResult` is called
  // as onResult('success', '') or onResult('error', message) once the
  // customer finishes.
  mountCheckout: function (clientSecret, expressContainerId, paymentContainerId, onResult) {
    this._elements = this._stripe.elements({ clientSecret });

    const expressCheckoutElement = this._elements.create("expressCheckout");
    expressCheckoutElement.mount("#" + expressContainerId);

    const paymentElement = this._elements.create("payment");
    paymentElement.mount("#" + paymentContainerId);

    const confirm = async () => {
      const { error } = await this._stripe.confirmPayment({
        elements: this._elements,
        confirmParams: { return_url: window.location.href },
        redirect: "if_required",
      });
      if (error) {
        onResult("error", error.message || "Le paiement a échoué.");
      } else {
        onResult("success", "");
      }
    };

    // Apple Pay / Google Pay / Link confirm themselves as soon as the
    // customer approves in their wallet sheet.
    expressCheckoutElement.on("confirm", confirm);

    // The visible "Payer" button (for the typed-card path) calls this via
    // submitPayment().
    this._confirm = confirm;
  },

  submitPayment: function () {
    if (this._confirm) this._confirm();
  },
};
