import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'generated/app_localizations.dart';
import 'platform_init_stub.dart' if (dart.library.io) 'platform_init_io.dart' as platform_init;
import 'screens/layout_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) await platform_init.initAndroidIfNeeded();
  if (kIsWeb || !platform_init.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: surfaceColor,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }
  runApp(const AppCageApp());
}

class AppLocaleScope extends InheritedWidget {
  const AppLocaleScope({
    super.key,
    required this.locale,
    required this.setLocale,
    required super.child,
  });

  final Locale? locale;
  final void Function(Locale?) setLocale;

  static AppLocaleScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppLocaleScope>();
    assert(scope != null, 'AppLocaleScope not found');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppLocaleScope old) =>
      locale != old.locale;
}

class AppCageApp extends StatefulWidget {
  const AppCageApp({super.key});

  @override
  State<AppCageApp> createState() => _AppCageAppState();
}

class _AppCageAppState extends State<AppCageApp> {
  Locale? _locale = const Locale('ko');

  void _setLocale(Locale? locale) {
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return AppLocaleScope(
      locale: _locale,
      setLocale: _setLocale,
      child: MaterialApp(
        title: 'Infinity Cage X',
        debugShowCheckedModeBanner: false,
        theme: appTheme,
        locale: _locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        localeResolutionCallback: (locale, supported) {
          for (final s in supported) {
            if (s.languageCode == locale?.languageCode) return s;
          }
          return const Locale('ko');
        },
        home: const LayoutScreen(),
      ),
    );
  }
}
