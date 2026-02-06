import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/layout_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Platform (dart:io) ay hindi supported sa web — check muna kIsWeb
  if (!kIsWeb && Platform.isAndroid) {
    // Fullscreen sa Android: walang status bar at navigation bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
  } else {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF01081A),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }
  runApp(const AppCageApp());
}

class AppCageApp extends StatelessWidget {
  const AppCageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Infinity Cage X',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const LayoutScreen(),
    );
  }
}
