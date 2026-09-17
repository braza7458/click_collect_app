import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'config/stripe_config.dart';
import 'firebase_options.dart';
import 'screens/dashboard_shell.dart';
import 'screens/welcome_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (StripeConfig.isConfigured) {
    Stripe.publishableKey = StripeConfig.publishableKey;
    await Stripe.instance.applySettings();
  }
  runApp(const ClickCollectApp());
}

class ClickCollectApp extends StatefulWidget {
  /// [appState] lets tests inject a pre-seeded state (e.g. with a menu
  /// already set) instead of hitting the real Firestore backend.
  const ClickCollectApp({super.key, AppState? appState}) : _injectedState = appState;

  final AppState? _injectedState;

  @override
  State<ClickCollectApp> createState() => _ClickCollectAppState();
}

class _ClickCollectAppState extends State<ClickCollectApp> {
  late final _appState = widget._injectedState ?? AppState();
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    // Restores the locally saved session (login, points, cart…) and the
    // shared catalog before deciding which screen to open on.
    Future.wait([_appState.load(), _appState.loadCatalog()]).then((_) {
      if (mounted) setState(() => _loaded = true);
    });
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      state: _appState,
      child: MaterialApp(
        title: 'Les Poulets de Mamie',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: !_loaded
            ? const _SplashScreen()
            : (_appState.isLoggedIn || _appState.isGuest)
                ? const DashboardShell()
                : const WelcomeScreen(),
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
