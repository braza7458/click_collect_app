const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {onDocumentCreated, onDocumentUpdated} = require("firebase-functions/v2/firestore");
const {defineSecret} = require("firebase-functions/params");
const Stripe = require("stripe");
const {initializeApp} = require("firebase-admin/app");
const {getAuth} = require("firebase-admin/auth");

// firebase-admin v13+ dropped the old `require("firebase-admin")` namespace
// object (no more `admin.auth()`) in favor of these per-service imports.
initializeApp();

// Set once with: firebase functions:secrets:set STRIPE_SECRET_KEY
// Never hardcoded here, never shipped to either app.
const stripeSecretKey = defineSecret("STRIPE_SECRET_KEY");

// Must match KioskConfig.staffPin / TerminalConfig.staffPin in the kiosk and
// terminal apps — it's the same code staff already type to reach the staff
// panel, reused here as the one-time setup code that upgrades a reception
// terminal's anonymous Firebase Auth session into a "staff" session. Change
// it in all three places together if it's ever rotated.
const STAFF_SETUP_CODE = "1957";

/**
 * Grants the caller's own (anonymous) Firebase Auth uid a `staff: true`
 * custom claim, gated by STAFF_SETUP_CODE. Called once by a reception
 * terminal on first launch (see lib/services/staff_claim_service.dart in
 * click_collect_terminal) so firestore.rules can let it read every order
 * and advance an order's status — a normal app/guest session never calls
 * this and never gets the claim.
 */
exports.claimStaffTerminal = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Connexion requise.");
  }
  const setupCode = request.data && request.data.setupCode;
  if (setupCode !== STAFF_SETUP_CODE) {
    throw new HttpsError("permission-denied", "Code invalide.");
  }
  await getAuth().setCustomUserClaims(request.auth.uid, {staff: true});
  return {ok: true};
});

/**
 * Creates a Stripe PaymentIntent for the app's cart total and returns its
 * client secret, so the app can hand it straight to Stripe's PaymentSheet.
 * This is the only place the Stripe secret key is ever used — see
 * lib/services/payment_intent_service.dart in click_collect_app for the
 * client side of this call.
 */
exports.createPaymentIntent = onCall({secrets: [stripeSecretKey]}, async (request) => {
  const amountCents = request.data && request.data.amountCents;
  const currency = (request.data && request.data.currency) || "eur";

  if (!Number.isInteger(amountCents) || amountCents <= 0) {
    throw new HttpsError("invalid-argument", "amountCents must be a positive integer.");
  }

  const stripe = new Stripe(stripeSecretKey.value());
  const paymentIntent = await stripe.paymentIntents.create({
    amount: amountCents,
    currency,
    // Carte uniquement — pas de Link/Klarna/Bancontact/Amazon Pay/Satispay/EPS.
    // Google Pay reste disponible séparément, via le PaymentSheet côté app.
    payment_method_types: ["card"],
  });

  return {clientSecret: paymentIntent.client_secret};
});

// Set once with: firebase functions:secrets:set BREVO_API_KEY
const brevoApiKey = defineSecret("BREVO_API_KEY");

// The alphanumeric sender name shown to the customer instead of a phone
// number — French carriers (and Brevo) cap this at 11 characters, hence
// the dropped "s" from "Poulets".
const SMS_SENDER = "PouletMamie";

/**
 * "0612345678" / "06 12 34 56 78" -> "+33612345678". Brevo needs E.164
 * (country code, no spaces) — this is the only shape either app's phone
 * field actually collects, so a simple French-only normalizer is enough.
 */
function toE164France(raw) {
  const digits = raw.replace(/[^\d+]/g, "");
  if (digits.startsWith("+")) return digits;
  if (digits.startsWith("0")) return `+33${digits.slice(1)}`;
  if (digits.startsWith("33")) return `+${digits}`;
  return digits;
}

async function sendSms(apiKey, rawPhone, content) {
  const recipient = toE164France(rawPhone);
  const response = await fetch("https://api.brevo.com/v3/transactionalSMS/send", {
    method: "POST",
    headers: {
      "accept": "application/json",
      "api-key": apiKey,
      "content-type": "application/json",
    },
    body: JSON.stringify({sender: SMS_SENDER, recipient, content, type: "transactional"}),
  });
  if (!response.ok) {
    console.error(`Brevo SMS to ${recipient} failed (${response.status}): ${await response.text()}`);
  }
}

/**
 * Texts the customer as soon as their order lands in Firestore — covers
 * both the app (click_collect_app's OrdersRepository.submitOrder) and the
 * terminal's Borne mode (click_collect_terminal's
 * OrdersRepository.submitTicket), since both write into this same
 * collection and both collect a phone number at checkout. Silently does
 * nothing if no phone was given (e.g. "payer en caisse" without the
 * optional fidelity phone field).
 */
exports.onOrderCreatedSendConfirmationSms = onDocumentCreated(
  {document: "orders/{orderId}", secrets: [brevoApiKey]},
  async (event) => {
    const phone = event.data?.data()?.customerPhone;
    if (!phone) return;
    await sendSms(
      brevoApiKey.value(),
      phone,
      "Les Poulets de Mamie : votre commande est bien confirmée ! On vous prévient dès qu'elle est prête.",
    );
  },
);

/**
 * Texts the customer the moment a reception terminal marks their order
 * "ready" — see click_collect_terminal's
 * OrdersRepository.updateStatus / ReceptionScreen.
 */
exports.onOrderReadySendSms = onDocumentUpdated(
  {document: "orders/{orderId}", secrets: [brevoApiKey]},
  async (event) => {
    const before = event.data?.before?.data();
    const after = event.data?.after?.data();
    if (!after || after.status !== "ready" || before?.status === "ready") return;
    const phone = after.customerPhone;
    if (!phone) return;
    await sendSms(
      brevoApiKey.value(),
      phone,
      "Les Poulets de Mamie : votre commande est prête, venez la récupérer !",
    );
  },
);
