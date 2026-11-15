import 'package:flutter/material.dart';

import 'models/modelos.dart';
import 'screens/actor_screen.dart';
import 'screens/pelicula_screen.dart';
import 'screens/serie_screen.dart';

// Sustituye a los Intent con putExtra("id", ...) + startActivity(...).
// En Flutter se "apila" una pantalla con Navigator.push y se le pasa el id
// directamente en el constructor. Volver atrás (finish()) es Navigator.pop.

Future<void> abrirDetalle(BuildContext context, ElementoMedia elemento) {
  return Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => elemento.esSerie
        ? SerieScreen(idSerie: elemento.id)
        : PeliculaScreen(idPelicula: elemento.id),
  ));
}

Future<void> abrirActor(BuildContext context, int idPersona) {
  return Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => ActorScreen(idActor: idPersona),
  ));
}
