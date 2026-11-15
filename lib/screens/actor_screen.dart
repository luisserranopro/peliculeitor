import 'package:flutter/material.dart';

import '../config.dart';
import '../models/modelos.dart';
import '../services/tmdb_service.dart';
import '../textos.dart';
import '../widgets/comunes.dart';
import '../widgets/ficha_detalle.dart';
import '../widgets/tarjeta_media.dart';

/// Sustituye a ActorActivity.
class ActorScreen extends StatefulWidget {
  final int idActor; // antes: getExtras().getInt("idPersona")

  const ActorScreen({super.key, required this.idActor});

  @override
  State<ActorScreen> createState() => _ActorScreenState();
}

class _ActorScreenState extends State<ActorScreen> {
  final _api = TmdbService.instancia;

  late Future<Persona> _actor;
  late Future<List<ElementoMedia>> _peliculas;
  late Future<List<ElementoMedia>> _series;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() {
    _actor = _api.actor(widget.idActor);
    // Ordenadas por popularidad, para que salgan primero las más conocidas
    _peliculas = _api.peliculasActor(widget.idActor).then((lista) {
      lista.sort((a, b) => b.popularidad.compareTo(a.popularidad));
      return _sinRepetir(lista.map((p) => p.comoElemento));
    })..ignore();
    _series = _api.seriesActor(widget.idActor).then((lista) {
      lista.sort((a, b) => b.popularidad.compareTo(a.popularidad));
      return _sinRepetir(lista.map((s) => s.comoElemento));
    })..ignore();
  }

  /// La API repite un título si el actor hizo varios papeles en él.
  List<ElementoMedia> _sinRepetir(Iterable<ElementoMedia> elementos) {
    final vistos = <int>{};
    return elementos.where((e) => vistos.add(e.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Persona>(
      future: _actor,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return FichaCargando(futuro: _actor, reintentar: () => setState(_cargar));
        }
        final a = snapshot.data!;
        final nacimiento = [a.cumpleanos ?? '', a.lugarNacimiento ?? '']
            .where((t) => t.isNotEmpty)
            .join(' · ');
        return FichaDetalle(
          titulo: a.nombre,
          // La foto del actor ocupa toda la cabecera, centrada en la cara
          urlFondo: Config.imagen(a.foto),
          alineacionFondo: Alignment.topCenter,
          altoCabecera: 400,
          datos: [a.conocidoPor ?? ''],
          contenido: [
            if (nacimiento.isNotEmpty) ...[
              const SizedBox(height: 12),
              FilaDato(etiqueta: Textos.cumpleanos, valor: nacimiento),
            ],
            if (a.tambienConocido.isNotEmpty)
              FilaDato(
                etiqueta: Textos.tambienConocido,
                valor: a.tambienConocido.take(3).join(', '),
              ),
            if (a.biografia.isNotEmpty) ...[
              TituloSeccion(Textos.biografia),
              TextoDesplegable(a.biografia, lineas: 6),
            ],
            CargaFutura<List<ElementoMedia>>(
              futuro: _peliculas,
              constructor: (lista) => SeccionHorizontal<ElementoMedia>(
                titulo: Textos.peliculasActor,
                elementos: lista,
                constructor: (e) => TarjetaMedia(elemento: e),
              ),
            ),
            CargaFutura<List<ElementoMedia>>(
              futuro: _series,
              constructor: (lista) => SeccionHorizontal<ElementoMedia>(
                titulo: Textos.seriesActor,
                elementos: lista,
                constructor: (e) => TarjetaMedia(elemento: e),
              ),
            ),
          ],
        );
      },
    );
  }
}
