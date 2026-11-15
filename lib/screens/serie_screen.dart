import 'package:flutter/material.dart';

import '../config.dart';
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
    _reparto = _api.repartoSerie(id)..ignore();
    _similares = _api.seriesSimilares(id)..ignore();
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
          return FichaCargando(futuro: _serie, reintentar: () => setState(_cargar));
        }
        final s = snapshot.data!;
        final elemento = s.comoElemento;
        return FichaDetalle(
          titulo: s.nombre,
          urlFondo: Config.imagenFondo(s.fondo),
          urlPoster: Config.imagen(s.poster),
          asetSinFoto: 'assets/images/sin_foto_serie.png',
          datos: [
            elemento.anio,
            if (s.temporadas != null) Textos.temporadas(s.temporadas!),
          ],
          nota: s.votoMedio,
          votos: s.votos,
          etiquetas: s.generos,
          acciones: AccionesMedia(elemento: elemento, urlTrailer: _trailer),
          contenido: [
            if (s.descripcion.isNotEmpty) ...[
              TituloSeccion(Textos.sinopsis),
              TextoDesplegable(s.descripcion),
            ],
            CargaFutura<List<Persona>>(
              futuro: _reparto,
              constructor: (reparto) => SeccionHorizontal<Persona>(
                titulo: Textos.reparto,
                alto: 150,
                elementos: reparto.take(20).toList(),
                constructor: (persona) => TarjetaPersona(
                  nombre: persona.nombre,
                  personaje: persona.personaje,
                  urlFoto: Config.imagen(persona.foto),
                  onTap: () => abrirActor(context, persona.id),
                ),
              ),
            ),
            TituloSeccion(Textos.detalles),
            // El original solo mostraba la primera cadena y el primer género
            // (y fallaba si la lista venía vacía). Aquí se muestran todos.
            FilaDato(etiqueta: Textos.cadena, valor: s.cadenas.join(', ')),
            FilaDato(etiqueta: Textos.estado, valor: s.estado),
            FilaDato(
              etiqueta: Textos.capitulos,
              valor: [
                if (s.temporadas != null) Textos.temporadas(s.temporadas!),
                if (s.episodios != null) Textos.episodios(s.episodios!),
              ].join(' · '),
            ),
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
