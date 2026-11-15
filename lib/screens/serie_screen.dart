import 'package:flutter/material.dart';

import '../config.dart';
import '../data/favoritos_db.dart';
import '../models/modelos.dart';
import '../navegacion.dart';
import '../services/tmdb_service.dart';
import '../textos.dart';
import '../widgets/comunes.dart';
import '../widgets/ficha_detalle.dart';
import '../widgets/tarjeta_media.dart';

/// Sustituye a SerieActivity.
class SerieScreen extends StatefulWidget {
  final int idSerie;

  const SerieScreen({super.key, required this.idSerie});

  @override
  State<SerieScreen> createState() => _SerieScreenState();
}

class _SerieScreenState extends State<SerieScreen> {
  final _api = TmdbService.instancia;
  final _db = FavoritosDb.instancia;

  late Future<Serie> _serie;
  late Future<List<Persona>> _reparto;
  late Future<List<Serie>> _similares;
  late Future<String?> _trailer;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() {
    final id = widget.idSerie;
    _serie = _api.serie(id);
    _reparto = _api.repartoSerie(id);
    _similares = _api.seriesSimilares(id);
    _trailer = _buscarTrailer(id);
  }

  /// En series el original aceptaba cualquier vídeo de YouTube (no solo "Trailer").
  Future<String?> _buscarTrailer(int id) async {
    try {
      final videos = await _api.trailersSerie(id);
      for (final v in videos) {
        if (v.sitio == 'YouTube') return v.urlYoutube;
      }
    } catch (e) {
      debugPrint('Error al cargar tráileres: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Serie>(
      future: _serie,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(backgroundColor: Colores.fondoOscuro),
            body: CargaFutura<Serie>(
              futuro: _serie,
              reintentar: () => setState(_cargar),
              constructor: (_) => const SizedBox.shrink(),
            ),
          );
        }
        final s = snapshot.data!;
        return FichaDetalle(
          urlImagen: Config.imagen(s.poster),
          asetSinFoto: 'assets/images/sin_foto_serie.png',
          accion: BotonFavorito(
            comprobar: () => _db.esSerieFavorita(s.id),
            cambiar: (fav) => fav ? _db.agregarSerie(s.id) : _db.borrarSerie(s.id),
          ),
          contenido: [
            TituloFicha(titulo: s.nombre, valoracion: s.valoracion),
            BotonTrailer(urlTrailer: _trailer),
            TextoLargo(s.descripcion),
            FilaDato(etiqueta: Textos.temporadas, valor: '${s.temporadas ?? ''}'),
            FilaDato(etiqueta: Textos.episodios, valor: '${s.episodios ?? ''}'),
            FilaDato(etiqueta: Textos.estado, valor: s.estado),
            CargaFutura<List<Persona>>(
              futuro: _reparto,
              constructor: (reparto) => SeccionHorizontal<Persona>(
                titulo: Textos.reparto,
                alto: 160,
                elementos: reparto,
                constructor: (persona) => TarjetaPersona(
                  nombre: persona.nombre,
                  urlFoto: Config.imagen(persona.foto),
                  onTap: () => abrirActor(context, persona.id),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // El original solo mostraba la primera cadena y el primer género
            // (y fallaba si la lista venía vacía). Aquí se muestran todos.
            FilaDato(etiqueta: Textos.estudio, valor: s.cadenas.join('\n')),
            FilaDato(etiqueta: Textos.genero, valor: s.generos.join('\n')),
            FilaDato(etiqueta: Textos.lanzamiento, valor: s.primeraEmision),
            CargaFutura<List<Serie>>(
              futuro: _similares,
              constructor: (similares) => SeccionHorizontal<ElementoMedia>(
                titulo: Textos.seriesSimilares,
                elementos: similares.map((x) => x.comoElemento).toList(),
                constructor: (e) => TarjetaMedia(elemento: e),
              ),
            ),
          ],
        );
      },
    );
  }
}
