import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'config.dart';
import 'screens/inicio_screen.dart';

void main() {
  // En el navegador sqflite necesita la versión web (WebAssembly)
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }
  runApp(const PeliculeitorApp());
}

class PeliculeitorApp extends StatelessWidget {
  const PeliculeitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final esquema = ColorScheme.fromSeed(
      seedColor: Colores.acento,
      brightness: Brightness.dark,
    ).copyWith(
      primary: Colores.acento,
      onPrimary: Colores.fondo,
      surface: Colores.fondo,
      onSurface: Colores.texto,
    );

    return MaterialApp(
      title: 'Peliculeitor',
      debugShowCheckedModeBanner: false,
      // Sustituye a styles.xml / colors.xml
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: esquema,
        scaffoldBackgroundColor: Colores.fondo,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colores.fondo,
          foregroundColor: Colores.texto,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colores.superficieAlta,
          contentTextStyle: const TextStyle(color: Colores.texto),
          actionTextColor: Colores.acento,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(color: Colores.acento),
      ),
      home: const SplashScreen(),
    );
  }
}

/// Sustituye a SplashActivity: muestra el logo 1 segundo y pasa a la pantalla
/// principal sin dejar el splash en la pila (como hacía finish()).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => const InicioScreen(),
        transitionsBuilder: (_, animacion, __, hijo) =>
            FadeTransition(opacity: animacion, child: hijo),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colores.fondo,
      body: Center(
        // Entra con un pequeño zoom y fundido
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (context, valor, hijo) => Opacity(
            opacity: valor,
            child: Transform.scale(scale: 0.85 + 0.15 * valor, child: hijo),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 140,
                height: 140,
                semanticLabel: 'Peliculeitor',
              ),
              const SizedBox(height: 24),
              const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'Pelicul'),
                    TextSpan(text: 'eitor', style: TextStyle(color: Colores.acento)),
                  ],
                ),
                style: TextStyle(
                  color: Colores.texto,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
