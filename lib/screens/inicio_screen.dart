import 'package:flutter/material.dart';

import '../textos.dart';
import '../widgets/barra_navegacion.dart';
import 'catalogo_screen.dart';
import 'mis_listas_screen.dart';

/// Sustituye a MainActivity + BottomNavigationView + mobile_navigation.xml.
class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  int _pestana = 0;

  // Las pantallas se crean una vez y se conservan (IndexedStack), así al cambiar
  // de pestaña no se pierde la posición ni se vuelve a descargar todo.
  // Mis listas se actualiza sola cuando cambia la base de datos.
  static const _pantallas = [
    CatalogoScreen(esSeries: false),
    CatalogoScreen(esSeries: true),
    MisListasScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // El contenido pasa por debajo de la barra flotante
      extendBody: true,
      body: IndexedStack(index: _pestana, children: _pantallas),
      bottomNavigationBar: BarraNavegacion(
        seleccionado: _pestana,
        alSeleccionar: (i) => setState(() => _pestana = i),
        destinos: [
          DestinoBarra(
            icono: Icons.movie_outlined,
            iconoActivo: Icons.movie_rounded,
            etiqueta: Textos.peliculas,
          ),
          DestinoBarra(
            icono: Icons.live_tv_outlined,
            iconoActivo: Icons.live_tv_rounded,
            etiqueta: Textos.series,
          ),
          DestinoBarra(
            icono: Icons.bookmarks_outlined,
            iconoActivo: Icons.bookmarks_rounded,
            etiqueta: Textos.misListas,
          ),
        ],
      ),
    );
  }
}
