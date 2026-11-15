import 'package:flutter/material.dart';

import '../config.dart';
import '../textos.dart';
import 'catalogo_screen.dart';
import 'favoritos_screen.dart';

/// Sustituye a MainActivity + BottomNavigationView + mobile_navigation.xml.
/// Cada pestaña era un Fragment; aquí es un widget que se cambia según el índice.
class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  int _pestana = 0;

  @override
  Widget build(BuildContext context) {
    // Igual que los Fragments, la pestaña se vuelve a crear al seleccionarla,
    // así Favoritos se recarga cada vez que se entra (antes, onResume()).
    final Widget cuerpo = switch (_pestana) {
      0 => const CatalogoScreen(key: ValueKey('peliculas'), esSeries: false),
      1 => const CatalogoScreen(key: ValueKey('series'), esSeries: true),
      _ => const FavoritosScreen(),
    };

    return Scaffold(
      body: SafeArea(child: cuerpo),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colores.fondoOscuro,
        selectedIndex: _pestana,
        onDestinationSelected: (i) => setState(() => _pestana = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.movie), label: Textos.peliculas),
          NavigationDestination(icon: const Icon(Icons.tv), label: Textos.series),
          NavigationDestination(icon: const Icon(Icons.favorite), label: Textos.favoritos),
        ],
      ),
    );
  }
}
