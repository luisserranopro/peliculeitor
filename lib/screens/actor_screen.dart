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
  late Future<List<Pelicula>> _peliculas;
  late Future<List<Serie>> _series;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() {
    _actor = _api.actor(widget.idActor);
    _peliculas = _api.peliculasActor(widget.idActor);
    _series = _api.seriesActor(widget.idActor);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Persona>(
      future: _actor,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(backgroundColor: Colores.fondoOscuro),
            body: CargaFutura<Persona>(
              futuro: _actor,
              reintentar: () => setState(_cargar),
              constructor: (_) => const SizedBox.shrink(),
            ),
          );
        }
        final a = snapshot.data!;
        return FichaDetalle(
          urlImagen: Config.imagen(a.foto),
          contenido: [
            TituloFicha(titulo: a.nombre),
            FilaDato(etiqueta: Textos.cumpleanos, valor: a.cumpleanos ?? ''),
            FilaDato(etiqueta: Textos.lugarNacimiento, valor: a.lugarNacimiento ?? ''),
            FilaDato(
              etiqueta: Textos.popularidad,
              valor: a.popularidad?.toStringAsFixed(1) ?? '',
            ),
            FilaDato(etiqueta: Textos.conocidoPor, valor: a.conocidoPor ?? ''),
            FilaDato(etiqueta: Textos.tambienConocido, valor: a.tambienConocido.join(', ')),
            if (a.biografia.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Text(
                  Textos.biografia,
                  style: const TextStyle(
                    color: Colores.busqueda,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            TextoLargo(a.biografia),
            CargaFutura<List<Pelicula>>(
              futuro: _peliculas,
              constructor: (lista) => SeccionHorizontal<ElementoMedia>(
                titulo: Textos.peliculasActor,
                elementos: lista.map((p) => p.comoElemento).toList(),
                constructor: (e) => TarjetaMedia(elemento: e),
              ),
            ),
            CargaFutura<List<Serie>>(
              futuro: _series,
              constructor: (lista) => SeccionHorizontal<ElementoMedia>(
                titulo: Textos.seriesActor,
                elementos: lista.map((s) => s.comoElemento).toList(),
                constructor: (e) => TarjetaMedia(elemento: e),
              ),
            ),
          ],
        );
      },
    );
  }
}
