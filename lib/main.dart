import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'config.dart';
import 'screens/inicio_screen.dart';
import 'textos.dart';

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
    return MaterialApp(
      title: 'Peliculeitor',
      debugShowCheckedModeBanner: false,
      // Sustituye a styles.xml / colors.xml
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colores.fondo,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colores.primario,
          brightness: Brightness.dark,
          surface: Colores.fondo,
        ),
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
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const InicioScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colores.fondo,
      body: Center(
        child: Semantics(
          label: Textos.peliculas,
          child: Image.asset('assets/images/logo.png', width: 250, height: 250),
        ),
      ),
    );
  }
}
