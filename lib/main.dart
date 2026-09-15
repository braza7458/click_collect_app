import 'package:flutter/material.dart';

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
        home: const WelcomeScreen(),
      ),
    );
  }
}
