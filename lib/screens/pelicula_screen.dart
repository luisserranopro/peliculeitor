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

/// Sustituye a PeliculaActivity.
class PeliculaScreen extends StatefulWidget {
  final int idPelicula; // antes: getIntent().getExtras().getInt("id")

  const PeliculaScreen({super.key, required this.idPelicula});

  @override
  State<PeliculaScreen> createState() => _PeliculaScreenState();
}

class _PeliculaScreenState extends State<PeliculaScreen> {
  final _api = TmdbService.instancia;
  final _db = FavoritosDb.instancia;

  late Future<Pelicula> _pelicula;
  late Future<List<Persona>> _reparto;
  late Future<List<Pelicula>> _similares;
  late Future<String?> _trailer;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() {
    final id = widget.idPelicula;
    // Las cuatro peticiones salen a la vez, como los cuatro enqueue() del original.
    _pelicula = _api.pelicula(id);
    _reparto = _api.repartoPelicula(id);
    _similares = _api.peliculasSimilares(id);
    _trailer = _buscarTrailer(id);
  }

  /// Primer vídeo de tipo "Trailer" alojado en YouTube, o null si no hay.
  Future<String?> _buscarTrailer(int id) async {
    try {
      final videos = await _api.trailersPelicula(id);
      for (final v in videos) {
        if (v.tipo == 'Trailer' && v.sitio == 'YouTube') return v.urlYoutube;
      }
    } catch (e) {
      debugPrint('Error al cargar tráileres: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Pelicula>(
      future: _pelicula,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(backgroundColor: Colores.fondoOscuro),
            body: CargaFutura<Pelicula>(
              futuro: _pelicula,
              reintentar: () => setState(_cargar),
              constructor: (_) => const SizedBox.shrink(),
            ),
          );
        }
        final p = snapshot.data!;
        return FichaDetalle(
          urlImagen: Config.imagen(p.poster),
          accion: BotonFavorito(
            comprobar: () => _db.esPeliculaFavorita(p.id),
            cambiar: (fav) => fav ? _db.agregarPelicula(p.id) : _db.borrarPelicula(p.id),
          ),
          contenido: [
            TituloFicha(titulo: p.titulo, valoracion: p.valoracion),
            BotonTrailer(urlTrailer: _trailer),
            TextoLargo(p.descripcion),
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
            FilaDato(etiqueta: Textos.estudio, valor: p.estudios.join('\n')),
            FilaDato(etiqueta: Textos.genero, valor: p.generos.join('\n')),
            FilaDato(etiqueta: Textos.lanzamiento, valor: p.fechaEstreno),
            CargaFutura<List<Pelicula>>(
              futuro: _similares,
              constructor: (similares) => SeccionHorizontal<ElementoMedia>(
                titulo: Textos.peliculasSimilares,
                elementos: similares.map((s) => s.comoElemento).toList(),
                constructor: (e) => TarjetaMedia(elemento: e),
              ),
            ),
          ],
        );
      },
    );
  }
}
