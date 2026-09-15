import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ClickCollectApp());
}

class ClickCollectApp extends StatelessWidget {
  const ClickCollectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Les Poulets de Mamie',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const HomeScreen(),
    );
  }
}
