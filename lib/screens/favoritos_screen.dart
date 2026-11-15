import 'package:flutter/material.dart';

import '../config.dart';
import '../data/favoritos_db.dart';
import '../models/modelos.dart';
import '../services/tmdb_service.dart';
import '../textos.dart';
import '../widgets/comunes.dart';
import '../widgets/tarjeta_media.dart';

/// Sustituye a FavoritosFragment. Lee los ids guardados en SQLite y pide a la
/// API los datos de cada uno.
class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({super.key});

  @override
  State<FavoritosScreen> createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {
  late Future<List<ElementoMedia>> _series;
  late Future<List<ElementoMedia>> _peliculas;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() {
    _series = _cargarSeries();
    _peliculas = _cargarPeliculas();
  }

  // En el original se encolaba una llamada por id y se iban añadiendo a la lista
  // según llegaban. Aquí se lanzan todas a la vez y Future.wait espera a todas.
  Future<List<ElementoMedia>> _cargarSeries() async {
    final ids = await FavoritosDb.instancia.idsSeries();
    final series = await Future.wait(ids.map(TmdbService.instancia.serie));
    return series.map((s) => s.comoElemento).toList();
  }

  Future<List<ElementoMedia>> _cargarPeliculas() async {
    final ids = await FavoritosDb.instancia.idsPeliculas();
    final pelis = await Future.wait(ids.map(TmdbService.instancia.pelicula));
    return pelis.map((p) => p.comoElemento).toList();
  }

  /// Al volver de una ficha se recarga, por si se ha quitado o puesto un favorito.
  void _recargar() {
    if (mounted) setState(_cargar);
  }

  Widget _seccion(String titulo, Future<List<ElementoMedia>> futuro) {
    return CargaFutura<List<ElementoMedia>>(
      futuro: futuro,
      reintentar: _recargar,
      constructor: (lista) => lista.isEmpty
          ? Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Text(
                '$titulo\n${Textos.sinFavoritos}',
                style: const TextStyle(color: Colores.texto),
              ),
            )
          : SeccionHorizontal<ElementoMedia>(
              titulo: titulo,
              elementos: lista,
              constructor: (e) => TarjetaMedia(elemento: e, alVolver: _recargar),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
          child: Text(
            Textos.favoritosTitulo,
            style: const TextStyle(
              color: Colores.texto,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _seccion(Textos.seriesFavoritas, _series),
        _seccion(Textos.peliculasFavoritas, _peliculas),
      ],
    );
  }
}
