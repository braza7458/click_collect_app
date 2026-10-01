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
// avec Ibrahim ou avec son ami Ryad), avant de terminer :
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
// Dernière mise à jour : 1er octobre 2026 (2e session du jour).
//
// =====================================================================
// 1. VUE D'ENSEMBLE
// =====================================================================
//
// Le projet "Les Poulets de Mamie" (rôtisserie, UN SEUL restaurant :
// 250 Rue du Galupe, 64170 Artix — 07 61 85 18 31) est composé de 3 apps
// Flutter séparées + 1 backend Firebase partagé :
//
//   - click_collect_app      → app mobile cliente (commander à l'avance,
//                               compte fidélité, suivi des commandes en
//                               direct, paiement en ligne).
//   - click_collect_kiosk    → borne self-service physique en boutique
//                               (le client commande et paie directement
//                               sur place, écran tactile en mode kiosque).
//   - click_collect_terminal → terminal du personnel, 2 modes :
//                               "Réception" (écran cuisine : TOUTES les
//                               commandes app + bornes en direct, alarme,
//                               calendrier de l'historique) et "Borne"
//                               (exactement les mêmes écrans que
//                               click_collect_kiosk).
//
// Les écrans "borne" (attract/order_type/menu/checkout/ticket, dialogue
// d'options, pavé PIN) sont IDENTIQUES entre click_collect_kiosk et
// click_collect_terminal depuis le 01/10/2026 : on les modifie dans le
// terminal puis on recopie dans le kiosk. Seuls diffèrent : main.dart,
// attract_screen.dart (le kiosk n'a pas de mode Réception →
// StaffPanelScreen() sans paramètre), staff_panel_screen.dart (pas de
// bascule de mode dans le kiosk), data/orders_repository.dart (le kiosk ne
// fait qu'écrire), firebase_options.dart, et tout ce qui est propre à la
// réception (reception_screen, order_calendar_screen, incoming_order,
// alert_service, staff_claim_service, terminal_mode, widgets/order_card).
//
// Toutes les 3 apps + les Cloud Functions vivent sur le même projet
// Firebase : "les-poulets-de-mamie" (compte contact.isnad.app@gmail.com).
//
// Stack commun : Flutter + Firebase (firebase_core, cloud_firestore,
// firebase_auth, cloud_functions), google_fonts, flutter_stripe ^14.0.0
// (paiement carte — les 3 apps depuis le 01/10/2026). Kiosk + terminal :
// wakelock_plus + window_manager (mode kiosque) ; terminal : audioplayers
// (alarme sonore).
//
// Design system : "Feu de Bois" (depuis le 01/10/2026, remplace "Braise
// Dorée"). Voir lib/theme/app_theme.dart + lib/widgets/ui.dart dans
// chaque projet :
//   - Couleurs (AppColors) : braise #F28C38 (= `orange`, action/CTA, reprise
//     du logo), or miel #F6C35B (= `honey`, réservé à la fidélité), encre
//     fumée #120D09 (= `charcoal`), crème #FFF4E6, verre fumé
//     (`glass` / `glassStrong` / `glassBorder`) pour les cartes.
//   - Polices : Fraunces (titres, serif chaleureux) + Plus Jakarta Sans
//     (texte), via google_fonts.
//   - Fond : photo assets/images/fond_flou.jpg (fond.jpg PRÉ-FLOUTÉ et
//     assombri à l'export — aucun flou calculé à l'exécution) + voile
//     dégradé + lueur braise, posé sous CHAQUE page par
//     BackdropPageTransitionsBuilder (pageTransitionsTheme) → chaque page
//     est opaque, pas de "fantôme" pendant les transitions. Les Scaffold
//     sont donc transparents (scaffoldBackgroundColor: transparent).
//   - Composants partagés (widgets/ui.dart, identique dans les 3 apps sauf
//     la hauteur par défaut de GlowButton) : GlassCard, GlowButton (CTA en
//     dégradé braise avec halo), Pressable (enfoncement au toucher),
//     Eyebrow, SectionHeader, StatusPill, IconBadge, BrandSeal (logo dans
//     un anneau), FadeSlideIn (apparition en cascade, sans Timer),
//     CountUpText, EmptyState.
//   - Kiosk/terminal : mêmes couleurs, tailles agrandies (kKioskTapHeight =
//     64), KioskScrollBehavior (défilement à la souris aussi), et
//     KioskConfig.ambientAnimations (animations d'ambiance en boucle de
//     l'écran d'accueil borne — mis à false dans les tests, sinon
//     pumpAndSettle ne finit jamais).
//
// EN LIGNE (Firebase Hosting, même projet → les 3 apps restent reliées
// par Firestore) — version web de TEST :
//   - App client  : https://les-poulets-de-mamie.web.app
//   - Borne       : https://poulets-de-mamie-borne.web.app
//   - Terminal    : https://poulets-de-mamie-terminal.web.app
// Déploiement : dans chaque dossier, `flutter build web --release
// --no-tree-shake-icons` puis `firebase deploy --only hosting --project
// les-poulets-de-mamie` (kiosk/terminal ont leur "site" dans firebase.json).
// Différences web : pas de paiement carte (le PaymentSheet Stripe n'existe
// pas sur le web) → app "payer sur place", bornes "payer en caisse". Le
// terminal web demande le code équipe à l'ouverture (droits staff + bip de
// test qui autorise le son dans le navigateur — _WebReceptionGate dans
// main.dart). ⚠️ Le code équipe (1957) est dans le code de la page :
// suffisant pour des tests entre amis, à durcir avant une vraie mise en
// service (sinon quiconque a le lien et lit le code peut voir les commandes
// et numéros de téléphone).
//
// GitHub (compte braza7458, branche main, collaborateur Ryad) :
//   - https://github.com/braza7458/click_collect_app
//   - https://github.com/braza7458/click_collect_terminal
//   - https://github.com/braza7458/click_collect_kiosk
//
// =====================================================================
// 2. ÉTAT ACTUEL — click_collect_app (app cliente)
// =====================================================================
//
// Écrans (lib/screens/) :
//   - welcome_screen.dart       → accueil avant connexion : photo nette
//                                 (fond.jpg) fondue dans le fond flouté,
//                                 logo, "Bienvenue chez Les Poulets de
//                                 Mamie", boutons "Connexion / Inscription"
//                                 et "Continuer en tant qu'invité".
//   - login_screen.dart, signup_step1_screen.dart, signup_step2_screen.dart
//                               → compte = pseudo + mot de passe UNIQUEMENT
//                                 (pseudoEmailFor() dans state/app_state.dart
//                                 fabrique une fausse adresse pour Firebase
//                                 Auth). Après inscription → directement
//                                 loyalty_intro_screen.dart ("Bienvenue dans
//                                 le club !") — plus d'étape "restaurant
//                                 favori" (restaurant unique).
//   - dashboard_shell.dart      → barre de navigation flottante en verre,
//                                 5 onglets : Pour vous / Restaurant /
//                                 Commander (badge = nb d'articles du
//                                 panier) / Fidélité / Plus (point si
//                                 notifications non lues).
//   - tabs/home_tab.dart        → "Pour vous" : salutation + logo ; bouton
//                                 "Me connecter" (invité → LoginScreen) OU
//                                 "Mon identifiant" (connecté → carte membre
//                                 QR) ; grande carte ouvert/fermé EN DIRECT
//                                 calculée depuis les horaires ("Fermé ·
//                                 ouvre à 18h", horaires du jour, adresse,
//                                 bouton Commander) ; bandeau points fidélité
//                                 (connecté) ; carrousel "Les
//                                 incontournables" avec les photos
//                                 tasty_cheddar.jpg et tajine.jpg ;
//                                 "Événements à venir" (liste _events VIDE →
//                                 état "Rien de prévu pour l'instant" ; pour
//                                 annoncer un événement, ajouter une entrée à
//                                 _UpcomingEvents._events) ; raccourcis Carte
//                                 / Aide.
//   - tabs/restaurant_tab.dart  → "Restaurant" (remplace l'ancienne liste
//                                 restaurants_tab.dart) : photo, statut en
//                                 direct, adresse, téléphone, boutons
//                                 Appeler / Itinéraire, horaires de la
//                                 semaine (jour courant surligné, jours
//                                 fermés en rouge), services, et la carte
//                                 papier (menu.jpeg) zoomable en plein écran.
//   - tabs/order_tab.dart       → la carte : puces de catégories (avec
//                                 icônes), plats avec photo quand on en a
//                                 une (widgets/menu_visuals.dart :
//                                 poulet.jpg pour les poulets rôtis,
//                                 tasty_cheddar.jpg, tajine.jpg ; sinon
//                                 l'icône de la catégorie), barre "Voir le
//                                 panier" animée.
//   - widgets/item_options_sheet.dart → fiche plat : grande photo, tailles
//                                 M/L en grosses cartes, suppléments en
//                                 puces, quantité, bouton "Ajouter · X €".
//   - tabs/fidelity_tab.dart    → carte membre façon carte premium (or miel,
//                                 points qui "comptent", progression),
//                                 "comment ça marche", récompenses avec
//                                 barre de progression, dernières commandes.
//                                 Invité → écran d'invitation à créer un
//                                 compte.
//   - tabs/more_tab.dart        → "Mon espace" : carte profil, Mes
//                                 commandes, Notifications, Mon profil,
//                                 Appeler le restaurant, Aide, CGU,
//                                 confidentialité, déconnexion.
//   - cart_screen.dart          → panier : lignes avec stepper, mode
//                                 (Click & Collect / Livraison / Service à
//                                 table), créneaux de retrait PROPOSÉS
//                                 UNIQUEMENT pendant les heures d'ouverture
//                                 (toutes les 15 min, ≥ 20 min à l'avance,
//                                 groupés par jour) + "Autre heure" vérifiée
//                                 contre les horaires ; livraison/table
//                                 seulement si ouvert ; téléphone pour SMS ;
//                                 récompense fidélité ; total ; message qui
//                                 dit ce qui manque pour commander.
//   - stripe_checkout_screen.dart → paiement carte natif (PaymentSheet),
//                                 récap façon ticket.
//   - order_confirmation_screen.dart → coche animée + SUIVI EN DIRECT
//                                 (frise En préparation → Prête →
//                                 Récupérée, mise à jour quand le terminal
//                                 change le statut).
//   - order_history_screen.dart → "Mes commandes" : flux Firestore EN DIRECT
//                                 (statut à jour), tirer pour actualiser,
//                                 frise de suivi pour les commandes en cours.
//                                 Marche aussi pour un invité (ses commandes
//                                 portent l'uid de sa session anonyme).
//   - profile_screen.dart, notifications_screen.dart, legal/* → inchangés
//                                 sur le fond (style mis à jour).
//   - widgets/help_dialog.dart  → feuille "Besoin d'aide ?" : 07 61 85 18 31,
//                                 statut ouvert/fermé, bouton Appeler.
//   - services/contact.dart     → callRestaurant() (tel:) et openItinerary()
//                                 (Google Maps). AndroidManifest déclare les
//                                 <queries> tel + https.
//   - web_checkout_screen.dart, services/web_stripe_checkout.dart →
//                                 paiement web ABANDONNÉ (orphelins, voir 6).
//
// État / données (lib/state/, lib/data/) :
//   - state/app_state.dart      → state global (AppStateScope.of(context)).
//                                 `restaurant` (RestaurantLocation unique,
//                                 valeur par défaut RestaurantLocation.artix
//                                 remplacée par Firestore si dispo) ;
//                                 loadCatalog() charge menu / restaurant /
//                                 récompenses INDÉPENDAMMENT (un échec n'efface
//                                 pas les autres) ; refreshOrders().
//                                 favoriteRestaurantName / setFavoriteRestaurant
//                                 SUPPRIMÉS (restaurant unique).
//   - data/restaurant_data.dart → RestaurantLocation {name, address, phone,
//                                 schedule} ; schedule = 7 listes de
//                                 OpeningSlot (lundi → dimanche, minutes
//                                 depuis minuit). Calcule isOpenNow,
//                                 statusAt() ("Ouvert / Ferme bientôt /
//                                 Fermé" + "jusqu'à 14h30" / "ouvre mercredi
//                                 à 9h30"), nextOpening(), pickupSlots(),
//                                 acceptsPickupAt(). fromMap() renvoie null
//                                 pour les vieux documents sans `schedule`.
//   - data/catalog_repository.dart → fetchMenu(), fetchRestaurant() (premier
//                                 document au nouveau format, sinon .artix),
//                                 fetchRewardTiers().
//   - data/orders_repository.dart → submitOrder(), fetchOrdersForUser(),
//                                 watchOrdersForUser() — requête sur userId
//                                 SEUL, tri par date côté client (plus
//                                 besoin d'index composite).
//   - data/menu_data.dart       → MenuCategory a maintenant `iconKey` (champ
//                                 `icon` des documents, partagé avec la borne).
//
// Assets (pubspec.yaml) : logo.jpg, menu.jpeg, fond.jpg, fond_flou.jpg
// (généré depuis fond.jpg : 540 px, flou gaussien 18, luminosité 0,55),
// tasty_cheddar.jpg, tajine.jpg (photos fournies par le restaurant) et
// assets/images/produits/ : 18 photos de plats GÉNÉRÉES AVEC GEMINI
// (gemini-3-pro-image-preview, 640×640, même style : table en bois sombre,
// lumière chaude) — poulet_roti, demi_poulet, cuisse_dinde, formule_quart,
// bowl_tandoori, bowl_curry_coco, crousty_tenders, sup_cheddar, sup_oignons,
// sup_tenders, sup_poulet_marine, barquette, haricots_pdt, frites,
// riz_pilaf, couscous, tiramisu, canette. Le lien nom du plat → photo est
// dans menuItemImage() (widgets/menu_visuals.dart ici, widgets/menu_icons.dart
// dans le kiosk et le terminal — même liste de mots-clés, à garder
// synchronisée). Pour un nouveau plat : ajouter la photo dans produits/ des
// 3 apps + une ligne dans _productImages. Mêmes images dans les 3 apps.
//
// Comptes liés entre les 3 apps : un compte = pseudo + mot de passe Firebase
// Auth + users/{uid}. Les commandes passées sur la borne avec ce compte ont
// userId = uid (elles apparaissent dans "Mes commandes", OrderMode dineIn /
// takeaway, titre "Ticket borne n° X") ; les points gagnés sur la borne
// arrivent en direct dans l'app (AppState écoute users/{uid},
// UserRepository.watchProfile). Les commandes portent `customerName`
// (pseudo) pour que la réception affiche le client.
//
// Tests : test/widget_test.dart (6 tests : accueil, ajout au panier,
// paiement carte qui échoue proprement hors Firebase, commande sur place
// jusqu'à la confirmation, inscription, calcul des horaires).
//
// =====================================================================
// 3. ÉTAT ACTUEL — click_collect_terminal (terminal personnel)
// =====================================================================
//
// Mode Réception (écran par défaut) :
//   - screens/reception_screen.dart → en-tête (logo, "Commandes en direct",
//     point vert "en direct", horloge, bouton "Commandes" → calendrier,
//     Espace équipe), compteurs du jour (nb, chiffre, appli/borne), 3
//     colonnes Nouvelles / Prêtes / Terminées. Les 3 colonnes défilent de
//     la même façon (ListView + Scrollbar toujours visible + défilement
//     souris via KioskScrollBehavior). Carte de commande
//     (widgets/order_card.dart) : numéro ("N° 12" borne / "#K3F9A" appli),
//     badge BORNE/APPLI, chrono qui passe au orange (≥ 12 min) puis rouge
//     (≥ 25 min), lignes, récompense fidélité "À AJOUTER", Payée / À
//     encaisser, téléphone, total, gros bouton d'action. Alarme sonore +
//     cadre lumineux + bannière "Nouvelle commande ! / Désactiver".
//     ReceptionScreen accepte un `ordersStream` et un `calendarLoader`
//     injectables (tests + démo hors ligne tool/reception_demo.dart).
//   - screens/order_calendar_screen.dart → "Historique des commandes" :
//     calendrier mensuel (flèches, appui sur "Octobre 2026" → choix année/
//     mois), chaque jour affiche son nombre de commandes ("7 cdes") et
//     "chauffe" selon l'activité ; appui sur un jour → détail : nombre,
//     chiffre, appli/borne, payé en ligne, liste des commandes. Charge un
//     mois à la fois (OrdersRepository.fetchOrdersBetween : filtre sur la
//     chaîne ISO `date`, index simple automatique).
//   - data/orders_repository.dart → watchIncomingOrders() lit TOUTES les
//     commandes (plus de filtre source == 'app' : c'était le bug qui
//     empêchait les commandes de la borne d'apparaître en réception).
//   - models/incoming_order.dart → source (app/kiosk), ticketNumber,
//     displayNumber, libellés des modes app (clickCollect/delivery/
//     tableService) ET borne (dineIn → "Sur place", takeaway → "À
//     emporter").
//   - services/staff_claim_service.dart → claim `staff: true` (nécessaire
//     pour lire toutes les commandes et changer leur statut).
//
// Mode Borne : mêmes écrans que click_collect_kiosk (voir section 4).
//
// Config : lib/data/kiosk_config.dart → "Les Poulets de Mamie", "250 Rue
// du Galupe, 64170 Artix", restaurantPhone, PIN staff 1957, timeouts,
// ambientAnimations. Identique dans le kiosk.
//
// Identité Android : applicationId com.isnad.click_collect_terminal, app
// Firebase Android 1:524117961573:android:b3cc03d81a13e296d88f8c (depuis le
// 17/09/2026). Les blocs ios/macos/web/windows de firebase_options.dart
// pointent encore vers l'identité du kiosk.
//
// Tests : test/widget_test.dart (4 tests, écran 1280×800 : réception hors
// ligne, accueil borne, commande borne jusqu'au ticket, ET "les commandes
// borne apparaissent en réception à côté des commandes appli + le
// calendrier s'ouvre").
//
// =====================================================================
// 4. ÉTAT ACTUEL — click_collect_kiosk (borne self-service)
// =====================================================================
//
// À JOUR avec le mode Borne du terminal depuis le 01/10/2026 :
//   - attract_screen.dart → grande photo qui "respire" (zoom lent), logo,
//     "Les Poulets de Mamie", slogan, bouton pulsant "Touchez l'écran pour
//     commander", 2 plats mis en avant (Crousty Cheddar, Tajine) sur écran
//     large ; appui long sur l'adresse en bas → PIN → espace équipe.
//   - order_type_screen.dart → "Sur place ou à emporter ?" (2 grandes cartes).
//   - menu_screen.dart → rail de catégories, grille de plats avec photos,
//     panier à droite, "Valider ma commande".
//   - widgets/item_options_dialog.dart → photo, tailles, suppléments en
//     grandes cases, quantité.
//   - checkout_screen.dart → récap + champ téléphone "Prévenu par SMS"
//     (facultatif — la Cloud Function envoie le SMS confirmée/prête) +
//     PAIEMENT STRIPE sur la borne (carte / Apple Pay / Google Pay, même
//     compte Stripe et même Cloud Function createPaymentIntent que l'app)
//     OU "Payer en caisse".
//   - ticket_screen.dart → numéro géant, payé ou à régler en caisse,
//     compte à rebours avant retour à l'accueil.
//   - models/ticket.dart a le champ `paid`, KioskState.placeOrder(paid:).
//   - data/orders_repository.dart → submitTicket() écrit dans `orders` avec
//     source: 'kiosk', status: 'confirmed', paid → apparaît en direct dans
//     la réception du terminal (vérifié par test).
//   - Android : MainActivity = FlutterFragmentActivity, thèmes AppCompat,
//     dépendance androidx.appcompat, meta-data Google Pay (comme le
//     terminal) — nécessaires à flutter_stripe.
//   - tool/borne_demo.dart → démo hors ligne (carte fictive, sans Firebase).
//   - FIDÉLITÉ (depuis le 01/10/2026, 2e session) : services/loyalty_service.dart
//     connecte le client sur une SECONDE instance Firebase nommée "loyalty"
//     (la session anonyme de la borne reste intacte) avec les MÊMES comptes
//     que l'app (pseudoEmailFor identique), ou crée un compte. Le client se
//     connecte depuis le panier ("Compte fidélité : me connecter") ou le
//     récapitulatif (widgets/loyalty_dialog.dart : LoyaltyPanel), voit son
//     solde, gagne 1 point / € et peut échanger une récompense (rewardTiers).
//     KioskState.placeOrder écrit userId/customerName/pointsEarned/
//     appliedRewardLabel sur la commande puis met à jour users/{uid}.points
//     (transaction, délai max 8 s). Déconnexion automatique à la fin de la
//     commande (resetSession). Mêmes fichiers dans le mode Borne du terminal.
//   - PAIEMENT CORRIGÉ : initPaymentSheet recevait un paramètre applePay sans
//     Apple merchantIdentifier → assertion flutter_stripe, le formulaire ne
//     s'ouvrait jamais ("Le paiement a échoué"). Paramètre retiré, Link
//     masqué (LinkDisplay.never, aussi dans l'app), l'erreur réelle est
//     maintenant affichée et loguée. Vérifié sur émulateur Android : paiement
//     test 4242… réussi jusqu'au ticket.
//
// Tests : test/widget_test.dart (2 tests, écran 1280×800).
//
// =====================================================================
// 5. BACKEND FIREBASE (projet "les-poulets-de-mamie")
// =====================================================================
//
// -- Firestore — collections --
//   - menuCategories/{id}   → catalogue (lecture publique, écriture
//                             bloquée par les règles). Champs : title, icon,
//                             items[] (name, price, sizes[{label,price}],
//                             note, allowsSupplements, isAddOn, isInfoOnly,
//                             infoLabel), order.
//   - restaurants/{id}      → lecture publique, écriture bloquée. NOUVEAU
//                             FORMAT (tool/seed_firestore.dart) : name,
//                             address, phone, schedule[{day: 1..7, slots:
//                             [{open:'09:30', close:'14:30'}, ...]}], plus
//                             `hours` (texte résumé) et `isOpenNow` gardés
//                             uniquement pour les anciennes versions de
//                             l'app. ⚠️ VOIR PROCHAINE ÉTAPE #1 : pas
//                             encore poussé dans Firestore.
//   - rewardTiers/{id}      → paliers fidélité (points, label, icon).
//   - users/{uid}           → profil (username, points ; l'ancien champ
//                             favoriteRestaurantName n'est plus écrit).
//   - orders/{orderId}      → commandes app ET bornes. Champs : id, date
//                             (ISO 8601 string), mode, lines[], total,
//                             pointsEarned, restaurantName,
//                             fulfillmentDetail, status (confirmed/ready/
//                             completed), paid, userId, customerPhone,
//                             appliedRewardLabel, source ('app' | 'kiosk'),
//                             number (borne uniquement). Règles :
//                             création par tout authentifié ; lecture par
//                             le propriétaire ou un terminal staff ;
//                             modification du seul `status` par un
//                             terminal staff.
//
// -- Index (firestore.indexes.json) --
//   orders (source ASC, date DESC) — plus utilisé par le code mais
//   inoffensif. Aucun index composite n'est nécessaire au code actuel.
//
// -- Cloud Functions (functions/index.js, Node 20, gen2) --
//   - claimStaffTerminal (onCall) → claim staff:true (code STAFF_SETUP_CODE
//     "1957", synchro avec KioskConfig.staffPin).
//   - createPaymentIntent (onCall, secret STRIPE_SECRET_KEY) → carte
//     uniquement. Utilisée par l'app, le terminal (borne) ET le kiosk.
//   - onOrderCreatedSendConfirmationSms / onOrderReadySendSms (Brevo,
//     expéditeur "PouletMamie") → s'appliquent à TOUTES les commandes
//     (app et bornes) qui ont un customerPhone.
//
// -- SMS (Brevo) --
//   Crédits SMS payants séparés de l'abonnement email (~5 centimes/SMS).
//   Fonctionnel depuis le 16/09/2026.
//
// =====================================================================
// 6. PAIEMENT (Stripe)
// =====================================================================
//
// Chemin actif : PaymentSheet natif (flutter_stripe) dans l'app
// (stripe_checkout_screen.dart, carte uniquement, sans champ pays) et dans
// les bornes (checkout_screen.dart du terminal et du kiosk, carte + Apple
// Pay / Google Pay selon l'appareil). Clé publique de test par défaut
// (StripeConfig, surchargeable par --dart-define=STRIPE_PUBLISHABLE_KEY).
//
// ABANDONNÉ (ne pas reprendre sauf demande explicite) : paiement WEB Apple
// Pay/Google Pay via Stripe.js — fichiers orphelins web_checkout_screen.dart,
// services/web_stripe_checkout.dart, web/poulets_stripe.js.
//
// =====================================================================
// 7. HISTORIQUE DES SESSIONS (la plus récente en premier)
// =====================================================================
//
// --- 01/10/2026 (3e session) ---
// - Les 3 apps mises en ligne (voir liens section 1). Lien testé EN LIGNE :
//   commande passée sur la borne web → apparue sur le terminal avec
//   l'alarme (2 fois). App web : même écriture Firestore que l'app Android
//   (non testée en commande réelle car elle exige un vrai numéro et
//   enverrait un SMS).
// - Terminal : fausse alarme au démarrage corrigée (le cache local arrivait
//   avant le serveur) ; numéro de commande qui ne rétrécit plus.
// - ⚠️ 2 commandes de TEST "Le Demi-Poulet" (borne, 11,50 €) ajoutées dans
//   Firestore pendant le test : à passer en "Récupérée".
//
// --- 01/10/2026 (2e session) ---
// - 18 photos de plats générées avec Gemini et installées dans les 3 apps
//   (carte, fiche plat, suppléments).
// - Fidélité sur la borne (et le mode Borne du terminal), mêmes comptes que
//   l'app ; points synchronisés en direct dans l'app ; commandes borne du
//   client dans "Mes commandes" ; pseudo du client affiché en réception.
// - Paiement de la borne réparé (paramètre Apple Pay fautif, voir section 4)
//   et testé sur émulateur. ⚠️ Ce test a créé une vraie commande de TEST
//   dans Firestore (ticket borne n° 1, 20,50 €, payée en mode test Stripe) :
//   la passer en "Récupérée" depuis la réception.
// - Petits débordements corrigés sur les écrans de borne de petite taille.
//
// --- 01/10/2026 ---
// - Les 11 tâches de la session du 17/09 implémentées (app 1 à 9,
//   terminal 1 et 2) — détail dans les sections 2 et 3 :
//   app 1 "Me connecter" pour l'invité / "Mon identifiant" connecté ;
//   app 2 images Tasty Cheddar + Tajine sur l'accueil ; app 3 restaurant
//   unique 250 Rue du Galupe / 07 61 85 18 31 partout (app, kiosk,
//   terminal, CGU) ; app 4 horaires par jour (lundi/mardi fermés,
//   mer→sam 9h30–14h30 + 18h–21h, dim 9h30–14h30) avec statut
//   ouvert/fermé en direct et créneaux de retrait limités aux heures
//   d'ouverture ; app 5 "Événements à venir" sans faux événements ; app 6
//   Crousty Cheddar M 8,50 € / L 10,00 € (seed — voir PROCHAINE ÉTAPE #1) ;
//   app 7 "Mes commandes" réparé (cause : requête userId + orderBy(date)
//   sans index composite, erreur avalée → requête sur userId seul + tri
//   côté client) et passé en direct ; app 8 numéro d'aide 07 61 85 18 31 ;
//   app 9 fond photo flouté sur toute l'app. Terminal 1 bouton
//   "Commandes" → calendrier ; terminal 2 colonnes toutes défilantes
//   (barre visible + défilement souris).
// - BUG CORRIGÉ "borne pas reliée au terminal" : la réception filtrait
//   `source == 'app'`, donc les commandes de la borne (source 'kiosk')
//   n'apparaissaient jamais. Filtre retiré, modes de la borne traduits,
//   badge BORNE/APPLI, test automatique ajouté.
// - Kiosk mis à jour : paiement Stripe sur la borne, Ticket.paid,
//   tous les écrans borne alignés sur le terminal, config Android Stripe.
// - Refonte visuelle complète des 3 apps : design system "Feu de Bois"
//   (voir section 1). Vérifié visuellement en version web (app mobile 375
//   px, réception + calendrier et borne 1280×800 via les démos hors ligne).
// - Démos hors ligne ajoutées (aucune donnée réelle touchée) :
//   click_collect_terminal/tool/reception_demo.dart et
//   click_collect_kiosk/tool/borne_demo.dart.
// - `flutter analyze` propre et tous les tests verts sur les 3 apps ;
//   `flutter build apk --debug` du kiosk vérifié (config Stripe Android).
//
// --- 17/09/2026 ---
// - Terminal et kiosk partageaient le même applicationId Android → corrigé
//   (terminal = com.isnad.click_collect_terminal + nouvelle app Firebase).
// - Création de ce log.dart ; 11 tâches consignées (sans les coder, à la
//   demande d'Ibrahim) ; mise sur GitHub des 3 dossiers + collaborateur Ryad.
//
// --- 16/09/2026 ---
// - Stripe carte uniquement ; champ "Pays/région" retiré ; alarme du
//   terminal 5 min + bouton "Désactiver" ; SMS réparés (redéploiement des
//   fonctions + crédits Brevo) ; paiement web Apple/Google Pay abandonné ;
//   correction du build Android cassé par des imports web-only.
//
// --- Sessions antérieures (résumé) ---
// - Backend Firebase complet (Auth, Firestore, Functions), design "Braise
//   Dorée", parcours connexion/inscription/fidélité/panier/historique,
//   Stripe natif, construction du kiosk et du terminal.
//
// =====================================================================
// 8. PROCHAINE ÉTAPE — À FAIRE
// =====================================================================
//
// 1) POUSSER LES NOUVELLES DONNÉES DANS FIRESTORE (pas encore fait) :
//    tool/seed_firestore.dart contient le restaurant unique (adresse,
//    téléphone, horaires `schedule`) et le Crousty Cheddar M 8,50 € /
//    L 10,00 €, et supprime restaurants/restaurant-1 et restaurant-2. Les
//    règles Firestore interdisent l'écriture du catalogue depuis un client,
//    donc il faut SOIT un jeton OAuth d'un propriétaire du projet dans
//    FIRESTORE_TOKEN, SOIT ouvrir temporairement l'écriture sur
//    menuCategories/restaurants/rewardTiers dans firestore.rules
//    (`firebase deploy --only firestore:rules`), lancer
//    `dart run tool/seed_firestore.dart`, puis remettre les règles.
//    En attendant : l'app affiche déjà le bon restaurant et les bons
//    horaires (valeur intégrée RestaurantLocation.artix, utilisée tant que
//    Firestore n'a pas le nouveau format), MAIS le Crousty Cheddar reste
//    "Prix à définir" (non commandable) dans l'app et les bornes tant que
//    menuCategories n'est pas mis à jour.
// 2) Fidélité borne à tester avec un vrai compte sur la tablette (connexion,
//    points gagnés, récompense, puis vérifier dans l'app "Mes commandes" et
//    le solde). Pas testable par Claude (il ne saisit pas de mots de passe).
// 2 bis) Tester sur les vrais appareils : app Android (fond, horaires,
//    "Mes commandes" en direct), terminal en mode Réception (une commande
//    passée sur la borne doit sonner et apparaître avec le badge BORNE),
//    paiement Stripe sur la borne.
// 3) Les numéros de ticket borne repartent de 1 chaque jour sur CHAQUE
//    appareil (compteur local) : si le kiosk ET le terminal en mode Borne
//    servent le même jour, deux tickets peuvent avoir le même numéro. À
//    traiter si les deux sont utilisés en même temps (compteur partagé
//    dans Firestore, ou préfixe par appareil).
// 4) Politique de confidentialité (legal/privacy_screen.dart) : le texte
//    parle encore d'e-mail, date de naissance et restaurant favori, alors
//    que les comptes n'ont qu'un pseudo + mot de passe — à réécrire (et à
//    faire valider par un juriste, comme indiqué dans l'écran).
//
// =====================================================================
// FIN DU LOG — rappel : mets-le à jour avant de terminer ta session.
// =====================================================================
