import 'package:flutter/material.dart';

import 'screens/dashboard_shell.dart';
import 'screens/welcome_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ClickCollectApp());
}

class ClickCollectApp extends StatefulWidget {
  const ClickCollectApp({super.key});

  @override
  State<ClickCollectApp> createState() => _ClickCollectAppState();
}

class _ClickCollectAppState extends State<ClickCollectApp> {
  final _appState = AppState();
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    // Restores the locally saved session (login, points, cart…) before
    // deciding whether to open on the welcome screen or the dashboard.
    _appState.load().then((_) {
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
