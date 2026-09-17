// =====================================================================
// LOG DU PROJET — "Les Poulets de Mamie" (click_collect_app / _terminal / _kiosk)
// =====================================================================
//
// CE FICHIER N'EST PAS DU CODE EXÉCUTABLE (rien n'est importé nulle part
// exprès). C'est un journal de bord destiné à être lu par une IA (Claude)
// en tout début de session, pour comprendre en un seul fichier où en est
// le projet — sans avoir à relire les 3 dossiers du projet
// (click_collect_app, click_collect_terminal, click_collect_kiosk) ni la
// base Firebase derrière.
//
// RÈGLE POUR CLAUDE : à la fin de chaque session de travail (que ce soit
// avec Ibrahim ou avec son ami), avant de terminer :
//   1. Ajoute une entrée en haut de la section "HISTORIQUE DES SESSIONS"
//      avec la date et ce qui a été fait/corrigé/cassé.
//   2. Réécris entièrement la section "PROCHAINE ÉTAPE" avec ce qu'il
//      reste à faire (les items terminés sont retirés, les nouveaux
//      demandés par l'utilisateur sont ajoutés).
//   3. Si un point de la section "ÉTAT ACTUEL" a changé (nouvel écran,
//      nouvelle collection Firestore, nouvelle dépendance...), mets-le à
//      jour aussi — ce fichier doit toujours refléter l'état réel du code,
//      pas un instantané périmé.
//
// Dernière mise à jour : 17 septembre 2026.
//
// =====================================================================
// 1. VUE D'ENSEMBLE
// =====================================================================
//
// Le projet "Les Poulets de Mamie" (rôtisserie, un seul restaurant) est
// composé de 3 apps Flutter séparées + 1 backend Firebase partagé :
//
//   - click_collect_app      → app mobile cliente (commander à l'avance,
//                               compte fidélité, historique de commandes,
//                               paiement en ligne).
//   - click_collect_kiosk    → borne self-service physique en boutique
//                               (le client commande et paie directement
//                               sur place, écran tactile en mode kiosque).
//   - click_collect_terminal → terminal de réception pour le personnel
//                               (affiche en direct les commandes qui
//                               arrivent — app ET borne —, avec une alarme
//                               sonore). C'est une COPIE de click_collect_kiosk
//                               à l'origine (mêmes écrans borne dedans,
//                               attract_screen/menu_screen/checkout_screen/
//                               ticket_screen), avec en plus reception_screen.dart
//                               (le vrai écran utile pour le personnel) et
//                               staff_claim_service.dart par-dessus.
//
// Toutes les 3 apps + les Cloud Functions vivent sur le même projet
// Firebase : "les-poulets-de-mamie" (compte contact.isnad.app@gmail.com).
//
// Stack commun : Flutter + Firebase (firebase_core, cloud_firestore,
// firebase_auth, cloud_functions), google_fonts. click_collect_app et
// click_collect_terminal utilisent en plus flutter_stripe: ^14.0.0
// (paiement carte). click_collect_terminal et click_collect_kiosk
// utilisent en plus wakelock_plus + window_manager (mode kiosque),
// click_collect_terminal utilise aussi audioplayers (alarme sonore).
//
// Design system : "Braise Dorée" — thème sombre charcoal/or antique, voir
// lib/theme/app_theme.dart dans chaque projet (AppColors, AppRadius).
//
// GitHub : click_collect_app est déjà un repo git avec un remote GitHub
// (https://github.com/braza7458/click_collect_app.git, branche main,
// compte braza7458) mais avait ~30 fichiers modifiés/jamais commités avant
// la session du 17/09/2026 (tout le travail Firebase/Stripe/fidélité).
// click_collect_terminal et click_collect_kiosk n'étaient PAS encore des
// repos git avant cette même session. Voir HISTORIQUE DES SESSIONS pour
// l'état exact après la session du 17/09.
//
// =====================================================================
// 2. ÉTAT ACTUEL — click_collect_app (app cliente)
// =====================================================================
//
// Écrans (lib/screens/) :
//   - welcome_screen.dart       → écran d'accueil avant connexion
//                                 ("Bienvenue chez Les Poulets de Mamie",
//                                 boutons "Connexion / Inscription" et
//                                 "Continuer en tant qu'invité").
//   - login_screen.dart, signup_step1_screen.dart, signup_step2_screen.dart
//                               → compte = pseudo + mot de passe UNIQUEMENT
//                                 (pas d'e-mail, pas de téléphone stocké sur
//                                 le compte — voir AppState._authErrorMessage
//                                 et pseudoEmailFor() dans state/app_state.dart
//                                 qui bricole une fausse adresse e-mail pour
//                                 pouvoir utiliser Firebase Auth email/password).
//   - dashboard_shell.dart      → shell avec bottom nav (4 onglets, voir
//                                 screens/tabs/) : Accueil / Restaurants /
//                                 Commander / Plus.
//   - tabs/home_tab.dart        → onglet Accueil. Contient le bandeau
//                                 "Bonjour {pseudo}" + bouton "Mon
//                                 identifiant" (QR code), le carrousel
//                                 d'offres du moment, la carte "Votre
//                                 restaurant favori", le bloc "Événements &
//                                 Ateliers", et 2 cartes d'action (carte /
//                                 aide).
//   - tabs/restaurants_tab.dart → liste des restaurants (actuellement 3,
//                                 voir section Firestore ci-dessous).
//   - tabs/order_tab.dart       → la carte / menu, catégories + items.
//   - tabs/fidelity_tab.dart    → programme fidélité (paliers de points).
//   - choose_restaurant_screen.dart, widgets/restaurant_picker_sheet.dart
//                               → sélection du restaurant favori.
//   - cart_screen.dart          → panier, choix du mode (click&collect /
//                                 livraison / sur place), choix d'une
//                                 récompense fidélité à appliquer, paiement.
//   - stripe_checkout_screen.dart → paiement carte natif (flutter_stripe
//                                 PaymentSheet). SEUL chemin de paiement
//                                 actif (voir section Paiement ci-dessous).
//   - web_checkout_screen.dart, services/web_stripe_checkout.dart
//                               → paiement web (Stripe.js, Apple Pay/Google
//                                 Pay navigateur) — ABANDONNÉ, fichiers
//                                 orphelins non utilisés, voir section 6.
//   - order_confirmation_screen.dart → écran de confirmation après commande.
//   - order_history_screen.dart → "Mes commandes" (accessible depuis
//                                 l'onglet Plus). BUG CONNU, voir PROCHAINE
//                                 ÉTAPE #7.
//   - profile_screen.dart       → "Mon profil" (pseudo, points, statut invité).
//   - notifications_screen.dart → notifications locales (commande confirmée,
//                                 récompense échangée...).
//   - loyalty_intro_screen.dart → écran d'intro au programme fidélité.
//   - legal/cgu_screen.dart, legal/privacy_screen.dart → CGU / confidentialité.
//   - widgets/help_dialog.dart  → pop-up "Besoin d'aide ?" avec un numéro de
//                                 téléphone EN DUR. Voir PROCHAINE ÉTAPE #8.
//
// État / données (lib/state/, lib/data/) :
//   - state/app_state.dart      → state global (ChangeNotifier), tout passe
//                                 par AppStateScope.of(context). Gère
//                                 auth, panier, catalogue, restaurants,
//                                 fidélité, historique de commandes,
//                                 notifications. Persistance locale légère
//                                 via shared_preferences (panier,
//                                 notifications, dernier mode de commande) ;
//                                 tout le reste (profil, points, historique)
//                                 vit dans Firestore/Firebase Auth.
//   - data/catalog_repository.dart → lit menuCategories / restaurants /
//                                 rewardTiers depuis Firestore (PAS de
//                                 données en dur dans menu_data.dart /
//                                 restaurant_data.dart — ces fichiers ne
//                                 contiennent QUE les classes modèles
//                                 (MenuItem, MenuCategory, RestaurantLocation),
//                                 pas de données).
//   - data/orders_repository.dart → submitOrder() écrit dans Firestore
//                                 orders/{orderId} ; fetchOrdersForUser(uid)
//                                 lit les commandes d'un utilisateur — BUG
//                                 CONNU, voir PROCHAINE ÉTAPE #7.
//   - data/user_repository.dart → profil Firestore users/{uid} (pseudo,
//                                 points, restaurant favori).
//   - data/loyalty_data.dart    → modèle RewardTier (paliers de points).
//
// Assets (assets/images/) : logo.jpg, menu.jpeg (déclarés dans pubspec.yaml),
// PLUS fond.jpg, tajine.jpg, tasty_cheddar.jpg (présents sur le disque et
// déjà "git add"-és, mais PAS ENCORE déclarés dans pubspec.yaml → donc PAS
// ENCORE utilisables par Image.asset tant qu'ils ne sont pas ajoutés à la
// liste `assets:` du pubspec — voir PROCHAINE ÉTAPE #2 et #9).
//
// =====================================================================
// 3. ÉTAT ACTUEL — click_collect_terminal (terminal personnel)
// =====================================================================
//
// Écrans borne (copiés de click_collect_kiosk, identiques ou presque) :
// attract_screen.dart, menu_screen.dart, order_type_screen.dart,
// checkout_screen.dart, ticket_screen.dart, staff/staff_panel_screen.dart,
// staff/staff_pin_dialog.dart.
//
// Écran spécifique au terminal (n'existe PAS dans le kiosk) :
//   - screens/reception_screen.dart → LE vrai écran utile : liste en
//     direct des commandes (app + borne) groupées en 3 colonnes "Nouvelles"
//     / "Prêtes" / "Terminées" (IncomingOrderStatus confirmed/ready/completed),
//     avec un bouton pour faire avancer le statut. Alarme sonore + bannière
//     visuelle avec bouton "Désactiver" quand une nouvelle commande arrive
//     (voir services/alert_service.dart — boucle jusqu'à 5 minutes ou jusqu'à
//     ce que le bouton soit pressé, se relance si une nouvelle commande
//     arrive pendant que l'alarme sonne déjà). Ajouté/corrigé le 16/09/2026.
//   - services/staff_claim_service.dart → appelle la Cloud Function
//     claimStaffTerminal pour que la session anonyme Firebase Auth du
//     terminal reçoive le custom claim `staff: true` (nécessaire pour lire
//     TOUTES les commandes et changer leur statut — voir firestore.rules).
//
// Config : lib/data/kiosk_config.dart → restaurant, adresse, PIN staff
// (1957), timeouts. Actuellement câblé sur "Les Poulets de Mamie — Centre
// Ville" / "12 Rue de la République" (placeholder à corriger, voir
// PROCHAINE ÉTAPE #3/#4).
//
// Identité Android : jusqu'au 17/09/2026, click_collect_terminal partageait
// LE MÊME applicationId Android que click_collect_kiosk
// (com.isnad.click_collect_kiosk) — installer l'un écrasait l'autre sur
// l'appareil. CORRIGÉ le 17/09/2026 : le terminal a maintenant son propre
// applicationId (com.isnad.click_collect_terminal) et sa propre app
// Firebase Android (App ID 1:524117961573:android:b3cc03d81a13e296d88f8c).
// Voir HISTORIQUE DES SESSIONS. ATTENTION : cette correction n'a été faite
// QUE pour Android — si jamais iOS/web sont buildés pour le terminal un
// jour, lib/firebase_options.dart (blocs ios/macos/web/windows) pointe
// encore vers l'identité de click_collect_kiosk, il faudra faire pareil.
//
// =====================================================================
// 4. ÉTAT ACTUEL — click_collect_kiosk (borne self-service)
// =====================================================================
//
// Borne en libre-service installée en boutique : écran d'accueil "attract"
// (mode veille), le client choisit son mode de commande, parcourt le menu,
// paie, reçoit un ticket. Tourne en "mode kiosque" (services/kiosk_mode.dart,
// wakelock_plus + window_manager) avec sortie possible via PIN staff caché
// (widgets/staff_exit_gate.dart). Écrit dans la même collection Firestore
// `orders` que l'app (avec `source: 'kiosk'` a priori — à vérifier contre
// le code borne exact si besoin, non audité en détail dans cette session).
// N'a PAS de paiement Stripe dans son pubspec (contrairement à app et
// terminal) — à vérifier si c'est voulu ou un oubli le jour où quelqu'un
// travaille dessus.
//
// =====================================================================
// 5. BACKEND FIREBASE (projet "les-poulets-de-mamie")
// =====================================================================
//
// -- Firestore — collections --
//   - menuCategories/{id}   → catalogue (lecture publique, écriture
//                             uniquement via tool/seed_firestore.dart ou
//                             à la main dans la console — voir
//                             firestore.rules). Champs : title, icon,
//                             items[] (name, price, sizes[{label,price}],
//                             note, allowsSupplements, isAddOn, isInfoOnly,
//                             infoLabel), order.
//   - restaurants/{id}      → lecture publique, écriture bloquée pareil.
//                             Champs actuels : name, address, hours
//                             (UNE SEULE chaîne de texte, ex "11h30 -
//                             21h30" — PAS de champ `phone`, PAS
//                             d'horaires par jour). Voir PROCHAINE ÉTAPE
//                             #3/#4 : le modèle RestaurantLocation
//                             (lib/data/restaurant_data.dart) devra être
//                             étendu.
//   - rewardTiers/{id}      → paliers fidélité (points, label, icon).
//   - users/{uid}           → profil compte (username, points,
//                             favoriteRestaurantName). Lecture/écriture
//                             réservée au propriétaire du uid.
//   - orders/{orderId}      → commandes, écrites par app ET kiosk/terminal
//                             (même collection). Champs (voir
//                             lib/models/order.dart côté app et
//                             lib/models/incoming_order.dart côté
//                             terminal) : id, date (ISO 8601 string), mode,
//                             lines[], total, pointsEarned, restaurantName,
//                             fulfillmentDetail, status
//                             (confirmed/ready/completed), paid, userId,
//                             customerPhone, appliedRewardLabel, source
//                             ('app' ou 'kiosk'). Création : tout utilisateur
//                             authentifié (y compris sessions anonymes
//                             invité/borne/terminal). Lecture : le
//                             propriétaire (userId) OU un terminal avec le
//                             custom claim `staff: true`. Modification :
//                             uniquement le champ `status`, uniquement par
//                             un terminal `staff: true`.
//
// -- Index composite (firestore.indexes.json) --
//   Un seul index déclaré actuellement : orders (source ASC, date DESC).
//   ⚠️ AUCUN index pour la requête (userId ==, orderBy date) utilisée par
//   OrdersRepository.fetchOrdersForUser() côté app → voir PROCHAINE ÉTAPE
//   #7, c'est très probablement LA cause du bug "mes commandes vides".
//
// -- Cloud Functions (functions/index.js, Node 20, gen2) --
//   - claimStaffTerminal (us-central1, onCall) → donne le custom claim
//     staff:true à l'appelant (protégé par le code STAFF_SETUP_CODE = "1957",
//     doit rester synchro avec KioskConfig.staffPin dans kiosk/terminal).
//   - createPaymentIntent (us-central1, onCall, secret STRIPE_SECRET_KEY)
//     → crée un PaymentIntent Stripe. Depuis le 16/09/2026 :
//     payment_method_types: ['card'] uniquement (avant :
//     automatic_payment_methods, qui faisait apparaître Link/Klarna/
//     Bancontact/Amazon Pay/Satispay/EPS en plus de la carte).
//   - onOrderCreatedSendConfirmationSms (europe-west1, onDocumentCreated
//     sur orders/{orderId}, secret BREVO_API_KEY) → SMS de confirmation via
//     l'API Brevo (transactionalSMS/send), expéditeur "PouletMamie".
//   - onOrderReadySendSms (europe-west1, onDocumentUpdated sur
//     orders/{orderId}, même secret) → SMS "commande prête" quand status
//     passe à "ready".
//   Ces 2 fonctions SMS ont été cassées un moment (voir historique) puis
//   remises en marche et CONFIRMÉES FONCTIONNELLES le 16/09/2026 (SMS
//   réellement reçus par l'utilisateur après achat de crédits Brevo).
//
// -- SMS (Brevo) --
//   Le SMS transactionnel Brevo nécessite des crédits payants SÉPARÉS de
//   l'abonnement email "Starter" (7€/mois) — malgré le fait que la page
//   de tarification Brevo liste "Email et SMS" comme inclus, sans préciser
//   que le SMS a son propre système de crédits. ~4,5 crédits par SMS vers
//   la France, crédits vendus par lots de 100 (100 crédits = 1€) → ~5
//   centimes/SMS. Le compte avait 0 crédit SMS jusqu'au 16/09/2026 (tous
//   les SMS étaient rejetés silencieusement, statut "Rejeté" visible dans
//   Brevo → Transactionnel → SMS → Temps réel, sans qu'aucune erreur ne
//   remonte côté app ni côté logs Cloud Functions). Crédits achetés (5€ /
//   100 SMS), SMS confirmés reçus depuis.
//
// =====================================================================
// 6. PAIEMENT (Stripe)
// =====================================================================
//
// SEUL chemin actif : paiement carte natif via flutter_stripe's
// PaymentSheet (lib/screens/stripe_checkout_screen.dart dans
// click_collect_app, et l'équivalent dans click_collect_terminal). Utilise
// createPaymentIntent (Cloud Function ci-dessus). Depuis le 16/09/2026,
// carte uniquement (plus de Link/Klarna/etc.).
//
// PAS ENCORE FAIT : billingDetailsCollectionConfiguration pour supprimer
// le champ "Pays / région" du formulaire carte — ajouté dans
// stripe_checkout_screen.dart de click_collect_app le 16/09/2026
// (BillingDetailsCollectionConfiguration(address: AddressCollectionMode.never)),
// mais PAS encore vérifié si click_collect_terminal a la même chose (à
// vérifier/répliquer si le terminal a aussi un écran de paiement carte
// utilisé en pratique).
//
// ABANDONNÉ (ne pas reprendre sauf demande explicite) : une tentative de
// paiement WEB avec Apple Pay/Google Pay via Stripe.js (Express Checkout +
// Payment Element) dans click_collect_app — fichiers
// lib/screens/web_checkout_screen.dart, lib/services/web_stripe_checkout.dart,
// web/poulets_stripe.js. Abandonnée après ~1h de debug sans succès (bug
// jamais trouvé). Ces fichiers existent toujours sur le disque mais ne sont
// PLUS importés depuis main.dart (donc n'affectent pas la compilation
// native). Apple Pay est de toute façon iOS-only — jamais visible sur
// Android quoi qu'il arrive.
//
// =====================================================================
// 7. HISTORIQUE DES SESSIONS (la plus récente en premier)
// =====================================================================
//
// --- 17/09/2026 ---
// - Diagnostiqué et corrigé : click_collect_terminal et click_collect_kiosk
//   partageaient le même applicationId Android (com.isnad.click_collect_kiosk)
//   → installer l'un écrasait l'autre sur l'appareil ("le terminal ouvrait
//   le kiosk"). Terminal recréé avec son propre applicationId
//   (com.isnad.click_collect_terminal), nouvelle app Firebase Android créée
//   (App ID 1:524117961573:android:b3cc03d81a13e296d88f8c),
//   android/app/google-services.json et lib/firebase_options.dart du
//   terminal mis à jour en conséquence. `flutter analyze` + `flutter build
//   apk --debug` OK sur le terminal après coup.
// - Création de ce fichier log.dart (demande explicite d'Ibrahim, pour que
//   Claude — le sien ou celui de son ami — puisse lire l'état du projet
//   sans tout réexplorer).
// - Recueil des 11 points listés en section PROCHAINE ÉTAPE (9 pour
//   click_collect_app, 2 pour click_collect_terminal) — DEMANDE EXPLICITE
//   D'IBRAHIM : NE RIEN CODER pour ces 11 points pendant cette session,
//   uniquement les documenter ici pour qu'une session future (la sienne ou
//   celle de son ami) les implémente directement.
// - Aide à la mise sur GitHub des 3 dossiers (voir état des repos en
//   section 1 / commit(s) de cette session pour le détail exact — à
//   compléter par Claude une fois la mise sur GitHub terminée).
//
// --- 16/09/2026 ---
// - Restriction des moyens de paiement Stripe à la carte uniquement
//   (functions/index.js : payment_method_types: ['card']).
// - Suppression du champ "Pays/région" du formulaire carte
//   (BillingDetailsCollectionConfiguration(address: AddressCollectionMode.never)
//   dans stripe_checkout_screen.dart de click_collect_app).
// - Refonte de l'alarme du terminal (services/alert_service.dart +
//   screens/reception_screen.dart) : boucle jusqu'à 5 minutes au lieu de 2
//   bips, bouton "Désactiver" qui apparaît à chaque nouvelle commande et
//   relance le minuteur de 5 min si une commande arrive pendant que
//   l'alarme sonne déjà.
// - Diagnostic + correction des SMS qui ne partaient jamais : (a) une
//   ancienne révision des Cloud Functions plantait au démarrage
//   ("Cannot find module '@google-cloud/firestore'") → redéployé
//   proprement ; (b) le compte Brevo n'avait 0 crédit SMS → crédits
//   achetés par Ibrahim, SMS confirmés reçus.
// - Avant ça (même session, plus tôt) : ~1h de debug infructueux sur un
//   paiement web Apple Pay/Google Pay via Stripe.js → abandonné à la
//   demande d'Ibrahim (voir section 6).
// - Correction d'un bug de build Android : des imports web-only
//   (dart:ui_web, package:web) dans web_checkout_screen.dart /
//   web_stripe_checkout.dart avaient cassé la compilation Android native
//   de click_collect_app ("impossible de lancer l'appli") — corrigé en
//   retirant leur import depuis cart_screen.dart (fichiers rendus orphelins
//   plutôt que supprimés).
//
// --- Sessions antérieures (résumé, non détaillé ici) ---
// - Mise en place complète du backend Firebase (Auth, Firestore, Cloud
//   Functions) pour remplacer les données en dur.
// - Refonte visuelle complète : design system "Braise Dorée".
// - Ajout du parcours complet : connexion, inscription, fidélité,
//   dashboard, panier, historique.
// - Intégration Stripe native (PaymentSheet) dans l'app et le terminal.
// - Construction de click_collect_kiosk et click_collect_terminal (borne +
//   réception personnel).
//
// =====================================================================
// 8. PROCHAINE ÉTAPE — À FAIRE (demandé le 17/09/2026, PAS ENCORE CODÉ)
// =====================================================================
//
// ⚠️ Ces 11 points ont été listés par Ibrahim le 17/09/2026 en demandant
// EXPLICITEMENT qu'ils ne soient PAS implémentés tout de suite — juste
// consignés ici pour qu'une prochaine session (la sienne ou celle de son
// ami) les exécute directement. Les indications entre [crochets] sont des
// pistes techniques trouvées en explorant le code pendant cette session,
// pour accélérer le travail — pas des instructions de l'utilisateur.
//
// === click_collect_app ===
//
// 1) Écran d'accueil (onglet Accueil, lib/screens/tabs/home_tab.dart) :
//    à côté de "Bonjour {pseudo}", remplacer le bouton "Mon identifiant"
//    par "Me connecter" TANT QUE l'utilisateur est invité (appState.isGuest)
//    — ce bouton doit amener directement à LoginScreen. Une fois connecté
//    (appState.isGuest == false), garder le bouton actuel "Mon identifiant"
//    (QR code, voir _showMemberCard()) tel quel.
//    [Piste : home_tab.dart lignes 36-41 pour le bouton actuel, condition
//    à ajouter sur appState.isGuest ; LoginScreen déjà importée nulle part
//    dans ce fichier, import à ajouter depuis screens/login_screen.dart.]
//
// 2) Ajouter dans l'écran d'accueil les 2 images "tasty cheddar" et
//    "tajine" (déjà présentes dans assets/images/tasty_cheddar.jpg et
//    assets/images/tajine.jpg, déjà "git add"-ées mais PAS déclarées dans
//    pubspec.yaml → à ajouter dans la liste `assets:` d'abord, sinon
//    Image.asset plantera).
//    [Piste : home_tab.dart a déjà un carrousel "_offers" avec des cartes
//    texte only (_OfferCard) mentionnant justement "Le Crousty Cheddar" et
//    "Tajine du mercredi" — le plus cohérent est probablement d'ajouter une
//    image à ces cartes-là plutôt que créer une nouvelle section, mais à
//    confirmer avec Ibrahim si un autre emplacement est voulu.]
//
// 3) Dans TOUTE l'application (click_collect_app + click_collect_kiosk +
//    click_collect_terminal), ne garder qu'UN SEUL restaurant, avec ces
//    infos : adresse "250 Rue du Galupe, 64170 Artix", téléphone
//    "07 61 85 18 31".
//    [Piste : (a) le modèle RestaurantLocation (click_collect_app/lib/data/
//    restaurant_data.dart) n'a AUCUN champ `phone` actuellement (juste name/
//    address/hours/isOpenNow) → à ajouter, avec toMap/fromMap. (b) Les 3
//    restaurants actuels sont seedés dans Firestore via
//    click_collect_app/tool/seed_firestore.dart (_restaurants, lignes ~193-197)
//    → à remplacer par une seule entrée, puis re-exécuter
//    `dart run tool/seed_firestore.dart` (attention : ce script écrit via
//    l'API REST Firestore SANS AUTH, ça ne marche que si les règles
//    Firestore sont temporairement ouvertes — sinon écrire les documents à
//    la main dans la console, ou adapter le script). Il faudra aussi
//    SUPPRIMER les 2 anciens documents restaurant-1/restaurant-2 devenus
//    inutiles (le script ne fait que des PATCH/upsert, pas de nettoyage).
//    (c) click_collect_kiosk/lib/data/kiosk_config.dart ET
//    click_collect_terminal/lib/data/kiosk_config.dart ont CHACUN
//    restaurantLocationName + restaurantAddress en dur (actuellement
//    "Les Poulets de Mamie — Centre Ville" / "12 Rue de la République") →
//    à mettre à jour dans les 2 fichiers, plus y ajouter un champ
//    téléphone si utilisé quelque part dans ces 2 apps.]
//
// 4) Ajouter les bons horaires (probablement sur la fiche restaurant,
//    lib/screens/tabs/restaurants_tab.dart et/ou home_tab.dart "Votre
//    restaurant favori") :
//      jeudi     09:30–14:30, 18:00–21:00
//      vendredi  09:30–14:30, 18:00–21:00
//      samedi    09:30–14:30, 18:00–21:00
//      dimanche  09:30–14:30
//      lundi     Fermé
//      mardi     Fermé
//      mercredi  09:30–14:30, 18:00–21:00
//    [Piste : le champ `hours` actuel de RestaurantLocation est UNE SEULE
//    chaîne de texte plate (ex "11h30 - 21h30"), pas un horaire par jour →
//    le modèle devra être étendu (soit une Map<String,String> jour→plage,
//    soit une liste de jours structurée) pour représenter des horaires
//    différents par jour + jours fermés. Impacte restaurant_data.dart,
//    catalog_repository.dart (fromMap/toMap), tool/seed_firestore.dart, et
//    l'écran qui affiche les horaires.]
//
// 5) Section "Événements & Ateliers" de l'écran d'accueil
//    (home_tab.dart) : enlever le mot "Ateliers" du titre (donc "Événements
//    & Ateliers" → probablement juste "Événements"), ET enlever les
//    événements actuels (placeholders "Atelier découpe de poulet" /
//    "Soirée dégustation") en les remplaçant par "Événements à venir".
//    [Piste : home_tab.dart ligne 108 pour le titre de section, classe
//    _Event + const _events (lignes ~264-274) pour la liste en dur à vider/
//    remplacer. Ambigu si "remplace par 'Événements à venir'" veut dire (a)
//    renommer le titre de section en "Événements à venir" et vider la
//    liste avec un état vide, ou (b) autre chose — à clarifier avec
//    Ibrahim si besoin avant de coder, ou prendre la lecture (a) qui est la
//    plus naturelle.]
//
// 6) Dans la carte (menu), le "Crousty Cheddar" doit avoir le prix
//    "8,50€ / 10,00€" (comme M/L).
//    [Piste : actuellement dans tool/seed_firestore.dart (_menuCategories,
//    catégorie "Nos Bowls"), l'item "Crousty Cheddar" a price: null, sizes: [],
//    note: 'Taille M / L — prix à confirmer' → à remplacer par
//    sizes: [{'label': 'M', 'price': 8.50}, {'label': 'L', 'price': 10.00}]
//    (exactement comme "Crousty Tenders" juste en dessous dans le même
//    fichier), et retirer/adapter la note "prix à confirmer". Puis
//    re-seeder ou modifier le document Firestore menuCategories/cat-1
//    directement.]
//
// 7) "Mon profil" → "Mes commandes" (order_history_screen.dart) n'affiche
//    pas les commandes passées : à corriger.
//    [Piste très probable trouvée en explorant le code cette session :
//    OrdersRepository.fetchOrdersForUser() (click_collect_app/lib/data/
//    orders_repository.dart lignes 25-32) fait
//    .where('userId', isEqualTo: uid).orderBy('date', descending: true)
//    — une requête composite qui EXIGE un index Firestore composite
//    (userId + date). Le fichier firestore.indexes.json ne déclare
//    actuellement QU'UN SEUL index, sur (source ASC, date DESC) — AUCUN
//    index sur (userId, date). Sans cet index, Firestore renvoie une
//    erreur FAILED_PRECONDITION, qui est silencieusement avalée par le
//    try/catch de AppState._loadUserProfile() (app_state.dart lignes
//    157-171, commentaire "Offline — keep whatever profile..." — ce
//    catch-all avale AUSSI les vraies erreurs, pas seulement le mode hors
//    ligne). Ça expliquerait un historique systématiquement vide, sans
//    aucune erreur visible. Fix probable : ajouter l'index composite
//    (userId ASC, date DESC) sur la collection orders dans
//    firestore.indexes.json, puis `firebase deploy --only firestore:indexes`
//    — OU laisser Firestore le proposer automatiquement (l'erreur
//    FAILED_PRECONDITION contient normalement un lien direct pour créer
//    l'index en un clic, visible si on retire temporairement le try/catch
//    pour voir l'erreur réelle en debug). À VÉRIFIER avant de considérer
//    que c'est LA cause unique — il peut aussi y avoir un souci de
//    `userId` non renseigné sur certaines commandes.]
//
// 8) Dans "Aide" (widgets/help_dialog.dart), remplacer le numéro en dur
//    "01 23 45 67 89" par "07 61 85 18 31" (le numéro du snack).
//    [Piste : help_dialog.dart ligne 9, une seule ligne à changer.]
//
// 9) Mettre une image de fond sur TOUTE l'application click_collect_app
//    (tous les écrans), avec un peu de flou. L'image existe déjà dans
//    assets/images/fond.jpg (déjà "git add"-ée, mais comme pour le point 2,
//    PAS ENCORE déclarée dans pubspec.yaml).
//    [Piste : à ajouter dans pubspec.yaml `assets:`. Pour l'appliquer
//    "sur toute l'application" proprement plutôt que de dupliquer le code
//    sur chaque écran, le plus propre est probablement un wrapper commun
//    (par ex. dans main.dart via MaterialApp.builder, ou un widget
//    partagé enveloppant chaque Scaffold) avec un Stack contenant
//    Image.asset('assets/images/fond.jpg', fit: BoxFit.cover) puis un
//    ImageFiltered/BackdropFilter(filter: ImageFilter.blur(...)) pour le
//    flou. Attention : plusieurs écrans ont déjà leur propre fond/dégradé
//    (ex. welcome_screen.dart utilise déjà assets/images/menu.jpeg en
//    fond) — à voir avec Ibrahim si cette image de fond remplace
//    welcome_screen.dart aussi ou seulement les écrans qui n'ont pas déjà
//    une image de fond dédiée. Penser aussi à garder le texte lisible
//    par-dessus (le thème actuel est déjà sombre avec du texte clair, donc
//    probablement ajouter un scrim sombre semi-transparent entre le fond
//    flouté et le contenu, comme le fait déjà welcome_screen.dart avec son
//    LinearGradient).]
//
// === click_collect_terminal ===
//
// 1) Ajouter un bouton en haut de reception_screen.dart, "Commandes", qui
//    ouvre un calendrier classique (année/mois/jour) : chaque case de jour
//    est cliquable et affiche le nombre de commandes passées ce jour-là
//    (et permet d'accéder à leur détail).
//    [Piste : reception_screen.dart a déjà un AppBar avec une action
//    (icône "Espace équipe" vers StaffPanelScreen, ligne ~132-139) — un
//    bouton "Commandes" peut suivre le même pattern. Un package comme
//    `table_calendar` (pub.dev) est l'option la plus rapide pour le
//    calendrier plutôt que d'en construire un à la main. Il faudra une
//    requête Firestore par jour sur orders (filtrée sur `date`, avec les
//    limites de fuseau horaire à gérer puisque `date` est stocké en ISO
//    8601 string — voir Order.toJson()/fromJson() dans click_collect_app,
//    et IncomingOrder.fromFirestore() côté terminal). Pas d'écran de ce
//    type actuellement dans le projet — nouveau screen à créer, ex.
//    lib/screens/order_calendar_screen.dart.]
//
// 2) Vérifier que les colonnes "Nouvelles" et "Prêtes" sont bien
//    déroulantes comme "Terminées" quand il y a plusieurs commandes (pour
//    voir celles en dessous en scrollant).
//    [Piste : en relisant reception_screen.dart pendant cette session
//    (16-17/09/2026), les 3 colonnes ("Nouvelles", "Prêtes", "Terminées")
//    utilisent EXACTEMENT le même widget _OrderColumn avec un
//    Expanded(child: ListView.separated(...)) — donc structurellement,
//    elles devraient déjà toutes défiler pareil. Le bug rapporté est peut-
//    être un problème de contrainte de hauteur/overflow visible seulement
//    en pratique sur l'appareil réel (pas évident en relisant juste le
//    code), ou peut-être que le comportement a changé depuis. À reproduire
//    sur l'appareil et déboguer visuellement plutôt que de partir d'une
//    hypothèse de code non confirmée — voir aussi la mémoire "no extended
//    live debugging" : privilégier un logs/dashboard/repro concret avant
//    de itérer à l'aveugle sur le layout.]
//
// =====================================================================
// FIN DU LOG — rappel : mets-le à jour avant de terminer ta session.
// =====================================================================
